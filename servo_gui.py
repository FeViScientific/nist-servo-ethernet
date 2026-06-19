#!/usr/bin/env python3
"""SuperLaserLand Ethernet GUI - Python reimplementation.

Replicates the original C++ Qt GUI with real-time scope plot from
UDP streaming data. Uses servo_device.py for register communication
and stream_recv.py for data parsing.

Layout: Left column (inputs), middle column (outputs), right (scope).
"""

import sys
import os
import json
import socket
import struct
import threading
import time
import traceback
import collections

try:
    import fcntl  # Linux-only; used to read the host NIC MAC for the stream dest
except ImportError:
    fcntl = None

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'firmware'))
from servo_device import (
    ServoDevice, iir1_coeffs, iir2_coeffs, volts_to_raw16,
    adc16_to_volts, adc24_to_volts,
    volts_to_dac24, dac24_to_volts, dac16_to_volts, sweep_params, sweep_to_freq,
    relock_stepsize, delay_us_to_cycles, freq_to_lockin_pinc,
    freq_to_phasedet_pinc, freq_to_transfer_pinc, deg_to_lockin_poff,
    _from_signed,
    INPUT_ADC0, INPUT_ADC1, INPUT_ADCDIFF, INPUT_LOCKIN, INPUT_PHASEDET,
    INPUT_DAC0, INPUT_DAC1, INPUT_DAC2,
    OUTPUT_RANGES, INPUT_RANGES, AD5791_RANGE,
    DSP_CLK_HZ, CLK1_HZ,
)
from stream_recv import parse_packet

from PyQt5.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QGroupBox, QLabel, QComboBox, QPushButton, QDoubleSpinBox,
    QCheckBox, QScrollArea, QSplitter, QStatusBar, QMessageBox,
    QFileDialog, QAction, QMenuBar, QLineEdit,
)
from PyQt5.QtCore import QTimer, Qt, pyqtSignal, QObject
from PyQt5.QtGui import QFont, QColor

import pyqtgraph as pg

MONITOR_INTERVAL_MS = 200
STREAM_PORT = 5000
# Fallback stream destination, used only if host IP/MAC auto-detection fails.
# The FPGA frames stream packets straight to this MAC/IP with no ARP, so it MUST
# be the machine running the GUI. Auto-detected at runtime by detect_stream_dest().
STREAM_DEST_MAC = 0x6c6e07504577
STREAM_DEST_IP = (192, 168, 7, 4)


def _host_ip_toward(target_ip):
    """This host's IPv4 (as a 4-tuple) on the interface that routes to target_ip.

    Uses a connected UDP socket: connect() on a datagram socket sends nothing but
    makes the kernel pick the source address it would use to reach target_ip.
    """
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect((target_ip, 9))
        ip = s.getsockname()[0]
    finally:
        s.close()
    return tuple(int(x) for x in ip.split('.'))


def _mac_for_host_ip(ip_tuple):
    """MAC (as int) of the Linux interface that owns ip_tuple, or None.

    Walks the interface list, matches the one carrying ip_tuple via SIOCGIFADDR,
    then reads its hardware address via SIOCGIFHWADDR. Linux-only (needs fcntl).
    """
    if fcntl is None:
        return None
    ip_str = '.'.join(str(x) for x in ip_tuple)
    SIOCGIFADDR = 0x8915
    SIOCGIFHWADDR = 0x8927
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        for _, ifname in socket.if_nameindex():
            req = struct.pack('256s', ifname.encode()[:15])
            try:
                if_ip = socket.inet_ntoa(
                    fcntl.ioctl(s.fileno(), SIOCGIFADDR, req)[20:24])
            except OSError:
                continue  # interface has no IPv4 address
            if if_ip == ip_str:
                hw = fcntl.ioctl(s.fileno(), SIOCGIFHWADDR, req)[18:24]
                return int.from_bytes(hw, 'big')
    finally:
        s.close()
    return None


def mac_int_to_str(mac):
    """0x6c6e07504577 -> '6c:6e:07:50:45:77'."""
    return ':'.join(f'{(mac >> (8 * i)) & 0xff:02x}' for i in range(5, -1, -1))


def mac_str_to_int(s):
    """'6c:6e:07:50:45:77' (or '6c-6e-...' / bare hex) -> int. Raises ValueError."""
    hexs = s.replace(':', '').replace('-', '').strip()
    if len(hexs) != 12:
        raise ValueError(f'MAC must be 6 bytes, got {s!r}')
    return int(hexs, 16)


def ip_str_to_tuple(s):
    """'192.168.7.4' -> (192, 168, 7, 4). Raises ValueError on malformed input."""
    parts = s.strip().split('.')
    if len(parts) != 4:
        raise ValueError(f'IP must have 4 octets, got {s!r}')
    octets = tuple(int(p) for p in parts)
    if any(o < 0 or o > 255 for o in octets):
        raise ValueError(f'IP octet out of range in {s!r}')
    return octets


def detect_stream_dest(fpga_ip):
    """(ip_tuple, mac_int) for streaming to this host; fallback to compiled defaults.

    The FPGA sends the UDP data stream to a fixed dest MAC/IP without ARP, so the
    destination must be the host running the GUI. Returns auto-detected values
    when possible, else the STREAM_DEST_* fallbacks.
    """
    try:
        ip = _host_ip_toward(fpga_ip)
        mac = _mac_for_host_ip(ip)
        if mac is not None:
            return ip, mac
    except Exception:
        pass
    return STREAM_DEST_IP, STREAM_DEST_MAC

INPUT_NAMES = ['AIN0', 'AIN1', 'AIN0-AIN1', 'LOCKIN', 'PHASEDET',
               'AOUT0', 'AOUT1', 'AOUT2']
# Mux source value for each INPUT_NAMES entry (servo input mux + relock input).
INPUT_SOURCES = [INPUT_ADC0, INPUT_ADC1, INPUT_ADCDIFF, INPUT_LOCKIN,
                 INPUT_PHASEDET, INPUT_DAC0, INPUT_DAC1, INPUT_DAC2]
HOLD_NAMES = ['Off', 'Relock0', 'Relock1', 'Relock2',
              'DIN0', 'DIN1', 'DIN2', '!DIN0', '!DIN1', '!DIN2']
HOLD_VALUES = [0, 0x01, 0x03, 0x05, 0x07, 0x09, 0x0B, 0x0D, 0x0F, 0x11]

# Stream channel names matching LoggerData fields
SCOPE_CHANNELS = [
    'Off', 'AIN0 raw', 'AIN1 raw', 'AIN0 filt', 'AIN1 filt',
    'AOUT0', 'AOUT1', 'AOUT2',
    'LOCKIN', 'PHASEDET',
    'TF sin', 'TF cos',
]
SCOPE_FIELD_MAP = {
    'AIN0 raw': 'adc_raw0', 'AIN1 raw': 'adc_raw1',
    'AIN0 filt': 'adc_filt0', 'AIN1 filt': 'adc_filt1',
    'AOUT0': 'dacin0', 'AOUT1': 'dacin1', 'AOUT2': 'dacin2',
    'LOCKIN': 'lockin_out', 'PHASEDET': 'phasedet',
    'TF sin': 'tf_sin', 'TF cos': 'tf_cos',
}
TRACE_COLORS = ['r', 'b', 'g', 'm', 'c']
N_TRACES = 5
N_PLOT_POINTS = 200

# Full-scale 16-bit limit value (symmetric) used to effectively disable output clamping.
RAW16_FULLSCALE = 0x7FFF


def safe_callback(func):
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except Exception:
            traceback.print_exc()
    return wrapper


###############################################################################
# Stream receiver thread
###############################################################################

class StreamReceiver(QObject):
    """Background thread receiving UDP stream data."""
    new_samples = pyqtSignal(list)  # emits list of parsed sample dicts

    def __init__(self, port=STREAM_PORT):
        super().__init__()
        self.port = port
        self._running = False
        self._thread = None

    def start(self):
        if self._thread and self._thread.is_alive():
            return
        self._running = True
        self._thread = threading.Thread(target=self._run, daemon=True)
        self._thread.start()

    def stop(self):
        self._running = False

    def _run(self):
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        sock.bind(('0.0.0.0', self.port))
        sock.settimeout(0.5)
        while self._running:
            try:
                data, addr = sock.recvfrom(2048)
                samples = parse_packet(data)
                if samples:
                    self.new_samples.emit(samples)
            except socket.timeout:
                continue
            except Exception:
                continue
        sock.close()


###############################################################################
# Scope plot widget
###############################################################################

class ScopePlot(QWidget):
    """Real-time scope plot matching the original C++ ScopePlot."""

    # Fields that carry ADC data (16-bit signed, need V conversion)
    ADC_FIELDS = {'adc_raw0', 'adc_raw1', 'adc_filt0', 'adc_filt1'}

    def __init__(self, parent=None):
        super().__init__(parent)
        self._ain_panels = {}   # ADC field -> InputPanel, set by MainWindow
        self._aout_panels = {}  # DAC field -> OutputPanel, set by MainWindow
        layout = QVBoxLayout(self)

        # Plot widget
        self.plot = pg.PlotWidget()
        self.plot.setBackground('w')
        self.plot.showGrid(x=True, y=True, alpha=0.3)
        self.plot.setLabel('bottom', 'Sample')
        self.plot.setLabel('left', 'Value')
        self.plot.setMinimumSize(400, 300)
        layout.addWidget(self.plot)

        # Traces: main curve (avg) + fill between min/max
        self.curves = []
        self.fills = []
        self.data_avg = [collections.deque(maxlen=N_PLOT_POINTS) for _ in range(N_TRACES)]
        self.data_min = [collections.deque(maxlen=N_PLOT_POINTS) for _ in range(N_TRACES)]
        self.data_max = [collections.deque(maxlen=N_PLOT_POINTS) for _ in range(N_TRACES)]
        TRACE_QCOLORS = [QColor(255,0,0), QColor(0,0,255), QColor(0,180,0),
                         QColor(180,0,180), QColor(0,180,180)]
        for i in range(N_TRACES):
            color = TRACE_COLORS[i]
            fill_color = QColor(TRACE_QCOLORS[i])
            fill_color.setAlpha(40)
            # Min/max band (filled area)
            curve_min = self.plot.plot(pen=pg.mkPen(color, width=0))
            curve_max = self.plot.plot(pen=pg.mkPen(color, width=0))
            fill = pg.FillBetweenItem(curve_min, curve_max,
                                       brush=pg.mkBrush(fill_color))
            self.plot.addItem(fill)
            self.fills.append((curve_min, curve_max, fill))
            # Average line (on top)
            curve = self.plot.plot(pen=pg.mkPen(color, width=2))
            self.curves.append(curve)

        # X-Y curve (hidden by default, shown in X-Y mode)
        self.xy_curve = self.plot.plot(pen=pg.mkPen('r', width=2))
        self.xy_curve.hide()
        self.xy_data_x = collections.deque(maxlen=2000)
        self.xy_data_y = collections.deque(maxlen=2000)

        # Mode + envelope toggle
        mode_row = QHBoxLayout()
        mode_row.addWidget(QLabel('Mode:'))
        self.mode_combo = QComboBox()
        self.mode_combo.addItems(['Off', 'Rolling', 'X-Y'])
        self.mode_combo.currentIndexChanged.connect(self._on_mode_changed)
        mode_row.addWidget(self.mode_combo)
        self.envelope_cb = QCheckBox('Min/Max bands')
        self.envelope_cb.setChecked(True)
        mode_row.addWidget(self.envelope_cb)
        self.clear_btn = QPushButton('Clear')
        self.clear_btn.clicked.connect(self._clear_rolling)
        mode_row.addWidget(self.clear_btn)
        mode_row.addStretch()
        layout.addLayout(mode_row)

        # X-Y controls (shown only in X-Y mode)
        self.xy_widget = QWidget()
        xy_row = QHBoxLayout(self.xy_widget)
        xy_row.setContentsMargins(0, 0, 0, 0)
        xy_row.addWidget(QLabel('X:'))
        self.xy_x_combo = QComboBox()
        self.xy_x_combo.addItems(SCOPE_CHANNELS[1:])  # no 'Off'
        self.xy_x_combo.setCurrentIndex(4)  # AOUT0
        xy_row.addWidget(self.xy_x_combo)
        xy_row.addWidget(QLabel('Y:'))
        self.xy_y_combo = QComboBox()
        self.xy_y_combo.addItems(SCOPE_CHANNELS[1:])
        self.xy_y_combo.setCurrentIndex(0)  # AIN0 raw
        xy_row.addWidget(self.xy_y_combo)
        self.xy_clear_btn = QPushButton('Clear')
        self.xy_clear_btn.clicked.connect(self._xy_clear)
        xy_row.addWidget(self.xy_clear_btn)
        xy_row.addStretch()
        layout.addWidget(self.xy_widget)
        self.xy_widget.hide()

        # Accumulator for 5 Hz decimation (collects all 500 Hz samples between plot updates)
        self._accum = [[] for _ in range(N_TRACES)]
        self._xy_accum_x = []
        self._xy_accum_y = []

        # Per-trace controls
        self.ch_combos = []
        self.scale_spins = []
        self.offset_spins = []
        for i in range(N_TRACES):
            row = QHBoxLayout()
            color_label = QLabel('---')
            color_label.setStyleSheet(f'color: {TRACE_COLORS[i]}; font-weight: bold;')
            color_label.setFixedWidth(20)
            row.addWidget(color_label)

            ch = QComboBox()
            ch.addItems(SCOPE_CHANNELS)
            if i < 2:
                ch.setCurrentIndex(i + 1)  # Default: AIN0 raw, AIN1 raw
            row.addWidget(ch)
            self.ch_combos.append(ch)

            row.addWidget(QLabel('Scale:'))
            scale = QDoubleSpinBox()
            scale.setRange(0.001, 100000)
            scale.setValue(1.0)
            scale.setDecimals(3)
            scale.setPrefix('/')
            row.addWidget(scale)
            self.scale_spins.append(scale)

            row.addWidget(QLabel('Offset:'))
            offset = QDoubleSpinBox()
            offset.setRange(-1e6, 1e6)
            offset.setValue(0)
            offset.setDecimals(1)
            row.addWidget(offset)
            self.offset_spins.append(offset)

            layout.addLayout(row)

    def set_panels(self, ain0, ain1, aout0, aout1, aout2):
        """Register the input/output panels so stream fields can be converted
        to physical units using each panel's live range setting."""
        self._ain_panels = {
            'adc_raw0': ain0, 'adc_filt0': ain0,
            'adc_raw1': ain1, 'adc_filt1': ain1,
        }
        self._aout_panels = {'dacin0': aout0, 'dacin1': aout1, 'dacin2': aout2}

    def _to_volts(self, field, raw):
        """Convert a raw stream value to a plottable physical unit.

        Every stream field is 16-bit: the firmware packs only the top 16 bits of
        each wide internal signal into the LoggerData slot (see
        ADCout[i][SIGNAL_SIZE-1:SIGNAL_SIZE-16] in the gateware). So:
          - ADC raw/filt -> volts via adc16_to_volts (input range).
          - DAC (dacin0/1/2) -> volts via dac16_to_volts (output range; AD5791
            0-10V for ch2). Matches OutputPanel.update_readback, which uses the
            full-width register value and dac24_to_volts.
          - LOCKIN / TF sin/cos -> normalized to +/-1.0 of full scale; these are
            internal DSP signals with no absolute-volts mapping (their readback
            panels show raw counts), but normalizing keeps them co-plottable with
            the volt-scale traces instead of dominating autorange at +/-32768.
          - anything else (e.g. phasedet) -> raw.
        """
        panel = self._ain_panels.get(field)
        if panel is not None:
            vmin, vmax = INPUT_RANGES[panel.range_combo.currentIndex()]
            return adc16_to_volts(raw, vmin, vmax)
        panel = self._aout_panels.get(field)
        if panel is not None:
            vmin, vmax = panel._get_range()
            return dac16_to_volts(raw, vmin, vmax)
        if field in ('lockin_out', 'tf_sin', 'tf_cos'):
            return raw / 32768.0
        return raw

    def _on_mode_changed(self, idx):
        is_xy = (idx == 2)
        self.xy_widget.setVisible(is_xy)
        # Hide/show rolling traces vs X-Y curve
        if is_xy:
            for i in range(N_TRACES):
                self.curves[i].hide()
                cm, cx, f = self.fills[i]
                cm.hide(); cx.hide(); f.hide()
            self.xy_curve.show()
            self.plot.setLabel('bottom', 'X')
            self.plot.setLabel('left', 'Y')
            self._xy_clear()
        else:
            self.xy_curve.hide()
            self.plot.setLabel('bottom', 'Sample')
            self.plot.setLabel('left', 'Value')

    def _clear_rolling(self):
        for i in range(N_TRACES):
            self.data_avg[i].clear()
            self.data_min[i].clear()
            self.data_max[i].clear()
            self._accum[i].clear()
        self._update_plot()

    def _xy_clear(self):
        self.xy_data_x.clear()
        self.xy_data_y.clear()
        self._xy_accum_x.clear()
        self._xy_accum_y.clear()
        self.xy_curve.setData([], [])

    def add_samples(self, samples):
        """Called when new stream samples arrive (~125 packets/sec).
        Accumulates raw values; flush() is called at 5 Hz to update plot."""
        mode = self.mode_combo.currentIndex()
        if mode == 0:
            return
        if mode == 2:  # X-Y mode: accumulate all samples directly
            x_field = SCOPE_FIELD_MAP.get(self.xy_x_combo.currentText())
            y_field = SCOPE_FIELD_MAP.get(self.xy_y_combo.currentText())
            if x_field and y_field:
                for s in samples:
                    if x_field in s and y_field in s:
                        self._xy_accum_x.append(self._to_volts(x_field, s[x_field]))
                        self._xy_accum_y.append(self._to_volts(y_field, s[y_field]))
            return
        # Rolling mode
        for s in samples:
            for i in range(N_TRACES):
                ch_name = self.ch_combos[i].currentText()
                field = SCOPE_FIELD_MAP.get(ch_name)
                if field and field in s:
                    val = self._to_volts(field, s[field])
                    val = (val - self.offset_spins[i].value()) / self.scale_spins[i].value()
                    self._accum[i].append(val)

    def flush(self):
        """Called at 5 Hz by the monitor timer. Computes avg/min/max from
        accumulated samples and adds one point to the rolling plot."""
        mode = self.mode_combo.currentIndex()
        if mode == 0:
            return
        if mode == 2:  # X-Y mode
            if self._xy_accum_x:
                self.xy_data_x.extend(self._xy_accum_x)
                self.xy_data_y.extend(self._xy_accum_y)
                self._xy_accum_x.clear()
                self._xy_accum_y.clear()
                self.xy_curve.setData(list(self.xy_data_x), list(self.xy_data_y))
                self.plot.enableAutoRange()
            return
        # Rolling mode
        for i in range(N_TRACES):
            buf = self._accum[i]
            if buf:
                avg = sum(buf) / len(buf)
                mn = min(buf)
                mx = max(buf)
                buf.clear()
            else:
                avg = 0; mn = 0; mx = 0
            self.data_avg[i].append(avg)
            self.data_min[i].append(mn)
            self.data_max[i].append(mx)
        self._update_plot()

    def _update_plot(self):
        show_envelope = self.envelope_cb.isChecked()
        for i in range(N_TRACES):
            ch_name = self.ch_combos[i].currentText()
            curve_min, curve_max, fill = self.fills[i]
            if ch_name == 'Off' or not self.data_avg[i]:
                self.curves[i].hide()
                curve_min.hide()
                curve_max.hide()
                fill.hide()
                if ch_name == 'Off':
                    self.data_avg[i].clear()
                    self.data_min[i].clear()
                    self.data_max[i].clear()
                    self._accum[i].clear()
            else:
                x = list(range(len(self.data_avg[i])))
                self.curves[i].setData(x, list(self.data_avg[i]))
                self.curves[i].show()
                if show_envelope:
                    curve_min.setData(x, list(self.data_min[i]))
                    curve_max.setData(x, list(self.data_max[i]))
                    curve_min.show()
                    curve_max.show()
                    fill.show()
                else:
                    curve_min.hide()
                    curve_max.hide()
                    fill.hide()
        self.plot.enableAutoRange()


###############################################################################
# Input panel (AIN0 / AIN1)
###############################################################################

class InputPanel(QGroupBox):
    def __init__(self, dev, ch, parent=None):
        super().__init__(f'AIN{ch}', parent)
        self.dev = dev
        self.ch = ch
        self._updating = False
        layout = QVBoxLayout(self)

        row = QHBoxLayout()
        row.addWidget(QLabel('Input range:'))
        self.range_combo = QComboBox()
        for r in INPUT_RANGES:
            self.range_combo.addItem(f'+/-{r[1]} V')
        row.addWidget(self.range_combo)
        layout.addLayout(row)

        row = QHBoxLayout()
        self.iir_on = QCheckBox('IIR filter')
        row.addWidget(self.iir_on)
        self.iir_type = QComboBox()
        self.iir_type.addItems(['Low pass', 'High pass', 'All pass', 'P'])
        row.addWidget(self.iir_type)
        layout.addLayout(row)

        row = QHBoxLayout()
        row.addWidget(QLabel('Freq:'))
        self.iir_freq = QDoubleSpinBox()
        self.iir_freq.setRange(1, 10e6)
        self.iir_freq.setValue(10000)
        self.iir_freq.setSuffix(' Hz')
        self.iir_freq.setDecimals(0)
        row.addWidget(self.iir_freq)
        row.addWidget(QLabel('Gain:'))
        self.iir_gain = QDoubleSpinBox()
        self.iir_gain.setRange(-60, 60)
        self.iir_gain.setValue(0)
        self.iir_gain.setSuffix(' dB')
        row.addWidget(self.iir_gain)
        layout.addLayout(row)

        self.readback = QLabel('ADC: ---')
        self.readback.setFont(QFont('monospace', 9))
        layout.addWidget(self.readback)

        self.range_combo.currentIndexChanged.connect(self._on_range_changed)
        self.iir_on.toggled.connect(self._on_iir_changed)
        self.iir_type.currentIndexChanged.connect(self._on_iir_changed)
        self.iir_freq.valueChanged.connect(self._on_iir_changed)
        self.iir_gain.valueChanged.connect(self._on_iir_changed)

    @safe_callback
    def _on_range_changed(self, *_):
        if self._updating: return
        gain0, gain1 = self.dev.read_input_gain()
        if self.ch == 0:
            gain0 = self.range_combo.currentIndex()
        else:
            gain1 = self.range_combo.currentIndex()
        self.dev.set_input_gain(gain0, gain1)

    @safe_callback
    def _on_iir_changed(self, *_):
        if self._updating: return
        types = ['lowpass', 'highpass', 'allpass', 'p']
        t = types[self.iir_type.currentIndex()]
        c = iir1_coeffs(t, self.iir_freq.value(), gain_db=self.iir_gain.value(),
                        a0_shift=26, fs=DSP_CLK_HZ)
        self.dev.set_adc_iir(self.ch, self.iir_on.isChecked(), **c)

    def update_readback(self, raw, filtered):
        vmin, vmax = INPUT_RANGES[self.range_combo.currentIndex()]
        raw_v = adc16_to_volts(raw, vmin, vmax)
        filt_v = adc24_to_volts(filtered, vmin, vmax)
        self.readback.setText(f'Raw: {raw_v:+.4f} V ({raw:+d})  Filt: {filt_v:+.4f} V')

    def get_settings(self):
        return {
            'range': self.range_combo.currentIndex(),
            'iir_on': self.iir_on.isChecked(),
            'iir_type': self.iir_type.currentIndex(),
            'iir_freq': self.iir_freq.value(),
            'iir_gain': self.iir_gain.value(),
        }

    def apply_settings(self, s):
        self._updating = True
        try:
            self.range_combo.setCurrentIndex(s.get('range', self.range_combo.currentIndex()))
            self.iir_on.setChecked(s.get('iir_on', self.iir_on.isChecked()))
            self.iir_type.setCurrentIndex(s.get('iir_type', self.iir_type.currentIndex()))
            self.iir_freq.setValue(s.get('iir_freq', self.iir_freq.value()))
            self.iir_gain.setValue(s.get('iir_gain', self.iir_gain.value()))
        finally:
            self._updating = False
        # Push restored values to hardware
        self._on_range_changed()
        self._on_iir_changed()


###############################################################################
# Output panel (AOUT0 / AOUT1 / AOUT2)
###############################################################################

class OutputPanel(QGroupBox):
    def __init__(self, dev, ch, parent=None):
        super().__init__(f'AOUT{ch}', parent)
        self.dev = dev
        self.ch = ch
        self._updating = False
        self.is_slow = (ch == 2)
        layout = QVBoxLayout(self)

        # Output range
        row = QHBoxLayout()
        row.addWidget(QLabel('Range:'))
        self.range_combo = QComboBox()
        if self.is_slow:
            self.range_combo.addItem('+10 V')
        else:
            for r in OUTPUT_RANGES:
                self.range_combo.addItem(f'+/-{r[1]:.0f} V')
        row.addWidget(self.range_combo)
        layout.addLayout(row)

        # Direct output
        row = QHBoxLayout()
        row.addWidget(QLabel('Direct:'))
        self.direct_spin = QDoubleSpinBox()
        self.direct_spin.setRange(-10, 10)
        self.direct_spin.setSuffix(' V')
        self.direct_spin.setDecimals(4)
        self.direct_spin.setSingleStep(0.01)
        row.addWidget(self.direct_spin)
        self.direct_btn = QPushButton('Set')
        self.direct_btn.clicked.connect(self._on_direct_set)
        row.addWidget(self.direct_btn)
        self.zero_btn = QPushButton('Zero')
        self.zero_btn.clicked.connect(self._on_direct_zero)
        row.addWidget(self.zero_btn)
        layout.addLayout(row)

        # Standalone sweep
        row = QHBoxLayout()
        self.quick_sweep = QCheckBox('Sweep')
        row.addWidget(self.quick_sweep)
        row.addWidget(QLabel('Vpp:'))
        self.qs_ampl = QDoubleSpinBox()
        self.qs_ampl.setRange(0, 10)
        self.qs_ampl.setValue(0.5)
        self.qs_ampl.setSuffix(' V')
        self.qs_ampl.setDecimals(3)
        row.addWidget(self.qs_ampl)
        row.addWidget(QLabel('Freq:'))
        self.qs_freq = QDoubleSpinBox()
        self.qs_freq.setRange(0.01, 1e6)
        self.qs_freq.setValue(100)
        self.qs_freq.setSuffix(' Hz')
        self.qs_freq.setDecimals(1)
        row.addWidget(self.qs_freq)
        layout.addLayout(row)

        self.quick_sweep.toggled.connect(self._on_quick_sweep)
        self.qs_ampl.valueChanged.connect(self._on_quick_sweep)
        self.qs_freq.valueChanged.connect(self._on_quick_sweep)

        # Output limits
        row = QHBoxLayout()
        row.addWidget(QLabel('Limits:'))
        self.limit_min = QDoubleSpinBox()
        self.limit_min.setRange(-10, 10)
        self.limit_min.setValue(-1)
        self.limit_min.setSuffix(' V')
        self.limit_min.setDecimals(3)
        row.addWidget(self.limit_min)
        row.addWidget(QLabel(f'< out <'))
        self.limit_max = QDoubleSpinBox()
        self.limit_max.setRange(-10, 10)
        self.limit_max.setValue(1)
        self.limit_max.setSuffix(' V')
        self.limit_max.setDecimals(3)
        row.addWidget(self.limit_max)
        layout.addLayout(row)

        # Servo on/off + edit toggle
        row = QHBoxLayout()
        self.servo_btn = QPushButton('Loop filter')
        self.servo_btn.setCheckable(True)
        row.addWidget(self.servo_btn)
        self.edit_btn = QPushButton('Edit')
        self.edit_btn.setCheckable(True)
        self.edit_btn.setChecked(False)
        row.addWidget(self.edit_btn)
        layout.addLayout(row)

        # Parameters container
        self.params = QWidget()
        pl = QVBoxLayout(self.params)
        pl.setContentsMargins(0, 0, 0, 0)

        # Input selection
        row = QHBoxLayout()
        row.addWidget(QLabel('Input:'))
        self.sign_combo = QComboBox()
        self.sign_combo.addItems(['+', '-'])
        row.addWidget(self.sign_combo)
        self.input_combo = QComboBox()
        for name, src in zip(INPUT_NAMES, INPUT_SOURCES):
            self.input_combo.addItem(name, src)
        row.addWidget(self.input_combo)
        row.addWidget(QLabel('Offset:'))
        self.offset_spin = QDoubleSpinBox()
        self.offset_spin.setRange(-10, 10)
        self.offset_spin.setSuffix(' V')
        self.offset_spin.setDecimals(4)
        row.addWidget(self.offset_spin)
        pl.addLayout(row)

        # IIR filters
        self.iir0_group = self._make_iir2('IIR0 (2nd)',
            ['P', 'Notch', 'I/HO', 'Low pass', 'High pass'])
        pl.addWidget(self.iir0_group)

        self.iir1_group = self._make_iir1('IIR1 (1st)',
            ['P', 'Low pass', 'High pass', 'PI', 'PD', 'I'])
        pl.addWidget(self.iir1_group)

        if not self.is_slow:
            self.iir2_group = self._make_iir1('IIR2', ['P', 'Low pass', 'High pass', 'PI', 'PD', 'I'])
            pl.addWidget(self.iir2_group)
            self.iir3_group = self._make_iir1('IIR3', ['P', 'Low pass', 'High pass', 'PI', 'PD', 'I'])
            pl.addWidget(self.iir3_group)

        # Sweep
        row = QHBoxLayout()
        self.sweep_on = QCheckBox('Sweep')
        row.addWidget(self.sweep_on)
        self.sweep_center = QDoubleSpinBox()
        self.sweep_center.setRange(-10, 10); self.sweep_center.setSuffix(' V'); self.sweep_center.setDecimals(3)
        row.addWidget(QLabel('Ctr:')); row.addWidget(self.sweep_center)
        self.sweep_ampl = QDoubleSpinBox()
        self.sweep_ampl.setRange(0, 10); self.sweep_ampl.setSuffix(' V'); self.sweep_ampl.setDecimals(3)
        row.addWidget(QLabel('Vpp:')); row.addWidget(self.sweep_ampl)
        self.sweep_freq = QDoubleSpinBox()
        self.sweep_freq.setRange(0.01, 1e6); self.sweep_freq.setValue(100); self.sweep_freq.setSuffix(' Hz')
        row.addWidget(QLabel('F:')); row.addWidget(self.sweep_freq)
        pl.addLayout(row)

        # Relock
        row = QHBoxLayout()
        self.relock_on = QCheckBox('Relock')
        row.addWidget(self.relock_on)
        self.relock_input = QComboBox()
        for name, src in zip(INPUT_NAMES, INPUT_SOURCES):
            self.relock_input.addItem(name, src)
        for i, name in enumerate(['DIN0', 'DIN1', 'DIN2']):
            self.relock_input.addItem(name, len(INPUT_SOURCES) + i)
        row.addWidget(self.relock_input)
        self.relock_rate = QDoubleSpinBox()
        self.relock_rate.setRange(0.01, 10000); self.relock_rate.setValue(1); self.relock_rate.setSuffix(' V/s')
        row.addWidget(QLabel('Rate:')); row.addWidget(self.relock_rate)
        pl.addLayout(row)

        # Hold
        row = QHBoxLayout()
        row.addWidget(QLabel('Hold:'))
        self.hold_combo = QComboBox()
        self.hold_combo.addItems(HOLD_NAMES)
        row.addWidget(self.hold_combo)
        self.hold_fall = QDoubleSpinBox()
        self.hold_fall.setRange(0, 1e6); self.hold_fall.setSuffix(' us')
        row.addWidget(QLabel('Fall:')); row.addWidget(self.hold_fall)
        self.hold_rise = QDoubleSpinBox()
        self.hold_rise.setRange(0, 1e6); self.hold_rise.setSuffix(' us')
        row.addWidget(QLabel('Rise:')); row.addWidget(self.hold_rise)
        pl.addLayout(row)

        self.center_railed = QCheckBox('Clear integrators when railed')
        pl.addWidget(self.center_railed)

        layout.addWidget(self.params)
        self.params.setVisible(False)

        # Readback
        self.readback = QLabel('Output: ---')
        self.readback.setFont(QFont('monospace', 9))
        layout.addWidget(self.readback)

        # Connections
        self.edit_btn.toggled.connect(self.params.setVisible)
        self.range_combo.currentIndexChanged.connect(self._on_range_changed)
        self.servo_btn.toggled.connect(self._on_servo_toggled)
        self.limit_min.valueChanged.connect(self._on_limits_changed)
        self.limit_max.valueChanged.connect(self._on_limits_changed)
        self.center_railed.toggled.connect(self._on_limits_changed)
        self.sign_combo.currentIndexChanged.connect(self._on_input_changed)
        self.input_combo.currentIndexChanged.connect(self._on_input_changed)
        self.offset_spin.valueChanged.connect(self._on_input_changed)
        self.sweep_on.toggled.connect(self._on_sweep_changed)
        self.sweep_center.valueChanged.connect(self._on_sweep_changed)
        self.sweep_ampl.valueChanged.connect(self._on_sweep_changed)
        self.sweep_freq.valueChanged.connect(self._on_sweep_changed)
        self.relock_on.toggled.connect(self._on_relock_changed)
        self.relock_input.currentIndexChanged.connect(self._on_relock_changed)
        self.relock_rate.valueChanged.connect(self._on_relock_changed)
        self.hold_combo.currentIndexChanged.connect(self._on_hold_changed)
        self.hold_fall.valueChanged.connect(self._on_hold_changed)
        self.hold_rise.valueChanged.connect(self._on_hold_changed)

    def _make_iir1(self, title, types):
        g = QGroupBox(title); g.setCheckable(True); g.setChecked(False)
        l = QHBoxLayout(g)
        c = QComboBox(); c.addItems(types); l.addWidget(c)
        l.addWidget(QLabel('F:'))
        f = QDoubleSpinBox(); f.setRange(0.01, 10e6); f.setValue(1000); f.setSuffix(' Hz'); l.addWidget(f)
        l.addWidget(QLabel('G:'))
        ga = QDoubleSpinBox(); ga.setRange(-60, 60); ga.setSuffix(' dB'); l.addWidget(ga)
        l.addWidget(QLabel('Lim:'))
        gl = QDoubleSpinBox(); gl.setRange(0, 81); gl.setValue(81); gl.setSuffix(' dB'); l.addWidget(gl)
        g._w = {'combo': c, 'freq': f, 'gain': ga, 'glimit': gl}
        g.toggled.connect(lambda *_: self._on_iir_changed())
        c.currentIndexChanged.connect(lambda *_: self._on_iir_changed())
        f.valueChanged.connect(lambda *_: self._on_iir_changed())
        ga.valueChanged.connect(lambda *_: self._on_iir_changed())
        gl.valueChanged.connect(lambda *_: self._on_iir_changed())
        return g

    def _make_iir2(self, title, types):
        g = QGroupBox(title); g.setCheckable(True); g.setChecked(False)
        l = QHBoxLayout(g)
        c = QComboBox(); c.addItems(types); l.addWidget(c)
        l.addWidget(QLabel('F:'))
        f = QDoubleSpinBox(); f.setRange(0.01, 10e6); f.setValue(1000); f.setSuffix(' Hz'); l.addWidget(f)
        l.addWidget(QLabel('Q:'))
        q = QDoubleSpinBox(); q.setRange(0.01, 100); q.setValue(0.707); q.setDecimals(3); l.addWidget(q)
        l.addWidget(QLabel('G:'))
        ga = QDoubleSpinBox(); ga.setRange(-60, 60); ga.setSuffix(' dB'); l.addWidget(ga)
        l.addWidget(QLabel('Lim:'))
        gl = QDoubleSpinBox(); gl.setRange(0, 81); gl.setValue(81); gl.setSuffix(' dB'); l.addWidget(gl)
        g._w = {'combo': c, 'freq': f, 'q': q, 'gain': ga, 'glimit': gl}
        g.toggled.connect(lambda *_: self._on_iir_changed())
        c.currentIndexChanged.connect(lambda *_: self._on_iir_changed())
        f.valueChanged.connect(lambda *_: self._on_iir_changed())
        q.valueChanged.connect(lambda *_: self._on_iir_changed())
        ga.valueChanged.connect(lambda *_: self._on_iir_changed())
        gl.valueChanged.connect(lambda *_: self._on_iir_changed())
        return g

    def _get_range(self):
        if self.is_slow: return AD5791_RANGE
        return OUTPUT_RANGES[self.range_combo.currentIndex()]

    @safe_callback
    def _on_range_changed(self, *_):
        if self._updating or self.is_slow:
            return
        gain0, gain1 = self.dev.read_output_gain()
        if self.ch == 0:
            gain0 = self.range_combo.currentIndex()
        else:
            gain1 = self.range_combo.currentIndex()
        self.dev.set_output_gain(gain0, gain1)

    @safe_callback
    def _on_direct_set(self, *_):
        vmin, vmax = self._get_range()
        self.dev.set_dac(self.ch, volts_to_dac24(self.direct_spin.value(), vmin, vmax))

    @safe_callback
    def _on_direct_zero(self, *_):
        self.dev.set_dac(self.ch, 0); self.direct_spin.setValue(0)

    @safe_callback
    def _on_quick_sweep(self, *_):
        if self._updating: return
        if not self.quick_sweep.isChecked():
            self.dev.set_sweep(self.ch, False); self.dev.servo_on(self.ch, False); return
        vmin, vmax = self._get_range()
        self.dev.set_iir0(self.ch, False)
        self.dev.set_iir1(self.ch, False, a1=0, b0=0, b1=0)
        if not self.is_slow:
            self.dev.set_iir2(self.ch, False, a1=0, b0=0, b1=0)
            self.dev.set_iir3(self.ch, False, a1=0, b0=0, b1=0)
        self.dev.set_relock(self.ch, False)
        self.dev.set_limits(self.ch, -RAW16_FULLSCALE, RAW16_FULLSCALE)
        try:
            mn, mx, step = sweep_params(0, self.qs_ampl.value(), self.qs_freq.value(), vmin, vmax)
            self.dev.set_sweep(self.ch, True, min_val=mn, max_val=mx, stepsize=step)
        except Exception: pass
        self.dev.servo_on(self.ch, True)

    @safe_callback
    def _on_servo_toggled(self, on):
        if self._updating: return
        self.dev.servo_on(self.ch, on)

    @safe_callback
    def _on_limits_changed(self, *_):
        if self._updating: return
        vmin, vmax = self._get_range()
        self.dev.set_limits(self.ch, volts_to_raw16(self.limit_min.value(), vmin, vmax),
                            volts_to_raw16(self.limit_max.value(), vmin, vmax),
                            self.center_railed.isChecked())

    @safe_callback
    def _on_input_changed(self, *_):
        if self._updating: return
        self.dev.set_input_mux(self.ch, self.input_combo.currentData(),
                                self.sign_combo.currentIndex() == 1)
        vmin, vmax = self._get_range()
        self.dev.set_offset(self.ch, volts_to_raw16(self.offset_spin.value(), vmin, vmax))

    @safe_callback
    def _on_iir_changed(self, *_):
        if self._updating: return
        tmap2 = {'p':'p','notch':'notch','i/ho':'iho','low pass':'lowpass','high pass':'highpass'}
        tmap1 = {'p':'p','low pass':'lowpass','high pass':'highpass','pi':'pi','pd':'pd','i':'i'}
        w = self.iir0_group._w
        t = tmap2.get(w['combo'].currentText().lower(), 'p')
        c = iir2_coeffs(t, w['freq'].value(), Q=w['q'].value(), gain_db=w['gain'].value(),
                        gain_limit_db=w['glimit'].value(), a0_shift=26, update_every=27, fs=DSP_CLK_HZ)
        self.dev.set_iir0(self.ch, self.iir0_group.isChecked(), **c)

        w = self.iir1_group._w
        t = tmap1.get(w['combo'].currentText().lower(), 'p')
        c = iir1_coeffs(t, w['freq'].value(), gain_db=w['gain'].value(),
                        gain_limit_db=w['glimit'].value(), a0_shift=26, fs=DSP_CLK_HZ)
        self.dev.set_iir1(self.ch, self.iir1_group.isChecked(), **c)

        if not self.is_slow:
            for idx, grp in [(2, self.iir2_group), (3, self.iir3_group)]:
                w = grp._w
                t = tmap1.get(w['combo'].currentText().lower(), 'p')
                c = iir1_coeffs(t, w['freq'].value(), gain_db=w['gain'].value(),
                                gain_limit_db=w['glimit'].value(), a0_shift=26, fs=DSP_CLK_HZ)
                (self.dev.set_iir2 if idx == 2 else self.dev.set_iir3)(self.ch, grp.isChecked(), **c)

    @safe_callback
    def _on_sweep_changed(self, *_):
        if self._updating: return
        if not self.sweep_on.isChecked():
            self.dev.set_sweep(self.ch, False); return
        vmin, vmax = self._get_range()
        try:
            mn, mx, step = sweep_params(self.sweep_center.value(), self.sweep_ampl.value(),
                                         self.sweep_freq.value(), vmin, vmax)
            self.dev.set_sweep(self.ch, True, min_val=mn, max_val=mx, stepsize=step)
        except Exception: pass

    @safe_callback
    def _on_relock_changed(self, *_):
        if self._updating: return
        if not self.relock_on.isChecked():
            self.dev.set_relock(self.ch, False); return
        vmin, vmax = self._get_range()
        step = relock_stepsize(self.relock_rate.value(), vmin, vmax)
        self.dev.set_relock(self.ch, True, input_sel=self.relock_input.currentData(), stepsize=step)

    @safe_callback
    def _on_hold_changed(self, *_):
        if self._updating: return
        self.dev.set_hold_source(self.ch, HOLD_VALUES[self.hold_combo.currentIndex()])
        self.dev.set_digital_delay(self.ch, falling=delay_us_to_cycles(self.hold_fall.value()),
                                    rising=delay_us_to_cycles(self.hold_rise.value()))

    def update_readback(self, dacin, railed, relock_hold, dac_direct):
        vmin, vmax = self._get_range()
        if self.servo_btn.isChecked():
            v = dac24_to_volts(dacin, vmin, vmax)
            parts = []
            if railed[0]: parts.append('RAIL-')
            if railed[1]: parts.append('RAIL+')
            if relock_hold: parts.append('HOLD')
            s = ' '.join(parts) if parts else 'OK'
            self.readback.setText(f'Servo: {v:+.4f} V  [{s}]')
        else:
            v = dac24_to_volts(dac_direct, vmin, vmax)
            self.readback.setText(f'Direct: {v:+.4f} V')

    @staticmethod
    def _iir_get(g):
        w = g._w
        d = {'on': g.isChecked(), 'type': w['combo'].currentIndex(),
             'freq': w['freq'].value(), 'gain': w['gain'].value(),
             'glimit': w['glimit'].value()}
        if 'q' in w:
            d['q'] = w['q'].value()
        return d

    @staticmethod
    def _iir_set(g, d):
        w = g._w
        g.setChecked(d.get('on', g.isChecked()))
        w['combo'].setCurrentIndex(d.get('type', w['combo'].currentIndex()))
        w['freq'].setValue(d.get('freq', w['freq'].value()))
        w['gain'].setValue(d.get('gain', w['gain'].value()))
        w['glimit'].setValue(d.get('glimit', w['glimit'].value()))
        if 'q' in w and 'q' in d:
            w['q'].setValue(d['q'])

    def get_settings(self):
        s = {
            'range': self.range_combo.currentIndex(),
            'quick_sweep': self.quick_sweep.isChecked(),
            'qs_ampl': self.qs_ampl.value(), 'qs_freq': self.qs_freq.value(),
            'limit_min': self.limit_min.value(), 'limit_max': self.limit_max.value(),
            'servo': self.servo_btn.isChecked(),
            'sign': self.sign_combo.currentIndex(),
            'input': self.input_combo.currentIndex(),
            'offset': self.offset_spin.value(),
            'iir0': self._iir_get(self.iir0_group),
            'iir1': self._iir_get(self.iir1_group),
            'sweep_on': self.sweep_on.isChecked(),
            'sweep_center': self.sweep_center.value(),
            'sweep_ampl': self.sweep_ampl.value(),
            'sweep_freq': self.sweep_freq.value(),
            'relock_on': self.relock_on.isChecked(),
            'relock_input': self.relock_input.currentIndex(),
            'relock_rate': self.relock_rate.value(),
            'hold': self.hold_combo.currentIndex(),
            'hold_fall': self.hold_fall.value(),
            'hold_rise': self.hold_rise.value(),
            'center_railed': self.center_railed.isChecked(),
        }
        if not self.is_slow:
            s['iir2'] = self._iir_get(self.iir2_group)
            s['iir3'] = self._iir_get(self.iir3_group)
        return s

    def apply_settings(self, s):
        self._updating = True
        try:
            self.range_combo.setCurrentIndex(s.get('range', self.range_combo.currentIndex()))
            self.quick_sweep.setChecked(s.get('quick_sweep', False))
            self.qs_ampl.setValue(s.get('qs_ampl', self.qs_ampl.value()))
            self.qs_freq.setValue(s.get('qs_freq', self.qs_freq.value()))
            self.limit_min.setValue(s.get('limit_min', self.limit_min.value()))
            self.limit_max.setValue(s.get('limit_max', self.limit_max.value()))
            self.servo_btn.setChecked(s.get('servo', False))
            self.sign_combo.setCurrentIndex(s.get('sign', 0))
            self.input_combo.setCurrentIndex(s.get('input', self.input_combo.currentIndex()))
            self.offset_spin.setValue(s.get('offset', self.offset_spin.value()))
            self._iir_set(self.iir0_group, s.get('iir0', {}))
            self._iir_set(self.iir1_group, s.get('iir1', {}))
            if not self.is_slow:
                self._iir_set(self.iir2_group, s.get('iir2', {}))
                self._iir_set(self.iir3_group, s.get('iir3', {}))
            self.sweep_on.setChecked(s.get('sweep_on', False))
            self.sweep_center.setValue(s.get('sweep_center', self.sweep_center.value()))
            self.sweep_ampl.setValue(s.get('sweep_ampl', self.sweep_ampl.value()))
            self.sweep_freq.setValue(s.get('sweep_freq', self.sweep_freq.value()))
            self.relock_on.setChecked(s.get('relock_on', False))
            self.relock_input.setCurrentIndex(s.get('relock_input', self.relock_input.currentIndex()))
            self.relock_rate.setValue(s.get('relock_rate', self.relock_rate.value()))
            self.hold_combo.setCurrentIndex(s.get('hold', self.hold_combo.currentIndex()))
            self.hold_fall.setValue(s.get('hold_fall', self.hold_fall.value()))
            self.hold_rise.setValue(s.get('hold_rise', self.hold_rise.value()))
            self.center_railed.setChecked(s.get('center_railed', False))
        finally:
            self._updating = False
        # Push restored values to hardware (servo enabled last; quick-sweep,
        # if it was the active mode, overrides afterwards).
        self._on_range_changed()
        self._on_input_changed()
        self._on_iir_changed()
        self._on_limits_changed()
        self._on_hold_changed()
        self._on_sweep_changed()
        self._on_relock_changed()
        self._on_servo_toggled(self.servo_btn.isChecked())
        if self.quick_sweep.isChecked():
            self._on_quick_sweep()


###############################################################################
# LockIn panel
###############################################################################

class LockInPanel(QGroupBox):
    def __init__(self, dev, parent=None):
        super().__init__('LOCKIN', parent)
        self.dev = dev
        self._updating = False
        layout = QVBoxLayout(self)
        row = QHBoxLayout()
        row.addWidget(QLabel('Input:')); self.input_combo = QComboBox()
        self.input_combo.addItems(['AIN0', 'AIN1']); row.addWidget(self.input_combo)
        layout.addLayout(row)
        row = QHBoxLayout()
        row.addWidget(QLabel('Freq:'))
        self.freq_spin = QDoubleSpinBox(); self.freq_spin.setRange(0, 10e6); self.freq_spin.setSuffix(' Hz')
        row.addWidget(self.freq_spin)
        row.addWidget(QLabel('Phase:'))
        self.phase_spin = QDoubleSpinBox(); self.phase_spin.setRange(0, 360); self.phase_spin.setSuffix(' deg')
        row.addWidget(self.phase_spin)
        layout.addLayout(row)
        row = QHBoxLayout()
        self.pre_on = QCheckBox('Pre LP'); row.addWidget(self.pre_on)
        self.pre_freq = QDoubleSpinBox(); self.pre_freq.setRange(0.01, 10e6); self.pre_freq.setValue(1000); self.pre_freq.setSuffix(' Hz')
        row.addWidget(self.pre_freq)
        self.pre_q = QDoubleSpinBox(); self.pre_q.setRange(0.01, 100); self.pre_q.setValue(0.707)
        row.addWidget(QLabel('Q:')); row.addWidget(self.pre_q)
        layout.addLayout(row)
        row = QHBoxLayout()
        self.post_on = QCheckBox('Post LP'); row.addWidget(self.post_on)
        self.post_freq = QDoubleSpinBox(); self.post_freq.setRange(0.01, 10e6); self.post_freq.setValue(1000); self.post_freq.setSuffix(' Hz')
        row.addWidget(self.post_freq)
        self.post_q = QDoubleSpinBox(); self.post_q.setRange(0.01, 100); self.post_q.setValue(0.707)
        row.addWidget(QLabel('Q:')); row.addWidget(self.post_q)
        layout.addLayout(row)
        self.readback = QLabel('LOCKIN: ---'); self.readback.setFont(QFont('monospace', 9))
        layout.addWidget(self.readback)
        for w in [self.input_combo, self.freq_spin, self.phase_spin, self.pre_on,
                  self.pre_freq, self.pre_q, self.post_on, self.post_freq, self.post_q]:
            if hasattr(w, 'toggled'): w.toggled.connect(self._on_changed)
            elif hasattr(w, 'valueChanged'): w.valueChanged.connect(self._on_changed)
            elif hasattr(w, 'currentIndexChanged'): w.currentIndexChanged.connect(self._on_changed)

    @safe_callback
    def _on_changed(self, *_):
        if self._updating: return
        self.dev.set_lockin_input(self.input_combo.currentIndex())
        pinc = freq_to_lockin_pinc(self.freq_spin.value())
        poff = deg_to_lockin_poff(self.phase_spin.value())
        self.dev.set_lockin_nco(pinc, poff)
        c = iir2_coeffs('lowpass', self.pre_freq.value(), Q=self.pre_q.value(),
                         a0_shift=32, update_every=26, fs=DSP_CLK_HZ)
        self.dev.set_lockin_iir0(self.pre_on.isChecked(), **c)
        c = iir2_coeffs('lowpass', self.post_freq.value(), Q=self.post_q.value(),
                         a0_shift=32, update_every=26, fs=DSP_CLK_HZ)
        self.dev.set_lockin_iir1(self.post_on.isChecked(), **c)

    def update_readback(self, out, lo):
        self.readback.setText(f'Out: {out:+8d}  LO: {lo:+8d}')

    def get_settings(self):
        return {'input': self.input_combo.currentIndex(), 'freq': self.freq_spin.value(),
                'phase': self.phase_spin.value(), 'pre_on': self.pre_on.isChecked(),
                'pre_freq': self.pre_freq.value(), 'pre_q': self.pre_q.value(),
                'post_on': self.post_on.isChecked(), 'post_freq': self.post_freq.value(),
                'post_q': self.post_q.value()}

    def apply_settings(self, s):
        self._updating = True
        try:
            self.input_combo.setCurrentIndex(s.get('input', self.input_combo.currentIndex()))
            self.freq_spin.setValue(s.get('freq', self.freq_spin.value()))
            self.phase_spin.setValue(s.get('phase', self.phase_spin.value()))
            self.pre_on.setChecked(s.get('pre_on', False))
            self.pre_freq.setValue(s.get('pre_freq', self.pre_freq.value()))
            self.pre_q.setValue(s.get('pre_q', self.pre_q.value()))
            self.post_on.setChecked(s.get('post_on', False))
            self.post_freq.setValue(s.get('post_freq', self.post_freq.value()))
            self.post_q.setValue(s.get('post_q', self.post_q.value()))
        finally:
            self._updating = False
        self._on_changed()


###############################################################################
# PhaseDetector panel
###############################################################################

class PhaseDetPanel(QGroupBox):
    def __init__(self, dev, parent=None):
        super().__init__('PHASEDET', parent)
        self.dev = dev; self._updating = False
        layout = QVBoxLayout(self)
        row = QHBoxLayout()
        row.addWidget(QLabel('Input:')); self.input_combo = QComboBox()
        self.input_combo.addItems(['AIN0', 'AIN1']); row.addWidget(self.input_combo)
        self.ext_clk = QCheckBox('Ext 10 MHz'); row.addWidget(self.ext_clk)
        layout.addLayout(row)
        row = QHBoxLayout()
        row.addWidget(QLabel('Freq:'))
        self.freq_spin = QDoubleSpinBox(); self.freq_spin.setRange(10, 50e6); self.freq_spin.setValue(10e6)
        self.freq_spin.setSuffix(' Hz'); self.freq_spin.setDecimals(0); row.addWidget(self.freq_spin)
        layout.addLayout(row)
        row = QHBoxLayout()
        self.lp_on = QCheckBox('LP'); row.addWidget(self.lp_on)
        self.lp_freq = QDoubleSpinBox(); self.lp_freq.setRange(0.01, 10e6); self.lp_freq.setValue(1000); self.lp_freq.setSuffix(' Hz')
        row.addWidget(QLabel('F:')); row.addWidget(self.lp_freq)
        self.lp_gain = QDoubleSpinBox(); self.lp_gain.setRange(-60, 60); self.lp_gain.setSuffix(' dB')
        row.addWidget(QLabel('G:')); row.addWidget(self.lp_gain)
        layout.addLayout(row)
        self.readback = QLabel('PHASEDET: ---'); self.readback.setFont(QFont('monospace', 9))
        layout.addWidget(self.readback)
        for w in [self.input_combo, self.ext_clk, self.freq_spin, self.lp_on, self.lp_freq, self.lp_gain]:
            if hasattr(w, 'toggled'): w.toggled.connect(self._on_changed)
            elif hasattr(w, 'valueChanged'): w.valueChanged.connect(self._on_changed)
            elif hasattr(w, 'currentIndexChanged'): w.currentIndexChanged.connect(self._on_changed)

    @safe_callback
    def _on_changed(self, *_):
        if self._updating: return
        self.dev.set_phasedet_input(self.input_combo.currentIndex())
        self.dev.set_phasedet(use_ext_clk=self.ext_clk.isChecked(),
                              pinc=freq_to_phasedet_pinc(self.freq_spin.value()))
        c = iir1_coeffs('lowpass', self.lp_freq.value(), gain_db=self.lp_gain.value(),
                         a0_shift=26, fs=DSP_CLK_HZ)
        self.dev.set_phasedet_lp(self.lp_on.isChecked(), a1=c['a1'], b0=c['b0'])

    def update_readback(self, val):
        self.readback.setText(f'Phase: {val:+10d}')

    def get_settings(self):
        return {'input': self.input_combo.currentIndex(), 'ext_clk': self.ext_clk.isChecked(),
                'freq': self.freq_spin.value(), 'lp_on': self.lp_on.isChecked(),
                'lp_freq': self.lp_freq.value(), 'lp_gain': self.lp_gain.value()}

    def apply_settings(self, s):
        self._updating = True
        try:
            self.input_combo.setCurrentIndex(s.get('input', self.input_combo.currentIndex()))
            self.ext_clk.setChecked(s.get('ext_clk', False))
            self.freq_spin.setValue(s.get('freq', self.freq_spin.value()))
            self.lp_on.setChecked(s.get('lp_on', False))
            self.lp_freq.setValue(s.get('lp_freq', self.lp_freq.value()))
            self.lp_gain.setValue(s.get('lp_gain', self.lp_gain.value()))
        finally:
            self._updating = False
        self._on_changed()


class DoutPanel(QGroupBox):
    """Per-pin DOUT source routing: relock-hold status (default) or a channel's
    sweep sync (high during the rising min->max half of the triangle)."""
    SOURCES = ['Status', 'Sync ch0', 'Sync ch1', 'Sync ch2']

    def __init__(self, dev, parent=None):
        super().__init__('DOUT', parent)
        self.dev = dev
        self._updating = False
        layout = QVBoxLayout(self)
        self.combos = []
        for pin in range(3):
            row = QHBoxLayout()
            row.addWidget(QLabel(f'DOUT[{pin}]:'))
            combo = QComboBox()
            combo.addItems(self.SOURCES)
            combo.currentIndexChanged.connect(self._on_changed)
            row.addWidget(combo)
            row.addStretch()
            layout.addLayout(row)
            self.combos.append(combo)

    @safe_callback
    def _on_changed(self, *_):
        if self._updating:
            return
        for pin, combo in enumerate(self.combos):
            idx = combo.currentIndex()
            # combo index: 0 -> status, 1/2/3 -> sweep sync ch0/1/2
            self.dev.set_dout_source(pin, 'status' if idx == 0 else idx - 1)

    def get_settings(self):
        return {'src': [c.currentIndex() for c in self.combos]}

    def apply_settings(self, s):
        self._updating = True
        try:
            for combo, idx in zip(self.combos, s.get('src', [])):
                combo.setCurrentIndex(idx)
        finally:
            self._updating = False
        self._on_changed()


class StreamPanel(QGroupBox):
    """UDP data-stream destination (regs 0x030-0x034).

    The FPGA frames stream packets straight to this MAC/IP with no ARP, so it
    must be the host running the GUI. Defaults are auto-detected; the user can
    override and persist them with the GUI settings (File > Save settings).
    """

    def __init__(self, dev, fpga_ip, parent=None):
        super().__init__('Data stream dest', parent)
        self.dev = dev
        self.fpga_ip = fpga_ip
        layout = QVBoxLayout(self)

        row = QHBoxLayout()
        row.addWidget(QLabel('Host IP:'))
        self.ip_edit = QLineEdit()
        row.addWidget(self.ip_edit)
        layout.addLayout(row)

        row = QHBoxLayout()
        row.addWidget(QLabel('Host MAC:'))
        self.mac_edit = QLineEdit()
        row.addWidget(self.mac_edit)
        layout.addLayout(row)

        row = QHBoxLayout()
        self.detect_btn = QPushButton('Auto-detect')
        self.detect_btn.clicked.connect(self._on_detect)
        row.addWidget(self.detect_btn)
        self.apply_btn = QPushButton('Apply')
        self.apply_btn.clicked.connect(self._on_apply)
        row.addWidget(self.apply_btn)
        layout.addLayout(row)

        self.status = QLabel(''); self.status.setFont(QFont('monospace', 9))
        layout.addWidget(self.status)

        # Seed the fields with auto-detected values (does not touch hardware yet).
        self._fill_detected()

    def _fill_detected(self):
        ip, mac = detect_stream_dest(self.fpga_ip)
        self.ip_edit.setText('.'.join(str(x) for x in ip))
        self.mac_edit.setText(mac_int_to_str(mac))

    @safe_callback
    def _on_detect(self, *_):
        self._fill_detected()
        self._apply_to_hw()

    @safe_callback
    def _on_apply(self, *_):
        self._apply_to_hw()

    def _apply_to_hw(self):
        """Parse the fields and program the stream destination registers."""
        try:
            ip = ip_str_to_tuple(self.ip_edit.text())
            mac = mac_str_to_int(self.mac_edit.text())
            src_ip = ip_str_to_tuple(self.fpga_ip)
        except ValueError as e:
            self.status.setText(f'Invalid: {e}')
            return
        self.dev.set_stream_dest(mac=mac, ip=ip, port=STREAM_PORT, src_ip=src_ip)
        self.status.setText(
            f'-> {".".join(map(str, ip))}  {mac_int_to_str(mac)}  :{STREAM_PORT}')

    def get_settings(self):
        return {'ip': self.ip_edit.text(), 'mac': self.mac_edit.text()}

    def apply_settings(self, s):
        if 'ip' in s:
            self.ip_edit.setText(s['ip'])
        if 'mac' in s:
            self.mac_edit.setText(s['mac'])
        self._apply_to_hw()


###############################################################################
# Main window
###############################################################################

class MainWindow(QMainWindow):
    def __init__(self, dev):
        super().__init__()
        self.dev = dev
        self.setWindowTitle('SuperLaserLand Ethernet')

        # Menu bar
        menu = self.menuBar()
        file_menu = menu.addMenu('File')
        file_menu.addAction('Save settings to flash', self._save_config)
        file_menu.addAction('Load settings from flash', self._load_config)
        file_menu.addSeparator()
        file_menu.addAction('Reset All', self._reset_all)

        # Central widget with splitter
        splitter = QSplitter(Qt.Horizontal)
        self.setCentralWidget(splitter)

        # Left: Inputs
        left = QWidget()
        ll = QVBoxLayout(left)
        self.ain0 = InputPanel(dev, 0)
        self.ain1 = InputPanel(dev, 1)
        self.lockin = LockInPanel(dev)
        self.phasedet = PhaseDetPanel(dev)
        ll.addWidget(self.ain0); ll.addWidget(self.ain1)
        ll.addWidget(self.lockin); ll.addWidget(self.phasedet)
        ll.addStretch()
        left_scroll = QScrollArea(); left_scroll.setWidget(left)
        left_scroll.setWidgetResizable(True); left_scroll.setMinimumWidth(380)

        # Middle: Outputs
        mid = QWidget()
        ml = QVBoxLayout(mid)
        self.aout0 = OutputPanel(dev, 0)
        self.aout1 = OutputPanel(dev, 1)
        self.aout2 = OutputPanel(dev, 2)
        self.dout = DoutPanel(dev)
        self.stream_panel = StreamPanel(dev, dev.dev.dest[0])
        ml.addWidget(self.aout0); ml.addWidget(self.aout1); ml.addWidget(self.aout2)
        ml.addWidget(self.dout)
        ml.addWidget(self.stream_panel)
        ml.addStretch()
        mid_scroll = QScrollArea(); mid_scroll.setWidget(mid)
        mid_scroll.setWidgetResizable(True); mid_scroll.setMinimumWidth(480)

        # Right: Scope
        self.scope = ScopePlot()
        self.scope.set_panels(self.ain0, self.ain1,
                              self.aout0, self.aout1, self.aout2)

        splitter.addWidget(left_scroll)
        splitter.addWidget(mid_scroll)
        splitter.addWidget(self.scope)
        splitter.setSizes([380, 480, 500])

        # Status bar
        self.statusBar().showMessage('Connecting...')

        # Stream receiver
        self.stream = StreamReceiver()
        self.stream.new_samples.connect(self.scope.add_samples)
        self.stream.start()

        # Monitor timer (register polling for readback)
        self.timer = QTimer()
        self.timer.timeout.connect(self._poll)
        self.timer.start(MONITOR_INTERVAL_MS)

        # Program the stream destination with the panel's auto-detected default.
        # The FPGA frames the UDP data stream directly to this MAC/IP (no ARP),
        # so it must point at THIS host. A saved value from flash (if any) then
        # overrides it in _autoload_settings() below.
        try:
            self.stream_panel._apply_to_hw()
        except Exception as e:
            print(f'Stream config error: {e}')
        # Put every control in a defined safe state, then overlay the saved GUI
        # settings from flash (if any). Blank flash -> safe defaults are kept.
        self._reset_all()
        self._autoload_settings()
        self._update_status()

    def _autoload_settings(self):
        """Load saved GUI settings from flash on connect (no-op if blank)."""
        try:
            loaded = self._load_settings_flash()
        except Exception as e:
            print(f'Settings auto-load error: {e}')
            return
        print('Loaded GUI settings from flash' if loaded
              else 'No saved GUI settings in flash; using defaults')

    def _update_status(self):
        try:
            st = self.dev.status()
            self.statusBar().showMessage(
                f'FW: 0x{st["firmware_id"]:04X}  PLL: {"OK" if st["pll_locked"] else "UNLOCKED"}  '
                f'RX: {st["rx_packets"]}  TX: {st["tx_packets"]}')
        except Exception as e:
            self.statusBar().showMessage(f'Error: {e}')

    def _poll(self):
        try:
            snap = self.dev.snapshot()
            dac_regs = self.dev.read_multi([0x100, 0x101, 0x102])
            dac_direct = [_from_signed(v, 32) for v in dac_regs]

            self.ain0.update_readback(snap['adc_raw'][0], snap['adc_filt'][0])
            self.ain1.update_readback(snap['adc_raw'][1], snap['adc_filt'][1])
            for i, panel in enumerate([self.aout0, self.aout1, self.aout2]):
                ch = snap[f'ch{i}']
                panel.update_readback(ch['dacin'], ch['railed'], ch['relock_hold'], dac_direct[i])
            self.lockin.update_readback(snap['lockin']['out'], snap['lockin']['lo'])
            self.phasedet.update_readback(snap['phasedet'])
        except Exception:
            pass
        # Flush scope plot at monitor timer rate (5 Hz)
        self.scope.flush()

    def _reset_all(self):
        try:
            for ch in range(3):
                self.dev.servo_on(ch, False)
                self.dev.set_sweep(ch, False)
                self.dev.set_relock(ch, False)
                self.dev.set_dac(ch, 0)
                self.dev.set_limits(ch, -RAW16_FULLSCALE, RAW16_FULLSCALE)
                self.dev.set_iir0(ch, False)
                self.dev.set_iir1(ch, False, a1=0, b0=0, b1=0)
                if ch < 2:
                    self.dev.set_iir2(ch, False, a1=0, b0=0, b1=0)
                    self.dev.set_iir3(ch, False, a1=0, b0=0, b1=0)
                self.dev.set_lo_shift(ch, 31)
                self.dev.set_transfer_amplitude(ch, 31)
            self.dev.set_ramp(False)
            self.dev.set_input_gain(0, 0)
            self.dev.set_output_gain(0, 0)
            self.dev.set_adc_iir(0, False)
            self.dev.set_adc_iir(1, False)
            self.dev.set_lockin_nco(0, 0)
            self.dev.set_lockin_iir0(False)
            self.dev.set_lockin_iir1(False)
            self.dev.set_transfer_freq(0)
            for pin in range(3):
                self.dev.set_dout_source(pin, 'status')
        except Exception as e:
            print(f'Reset error: {e}')

    def get_all_settings(self):
        """Aggregate every panel's high-level settings into one dict."""
        return {
            'version': 1,
            'ain': [self.ain0.get_settings(), self.ain1.get_settings()],
            'aout': [self.aout0.get_settings(), self.aout1.get_settings(),
                     self.aout2.get_settings()],
            'lockin': self.lockin.get_settings(),
            'phasedet': self.phasedet.get_settings(),
            'dout': self.dout.get_settings(),
            'stream': self.stream_panel.get_settings(),
        }

    def apply_all_settings(self, d):
        """Restore every panel's widgets from a settings dict (drives hardware)."""
        for p, s in zip([self.ain0, self.ain1], d.get('ain', [])):
            try: p.apply_settings(s)
            except Exception as e: print(f'apply AIN error: {e}')
        for p, s in zip([self.aout0, self.aout1, self.aout2], d.get('aout', [])):
            try: p.apply_settings(s)
            except Exception as e: print(f'apply AOUT error: {e}')
        if 'lockin' in d:
            try: self.lockin.apply_settings(d['lockin'])
            except Exception as e: print(f'apply LockIn error: {e}')
        if 'phasedet' in d:
            try: self.phasedet.apply_settings(d['phasedet'])
            except Exception as e: print(f'apply PhaseDet error: {e}')
        if 'dout' in d:
            try: self.dout.apply_settings(d['dout'])
            except Exception as e: print(f'apply DOUT error: {e}')
        if 'stream' in d:
            try: self.stream_panel.apply_settings(d['stream'])
            except Exception as e: print(f'apply Stream error: {e}')

    def _load_settings_flash(self):
        """Read GUI settings blob from flash and apply. Returns True if found."""
        raw = self.dev.flash_load_blob(self.dev.GUI_SETTINGS_FLASH_ADDR)
        if raw is None:
            return False
        self.apply_all_settings(json.loads(raw.decode('utf-8')))
        return True

    def _save_config(self):
        """Save current GUI settings to flash (File > Save settings to flash)."""
        try:
            data = json.dumps(self.get_all_settings()).encode('utf-8')
            n = self.dev.flash_save_blob(self.dev.GUI_SETTINGS_FLASH_ADDR, data)
            QMessageBox.information(self, 'Saved',
                                    f'Saved GUI settings to flash ({n} bytes)')
        except Exception as e:
            QMessageBox.critical(self, 'Save error', str(e))

    def _load_config(self):
        """Load GUI settings from flash (File > Load settings from flash)."""
        try:
            if self._load_settings_flash():
                QMessageBox.information(self, 'Loaded', 'Loaded GUI settings from flash')
            else:
                QMessageBox.information(self, 'Load', 'No saved GUI settings in flash')
        except Exception as e:
            QMessageBox.critical(self, 'Load error', str(e))

    def closeEvent(self, event):
        self.timer.stop()
        self.stream.stop()
        event.accept()


###############################################################################
# Main entry point
###############################################################################

def main():
    app = QApplication(sys.argv)
    try:
        dev = ServoDevice()
        dev.firmware_id()
    except Exception as e:
        QMessageBox.critical(None, 'Connection Error',
                             f'Cannot connect to FPGA at 192.168.7.140:803\n\n{e}')
        sys.exit(1)

    win = MainWindow(dev)
    win.resize(1400, 900)
    win.show()
    sys.exit(app.exec_())


if __name__ == '__main__':
    main()
