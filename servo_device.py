#!/usr/bin/env python3
"""Device class for SuperLaserLand Ethernet (Bare build).

Provides a clean API over the direct lbus register map. Uses lbus_access
for LASS UDP transport to the Badger Ethernet stack.

Register map:
    0x000-0x021  Test/status
    0x100-0x122  DAC, SPI, diagnostics
    0x200-0x212  ADC, input PGA, IIR filter
    0x300-0x33F  Servo channel 0
    0x400-0x43F  Servo channel 1
    0x500-0x53F  Servo channel 2
    0x600-0x625  LockIn demodulator
    0x700-0x714  PhaseDetector
"""

import sys
import os
import math
import time
import struct
import zlib

# Import lbus_access from Bedrock
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'Bedrock', 'badger'))
from lbus_access import lbus_access

# Clock frequencies
CLK1_HZ = 100.0e6          # System clock (ADC/DAC hardware, TransferFunction)
DSP_CLK_HZ = 25.0e6        # DSP clock (IIR filters, LockIn, sweep)
DSP_CLK_T = 1.0 / DSP_CLK_HZ

# Output voltage ranges (index matches AD8251 gain setting 0-3)
OUTPUT_RANGES = [
    (-1.0, 1.0),    # gain 0: +/-1V
    (-2.0, 2.0),    # gain 1: +/-2V
    (-4.0, 4.0),    # gain 2: +/-4V
    (-8.0, 8.0),    # gain 3: +/-8V
]

# Input voltage ranges (AD8251 gain setting, inverted: register=3-gain)
INPUT_RANGES = [
    (-0.5, 0.5),    # gain 3 (register 0): +/-0.5V
    (-1.0, 1.0),    # gain 2 (register 1): +/-1V
    (-2.0, 2.0),    # gain 1 (register 2): +/-2V
    (-4.0, 4.0),    # gain 0 (register 3): +/-4V
]

# AD5791 precision DAC range (ch2)
AD5791_RANGE = (0.0, 10.0)   # unipolar 0-10V

# Input mux sources (for servo channel input_mux and relock input_select)
INPUT_ADC0 = 0
INPUT_ADC1 = 1
INPUT_ADCDIFF = 2
INPUT_LOCKIN = 3
INPUT_PHASEDET = 4
INPUT_DAC0 = 5
INPUT_DAC1 = 6
INPUT_DAC2 = 7

# Hold sources (for DigitalDelay hold_source)
HOLD_OFF = 0
HOLD_RELOCK0 = 0x01
HOLD_RELOCK1 = 0x03
HOLD_RELOCK2 = 0x05
HOLD_DIN0 = 0x07
HOLD_DIN1 = 0x09
HOLD_DIN2 = 0x0B
HOLD_DIN0_INV = 0x0D
HOLD_DIN1_INV = 0x0F
HOLD_DIN2_INV = 0x11


def _to_signed(val, bits):
    """Convert Python int to unsigned register value (2's complement)."""
    mask = (1 << bits) - 1
    return int(val) & mask


def _from_signed(val, bits):
    """Convert unsigned register readback to signed Python int."""
    val = int(val)
    if val >= (1 << (bits - 1)):
        val -= (1 << bits)
    return val


def _split_35(val):
    """Split 35-bit signed value into (lo32, hi3) for register writes."""
    u = int(val) & 0x7FFFFFFFF
    return (u & 0xFFFFFFFF, (u >> 32) & 0x7)


def _join_35(lo, hi):
    """Join (lo32, hi3) register values into 35-bit signed Python int."""
    u = (int(hi) & 0x7) << 32 | (int(lo) & 0xFFFFFFFF)
    if u >= (1 << 34):
        u -= (1 << 35)
    return u


###############################################################################
# IIR filter coefficient calculator
###############################################################################

def iir1_coeffs(filter_type, freq_hz, gain_db=0.0, gain_limit_db=81.0,
                a0_shift=26, fs=DSP_CLK_HZ):
    """Compute 1st-order IIR coefficients from filter parameters.

    Args:
        filter_type: 'lowpass', 'highpass', 'allpass', 'p', 'i', 'pi', 'pd'
        freq_hz: corner frequency in Hz
        gain_db: gain in dB (0 dB = unity)
        gain_limit_db: gain limit for PI/PD (81 = infinite)
        a0_shift: fixed-point normalization (26 for servo IIR, 26 for ADC IIR)
        fs: sample rate (25 MHz for DSP filters)

    Returns:
        dict with 'a1', 'b0', 'b1' as integer coefficients
    """
    a0 = 1 << a0_shift
    pft = math.pi * freq_hz / fs
    K = 10.0 ** (gain_db / 20.0)
    g = 10.0 ** (gain_limit_db / 20.0)
    t = filter_type.lower().replace(' ', '')

    if t == 'lowpass':
        d = 1.0 + pft
        a1 = a0 * (1.0 - pft) / d
        b0 = a0 * K * pft / d
        b1 = b0
    elif t == 'highpass':
        d = 1.0 + pft
        a1 = a0 * (1.0 - pft) / d
        b0 = a0 * K / d
        b1 = a0 * (-K) / d
    elif t == 'allpass':
        d = 1.0 + pft
        a1 = a0 * (1.0 - pft) / d
        b0 = a0 * K * (1.0 - pft) / d
        b1 = a0 * (-K)
    elif t == 'p':
        a1 = 0
        b0 = a0 * K
        b1 = 0
    elif t == 'i':
        a1 = a0
        b0 = a0 * K * pft
        b1 = b0
    elif t == 'pi':
        if gain_limit_db >= 80:
            a1 = a0
            b0 = a0 * K * (1.0 + pft)
            b1 = a0 * (-K) * (1.0 - pft)
        else:
            d = 1.0 + pft / g
            a1 = a0 * (1.0 - pft / g) / d
            b0 = a0 * K * (1.0 + pft) / d
            b1 = a0 * (-K) * (1.0 - pft) / d
    elif t == 'pd':
        d = 1.0 / g + pft
        a1 = a0 * (1.0 / g - pft) / d
        b0 = a0 * K * (1.0 + pft) / d
        b1 = a0 * (-K) * (1.0 - pft) / d
    else:
        raise ValueError(f"Unknown 1st-order filter type: {filter_type}")

    return {'a1': round(a1), 'b0': round(b0), 'b1': round(b1)}


def iir2_coeffs(filter_type, freq_hz, Q=0.707, gain_db=0.0, gain_limit_db=81.0,
                a0_shift=26, update_every=1, fs=DSP_CLK_HZ):
    """Compute 2nd-order IIR coefficients from filter parameters.

    Args:
        filter_type: 'lowpass', 'highpass', 'notch', 'p', 'iho'
        freq_hz: corner frequency in Hz
        Q: quality factor (only for 2nd-order types)
        gain_db: gain in dB
        gain_limit_db: gain limit for I/HO mode
        a0_shift: fixed-point normalization
        update_every: multiplexed filter update interval in clocks
                      (27 for servo IIR0, 26 for LockIn IIR)
        fs: sample rate (25 MHz for DSP filters)

    Returns:
        dict with 'a1', 'a2', 'b0', 'b1', 'b2' as integer coefficients
    """
    a0 = 1 << a0_shift
    pft = math.pi * freq_hz * update_every / fs
    pft2 = pft * pft
    K = 10.0 ** (gain_db / 20.0)
    g = 10.0 ** (gain_limit_db / 20.0)
    t = filter_type.lower().replace(' ', '').replace('/', '')

    denom = 1.0 + pft / Q + pft2

    if t == 'lowpass':
        a1 = a0 * 2.0 * (1.0 - pft2) / denom
        a2 = a0 * (-1.0) * (1.0 - pft / Q + pft2) / denom
        b0 = a0 * K * pft2 / denom
        b1 = a0 * 2.0 * K * pft2 / denom
        b2 = b0
    elif t == 'highpass':
        a1 = a0 * 2.0 * (1.0 - pft2) / denom
        a2 = a0 * (-1.0) * (1.0 - pft / Q + pft2) / denom
        b0 = a0 * K / denom
        b1 = a0 * (-2.0 * K) / denom
        b2 = b0
    elif t == 'notch':
        a1 = a0 * 2.0 * (1.0 - pft2) / denom
        a2 = a0 * (-1.0) * (1.0 - pft / Q + pft2) / denom
        b0 = a0 * K * (1.0 + pft2) / denom
        b1 = a0 * (-2.0 * K) * (1.0 - pft2) / denom
        b2 = b0
    elif t == 'p':
        a1 = 0; a2 = 0; b0 = a0 * K; b1 = 0; b2 = 0
    elif t == 'iho':
        d_a = 1.0 + pft * g
        a1 = a0 * 2.0 / d_a
        a2 = a0 * (-1.0) * (1.0 - pft * g) / d_a
        d_b = 1.0 / g + pft
        b0 = a0 * K * denom / d_b
        b1 = a0 * (-2.0 * K) * (1.0 - pft2) / d_b
        b2 = a0 * K * (1.0 - pft / Q + pft2) / d_b
    else:
        raise ValueError(f"Unknown 2nd-order filter type: {filter_type}")

    return {'a1': round(a1), 'a2': round(a2),
            'b0': round(b0), 'b1': round(b1), 'b2': round(b2)}


###############################################################################
# Physical unit conversions
###############################################################################

def volts_to_raw16(voltage, vmin, vmax):
    """Convert voltage to 16-bit signed raw value for DAC limits/sweep."""
    return int(round(-32768 + (65535.0 / (vmax - vmin)) * (voltage - vmin)))


def raw16_to_volts(raw, vmin, vmax):
    """Convert 16-bit signed raw value to voltage.

    Offset-binary convention: maps the code range [-32768, +32767] onto
    [vmin, vmax], so code 0 is the center of the range. Use this for DAC
    limit/sweep codes (the inverse of volts_to_raw16), NOT for ADC samples.
    """
    return (raw + 32768.0) * (vmax - vmin) / 65535.0 + vmin


def adc16_to_volts(raw, vmin, vmax):
    """Convert a 16-bit signed (two's-complement) ADC sample to voltage.

    Zero-centered convention: code 0 is 0 V and full scale is
    +/-(vmax - vmin)/2, with 1 LSB = (vmax - vmin)/2**16. This is the
    correct mapping for a bipolar ADC sample, where (unlike raw16_to_volts)
    no vmin offset is applied. The two agree only when the range is
    symmetric (vmin == -vmax).
    """
    return raw * (vmax - vmin) / (1 << 16)


def adc24_to_volts(raw, vmin, vmax):
    """Convert a 24-bit signed ADC sample to voltage (zero-centered).

    Same convention as adc16_to_volts, for the post-IIR filtered ADC value:
    code 0 is 0 V, 1 LSB = (vmax - vmin)/2**24.
    """
    return raw * (vmax - vmin) / (1 << 24)


def volts_to_dac24(voltage, vmin, vmax):
    """Convert voltage to 24-bit signed DAC value."""
    scale = (1 << 23) - 1  # 8388607
    frac = (voltage - vmin) / (vmax - vmin)
    return int(round(frac * 2 * scale - scale))


def dac24_to_volts(raw24, vmin, vmax):
    """Convert 24-bit signed DAC value to voltage."""
    scale = (1 << 23) - 1
    frac = (raw24 + scale) / (2.0 * scale)
    return frac * (vmax - vmin) + vmin


def dac16_to_volts(raw16, vmin, vmax):
    """Convert a 16-bit signed DAC value to voltage.

    Same offset-binary mapping as dac24_to_volts but for the top 16 bits of the
    DAC datapath value (what stream_tx packs into a LoggerData slot). Code 0 maps
    to the range midpoint, code +/-(2**15-1) to vmax/vmin.
    """
    scale = (1 << 15) - 1
    frac = (raw16 + scale) / (2.0 * scale)
    return frac * (vmax - vmin) + vmin


def stream_ip_checksum(src_ip, dest_ip):
    """Compute IP header checksum for stream_tx packets.

    Args:
        src_ip: source IP as tuple (e.g. (192, 168, 7, 140))
        dest_ip: destination IP as tuple (e.g. (192, 168, 7, 4))

    Returns:
        16-bit checksum as int
    """
    # Fixed IP header fields (from stream_tx_header.v):
    #   Version/IHL=0x4500, Length=0x009C, ID=0x0000,
    #   Flags/Frag=0x4000, TTL/Proto=0x4011, Checksum=0x0000
    words = [
        0x4500, 0x009C, 0x0000, 0x4000, 0x4011, 0x0000,
        (src_ip[0] << 8) | src_ip[1],
        (src_ip[2] << 8) | src_ip[3],
        (dest_ip[0] << 8) | dest_ip[1],
        (dest_ip[2] << 8) | dest_ip[3],
    ]
    s = sum(words)
    while s > 0xFFFF:
        s = (s & 0xFFFF) + (s >> 16)
    return (~s) & 0xFFFF


def freq_to_lockin_pinc(freq_hz):
    """Convert frequency (Hz) to LockIn NCO phase increment (24-bit).

    LockIn DDS runs at clk_dsp (25 MHz).
    """
    return int(round((1 << 24) * freq_hz / DSP_CLK_HZ))


def lockin_pinc_to_freq(pinc):
    """Convert LockIn NCO phase increment to frequency (Hz)."""
    return pinc * DSP_CLK_HZ / (1 << 24)


def deg_to_lockin_poff(phase_deg):
    """Convert phase (degrees) to LockIn NCO phase offset (24-bit)."""
    return int(round((1 << 24) * (phase_deg / 360.0)))


def freq_to_phasedet_pinc(freq_hz):
    """Convert frequency (Hz) to PhaseDetector phase increment (32-bit).

    PhaseDetector DDS runs at clk1 (100 MHz).
    """
    return int(round((1 << 32) * freq_hz / CLK1_HZ))


def phasedet_pinc_to_freq(pinc):
    """Convert PhaseDetector phase increment to frequency (Hz)."""
    return pinc * CLK1_HZ / (1 << 32)


def freq_to_transfer_pinc(freq_hz):
    """Convert frequency (Hz) to TransferFunction DDS phase increment (32-bit).

    TransferFunction DDS runs at clk1 (100 MHz).
    """
    return int(round((1 << 32) * freq_hz / CLK1_HZ))


def sweep_params(center_v, vpp, freq_hz, vmin, vmax):
    """Compute sweep register values from physical parameters.

    Args:
        center_v: center voltage
        vpp: peak-to-peak amplitude (full swing); output spans center +/- vpp/2
        freq_hz: sweep frequency in Hz
        vmin, vmax: output voltage range

    Returns:
        (min_raw, max_raw, stepsize) for set_sweep()
    """
    min_raw = volts_to_raw16(center_v - vpp / 2.0, vmin, vmax)
    max_raw = volts_to_raw16(center_v + vpp / 2.0, vmin, vmax)
    min_raw = max(-32768, min(32767, min_raw))
    max_raw = max(-32768, min(32767, max_raw))
    if max_raw <= min_raw or freq_hz <= 0:
        return min_raw, max_raw, 0
    stepsize = int(round(
        65535.0 * 2.0 * (max_raw - min_raw) / (DSP_CLK_HZ / freq_hz - 6.0)
    ))
    return min_raw, max_raw, max(0, stepsize)


def sweep_to_freq(min_raw, max_raw, stepsize):
    """Convert sweep register values back to frequency (Hz)."""
    if stepsize == 0 or max_raw <= min_raw:
        return 0.0
    return DSP_CLK_HZ / (65535.0 * 2.0 * (max_raw - min_raw) / stepsize + 6.0)


def relock_stepsize(sweep_rate_v_per_s, vmin, vmax):
    """Compute relock step size from sweep rate in V/s."""
    return int(round(
        (1.0995e12 / DSP_CLK_HZ) * sweep_rate_v_per_s / (vmax - vmin)
    ))


def delay_us_to_cycles(delay_us):
    """Convert delay in microseconds to DSP clock cycles."""
    return int(round(delay_us * DSP_CLK_HZ / 1e6))


def delay_cycles_to_us(cycles):
    """Convert DSP clock cycles to delay in microseconds."""
    return cycles * 1e6 / DSP_CLK_HZ


class ServoDevice:
    """High-level interface to the SuperLaserLand Ethernet digital servo."""

    # Channel base addresses
    CH_BASE = [0x300, 0x400, 0x500]

    def __init__(self, host='192.168.7.140', port=803, timeout=1.0):
        self.dev = lbus_access(host, timeout=timeout, port=port,
                               allow_burst=True)

    # ------------------------------------------------------------------
    # Low-level register access
    # ------------------------------------------------------------------

    def read(self, addr):
        """Read single 32-bit register."""
        return int(self.dev.exchange([addr])[0])

    def write(self, addr, value):
        """Write single 32-bit register."""
        self.dev.exchange([addr], [int(value) & 0xFFFFFFFF])

    def read_multi(self, addrs):
        """Read multiple registers in one packet."""
        return self.dev.exchange(addrs)

    def write_multi(self, addrs, values):
        """Write multiple registers in one packet."""
        self.dev.exchange(addrs, [int(v) & 0xFFFFFFFF for v in values])

    # ------------------------------------------------------------------
    # Status
    # ------------------------------------------------------------------

    def firmware_id(self):
        """Read firmware ID register."""
        return self.read(0x020)

    def status(self):
        """Read basic status: firmware ID, PLL lock, counters."""
        vals = self.read_multi([0x020, 0x021, 0x010, 0x011, 0x012, 0x113])
        return {
            'firmware_id': int(vals[0]),
            'pll_locked': bool(vals[1] & 1),
            'rx_packets': int(vals[2]),
            'tx_packets': int(vals[3]),
            'uptime_ticks': int(vals[4]),
            'ad9783_pll_locked': bool(vals[5] & 1),
        }

    # ------------------------------------------------------------------
    # Stream TX destination
    # ------------------------------------------------------------------

    def set_stream_dest(self, mac, ip, port, src_ip=(192, 168, 7, 140)):
        """Set stream TX destination. IP checksum is computed automatically.

        Args:
            mac: 6-byte MAC as int (e.g. 0x5c857e32af37)
            ip: 4-byte IP as tuple (e.g. (192, 168, 7, 4)) or int
            port: UDP port (e.g. 5000)
            src_ip: FPGA source IP as tuple (must match stream_tx SRC_IP parameter)
        """
        if isinstance(ip, int):
            ip = ((ip >> 24) & 0xFF, (ip >> 16) & 0xFF,
                  (ip >> 8) & 0xFF, ip & 0xFF)
        ip_int = (ip[0] << 24) | (ip[1] << 16) | (ip[2] << 8) | ip[3]
        cksum = stream_ip_checksum(src_ip, ip)
        self.write_multi(
            [0x030, 0x031, 0x032, 0x033, 0x034],
            [(mac >> 16) & 0xFFFFFFFF,
             mac & 0xFFFF,
             ip_int & 0xFFFFFFFF,
             port & 0xFFFF,
             cksum & 0xFFFF]
        )

    def read_stream_dest(self):
        """Read stream TX destination. Returns dict with mac, ip, port, ip_checksum."""
        vals = self.read_multi([0x030, 0x031, 0x032, 0x033, 0x034])
        mac = (int(vals[0]) << 16) | (int(vals[1]) & 0xFFFF)
        ip = int(vals[2])
        return {
            'mac': mac,
            'ip': ((ip >> 24) & 0xFF, (ip >> 16) & 0xFF, (ip >> 8) & 0xFF, ip & 0xFF),
            'port': int(vals[3]) & 0xFFFF,
            'ip_checksum': int(vals[4]) & 0xFFFF,
        }

    # ------------------------------------------------------------------
    # Configuration flash (raw M25P32 SPI transport)
    #
    # The FPGA exposes only a dumb full-duplex SPI transport (flash_spi.v):
    #   0x044 flash_len, 0x045 flash_go, 0x046 flash_busy,
    #   0x800-0x87F  512-byte transfer buffer (128 x 32-bit words, byte0=[7:0]).
    # All M25P32 protocol lives here in software.
    # ------------------------------------------------------------------

    FLASH_LEN  = 0x044
    FLASH_GO   = 0x045
    FLASH_BUSY = 0x046
    FLASH_BUF  = 0x800
    FLASH_BUF_BYTES = 512

    # M25P32 opcodes
    _F_WREN = 0x06
    _F_RDSR = 0x05
    _F_READ = 0x03
    _F_PP   = 0x02
    _F_SE   = 0xD8
    _F_RDID = 0x9F

    _F_PAGE   = 256
    _F_SECTOR = 0x10000  # 64 KiB

    def _flash_xfer(self, tx):
        """Run one chip-select-framed SPI transaction.

        Shifts the bytes in `tx` out MOSI while capturing MISO; returns the
        received bytes (same length). Length must be 1..512.
        """
        tx = bytes(tx)
        n = len(tx)
        if not (1 <= n <= self.FLASH_BUF_BYTES):
            raise ValueError("flash transfer length must be 1..%d (got %d)"
                             % (self.FLASH_BUF_BYTES, n))
        padded = tx + b'\x00' * (-n % 4)
        nwords = len(padded) // 4
        words = [struct.unpack_from('<I', padded, 4 * i)[0] for i in range(nwords)]
        # Fill buffer, then set length and trigger (separate packets so the
        # buffer is fully written before GO).
        self.write_multi([self.FLASH_BUF + i for i in range(nwords)], words)
        self.write_multi([self.FLASH_LEN, self.FLASH_GO], [n, 1])
        self._flash_wait_xfer()
        rwords = self.read_multi([self.FLASH_BUF + i for i in range(nwords)])
        rx = b''.join(struct.pack('<I', int(w) & 0xFFFFFFFF) for w in rwords)
        return rx[:n]

    def _flash_wait_xfer(self, timeout=1.0):
        """Wait for an in-progress SPI shift to finish (flash_busy clears)."""
        t0 = time.time()
        while time.time() - t0 < timeout:
            if (int(self.read(self.FLASH_BUSY)) & 1) == 0:
                return
        raise TimeoutError("flash SPI transfer did not complete")

    def _flash_wren(self):
        self._flash_xfer(bytes([self._F_WREN]))

    def _flash_wait_wip(self, timeout=10.0):
        """Wait for the flash write-in-progress (WIP) bit to clear."""
        t0 = time.time()
        while time.time() - t0 < timeout:
            sr = self._flash_xfer(bytes([self._F_RDSR, 0x00]))[1]
            if (sr & 0x01) == 0:
                return
        raise TimeoutError("flash write/erase did not complete")

    def flash_read_id(self):
        """Read JEDEC ID. M25P32 returns (0x20, 0x20, 0x16)."""
        rx = self._flash_xfer(bytes([self._F_RDID, 0, 0, 0]))
        return tuple(rx[1:4])

    def flash_read(self, addr, n):
        """Read n bytes from flash starting at byte address addr."""
        out = bytearray()
        while n > 0:
            chunk = min(n, self.FLASH_BUF_BYTES - 4)  # 4-byte cmd+addr header
            tx = bytes([self._F_READ, (addr >> 16) & 0xFF,
                        (addr >> 8) & 0xFF, addr & 0xFF]) + b'\x00' * chunk
            out += self._flash_xfer(tx)[4:]
            addr += chunk
            n -= chunk
        return bytes(out)

    def flash_erase_sector(self, addr):
        """Erase the 64 KiB sector containing byte address addr."""
        self._flash_wren()
        self._flash_xfer(bytes([self._F_SE, (addr >> 16) & 0xFF,
                                (addr >> 8) & 0xFF, addr & 0xFF]))
        self._flash_wait_wip()

    def flash_program(self, addr, data):
        """Program bytes to flash, honoring 256-byte page boundaries.

        The sector must already be erased (erase sets bits to 1; program only
        clears bits to 0).
        """
        data = bytes(data)
        off = 0
        while off < len(data):
            page_off = addr & (self._F_PAGE - 1)
            chunk = min(self._F_PAGE - page_off, len(data) - off)
            self._flash_wren()
            tx = bytes([self._F_PP, (addr >> 16) & 0xFF,
                        (addr >> 8) & 0xFF, addr & 0xFF]) + data[off:off + chunk]
            self._flash_xfer(tx)
            self._flash_wait_wip()
            addr += chunk
            off += chunk

    # ------------------------------------------------------------------
    # Non-volatile configuration (host-managed, stored in flash)
    # ------------------------------------------------------------------

    # Flash byte address of the config blob. Sector 63 of the M25P32, well
    # clear of the FPGA bitstream (sectors 0..). Matches the original NIST
    # firmware's config sector.
    CONFIG_FLASH_ADDR = 0x3F0000
    CONFIG_MAGIC   = b'SLLC'   # SuperLaserLand Config
    CONFIG_VERSION = 1

    @classmethod
    def config_regs(cls):
        """Ordered list of lbus addresses that make up the persistent config.

        Every address here is both writable and readable in the gateway, so a
        read/write round-trip is lossless.
        """
        regs = []
        # Stream TX destination
        regs += [0x030, 0x031, 0x032, 0x033, 0x034]
        # DAC values / output gain / ramp
        regs += [0x100, 0x101, 0x102, 0x103, 0x104]
        # ADC gain, input IIR enable + coefficients
        regs += [0x204, 0x205] + list(range(0x206, 0x212))
        # Servo channels 0/1/2
        for base in cls.CH_BASE:
            regs += [base + o for o in range(0x00, 0x06)]
            regs += [base + o for o in range(0x10, 0x3D)]
        # LockIn
        regs += [0x600, 0x601, 0x602] + list(range(0x610, 0x626))
        # PhaseDetector
        regs += [0x700, 0x701, 0x702] + list(range(0x710, 0x715))
        return regs

    def _config_serialize(self, regs, values):
        body = struct.pack('<4sBBH', self.CONFIG_MAGIC, self.CONFIG_VERSION,
                           0, len(regs))
        for a, v in zip(regs, values):
            body += struct.pack('<HI', a & 0xFFFF, int(v) & 0xFFFFFFFF)
        body += struct.pack('<I', zlib.crc32(body) & 0xFFFFFFFF)
        return body

    def save_config(self):
        """Snapshot the current register config and store it in flash.

        Returns the number of registers saved.
        """
        regs = self.config_regs()
        values = [int(v) for v in self.read_multi(regs)]
        blob = self._config_serialize(regs, values)
        if len(blob) > self._F_SECTOR:
            raise ValueError("config blob too large for one sector")
        self.flash_erase_sector(self.CONFIG_FLASH_ADDR)
        self.flash_program(self.CONFIG_FLASH_ADDR, blob)
        # Verify readback
        check = self.flash_read(self.CONFIG_FLASH_ADDR, len(blob))
        if check != blob:
            raise IOError("config flash verify failed")
        return len(regs)

    def read_config_blob(self):
        """Read and validate the config blob from flash.

        Returns a list of (addr, value) pairs, or None if no valid config is
        stored (blank flash or bad magic/CRC/version).
        """
        header = self.flash_read(self.CONFIG_FLASH_ADDR, 8)
        magic, version, _, count = struct.unpack('<4sBBH', header)
        if magic != self.CONFIG_MAGIC or version != self.CONFIG_VERSION:
            return None
        total = 8 + count * 6 + 4
        blob = self.flash_read(self.CONFIG_FLASH_ADDR, total)
        stored_crc = struct.unpack_from('<I', blob, total - 4)[0]
        if zlib.crc32(blob[:total - 4]) & 0xFFFFFFFF != stored_crc:
            return None
        pairs = [struct.unpack_from('<HI', blob, 8 + 6 * i) for i in range(count)]
        return pairs

    def load_config(self):
        """Load config from flash and apply it to the registers.

        Returns the number of registers applied, or None if no valid config is
        stored (registers left at power-on defaults).
        """
        pairs = self.read_config_blob()
        if pairs is None:
            return None
        addrs = [a for a, _ in pairs]
        values = [v for _, v in pairs]
        self.write_multi(addrs, values)
        return len(pairs)

    # ------------------------------------------------------------------
    # Generic framed blob storage in flash (host-only data; FPGA ignores it)
    #
    # Used by the GUI to persist its high-level settings (filter type/freq/gain
    # etc.) which cannot be reconstructed from the register coefficients -- the
    # original NIST firmware likewise stored these high-level params in flash.
    # Stored in a separate sector from the register snapshot (CONFIG_FLASH_ADDR).
    # ------------------------------------------------------------------

    GUI_SETTINGS_FLASH_ADDR = 0x3E0000  # sector 62
    BLOB_MAGIC = b'SLBL'

    def flash_save_blob(self, addr, data):
        """Erase a sector and store an arbitrary byte blob with a framed header.

        Frame: magic(4) + length(4 LE) + data + crc32(4 LE). Returns len(data).
        """
        data = bytes(data)
        body = struct.pack('<4sI', self.BLOB_MAGIC, len(data)) + data
        body += struct.pack('<I', zlib.crc32(body) & 0xFFFFFFFF)
        if len(body) > self._F_SECTOR:
            raise ValueError("blob too large for one sector")
        self.flash_erase_sector(addr)
        self.flash_program(addr, body)
        if self.flash_read(addr, len(body)) != body:
            raise IOError("blob flash verify failed")
        return len(data)

    def flash_load_blob(self, addr):
        """Read a framed blob from flash. Returns the bytes, or None if absent
        or corrupt (blank flash / bad magic / bad CRC)."""
        head = self.flash_read(addr, 8)
        magic, n = struct.unpack('<4sI', head)
        if magic != self.BLOB_MAGIC or n > self._F_SECTOR:
            return None
        total = 8 + n + 4
        body = self.flash_read(addr, total)
        stored_crc = struct.unpack_from('<I', body, total - 4)[0]
        if zlib.crc32(body[:total - 4]) & 0xFFFFFFFF != stored_crc:
            return None
        return body[8:8 + n]

    # ------------------------------------------------------------------
    # FPGA network identity (MAC/IP), loaded by the FPGA at boot
    #
    # Stored in its own flash sector and read autonomously by the gateware's
    # net_config_loader at power-up (the host cannot set the address it uses to
    # reach the board). 16-byte block, format must match net_config_loader.v:
    #   magic "NCF1" + MAC[6] + IP[4] + checksum[2 LE] (sum of first 14 bytes).
    # Recovery: jumper DOUT[1]->DIN[1] at boot forces the compiled-in default.
    # ------------------------------------------------------------------

    NET_CONFIG_FLASH_ADDR = 0x3D0000  # sector 61
    NET_CONFIG_MAGIC = b'NCF1'

    @staticmethod
    def _mac_bytes(mac):
        if isinstance(mac, int):
            return bytes((mac >> (8 * (5 - i)) & 0xFF) for i in range(6))
        b = bytes(mac)
        if len(b) != 6:
            raise ValueError("MAC must be 6 bytes / 48-bit int")
        return b

    @staticmethod
    def _ip_bytes(ip):
        if isinstance(ip, int):
            return bytes((ip >> (8 * (3 - i)) & 0xFF) for i in range(4))
        b = bytes(ip)
        if len(b) != 4:
            raise ValueError("IP must be 4 bytes / tuple")
        return b

    def set_network_config(self, mac, ip):
        """Store the FPGA's own MAC/IP in flash; takes effect on NEXT boot.

        mac: 48-bit int (e.g. 0xAA0055000123) or 6 bytes.
        ip:  32-bit int or 4-tuple (e.g. (192, 168, 7, 140)).

        NOTE: the running firmware keeps its current address until power-cycled
        or reprogrammed; afterwards reconnect at the new IP. If a bad IP locks
        you out, jumper DOUT[1] to DIN[1] and power-cycle to force the default.
        """
        macb = self._mac_bytes(mac)
        ipb = self._ip_bytes(ip)
        body = self.NET_CONFIG_MAGIC + macb + ipb          # 14 bytes
        block = body + struct.pack('<H', sum(body) & 0xFFFF)  # +2 checksum
        self.flash_erase_sector(self.NET_CONFIG_FLASH_ADDR)
        self.flash_program(self.NET_CONFIG_FLASH_ADDR, block)
        if self.flash_read(self.NET_CONFIG_FLASH_ADDR, len(block)) != block:
            raise IOError("network config flash verify failed")
        return {'mac': ':'.join('%02x' % b for b in macb), 'ip': tuple(ipb)}

    def read_network_config(self):
        """Read the stored MAC/IP. Returns dict, or None if blank/invalid
        (board boots at the compiled-in default in that case)."""
        block = self.flash_read(self.NET_CONFIG_FLASH_ADDR, 16)
        if block[:4] != self.NET_CONFIG_MAGIC:
            return None
        if (sum(block[:14]) & 0xFFFF) != struct.unpack('<H', block[14:16])[0]:
            return None
        return {
            'mac': ':'.join('%02x' % b for b in block[4:10]),
            'ip': tuple(block[10:14]),
        }

    def recovery_status(self):
        """Read boot status reg 0x021: whether the board is running on the
        recovery (default) address and whether the boot loader finished."""
        v = int(self.read(0x021))
        return {
            'eth_clk_locked': bool(v & 1),
            'net_recovery': bool(v & 2),   # loopback recovery -> default MAC/IP
            'boot_done': bool(v & 4),
        }

    # ------------------------------------------------------------------
    # ADC
    # ------------------------------------------------------------------

    def read_adc_raw(self):
        """Read raw ADC values (16-bit signed). Returns (ch0, ch1)."""
        vals = self.read_multi([0x200, 0x201])
        return (_from_signed(vals[0], 32), _from_signed(vals[1], 32))

    def read_adc(self):
        """Read filtered ADC values (24-bit signed). Returns (ch0, ch1)."""
        vals = self.read_multi([0x202, 0x203])
        return (_from_signed(vals[0], 32), _from_signed(vals[1], 32))

    def set_input_gain(self, gain0, gain1):
        """Set input PGA gain. Values 0-3 (1x, 2x, 4x, 8x)."""
        self.write(0x204, (gain1 & 3) << 2 | (gain0 & 3))

    def read_input_gain(self):
        """Read input PGA gain. Returns (gain0, gain1), each 0-3."""
        val = self.read(0x204)
        return (val & 0x3, (val >> 2) & 0x3)

    def set_adc_iir(self, ch, on, a1=0, b0=0, b1=0):
        """Set ADC input IIR filter (1st order) coefficients.

        Args:
            ch: ADC channel (0 or 1)
            on: enable filter
            a1, b0, b1: 35-bit signed coefficients
        """
        base = 0x206 + ch * 6  # ch0: 0x206, ch1: 0x20C
        # Update enable register (both channels share one register)
        enable = self.read(0x205)
        if on:
            enable |= (1 << ch)
        else:
            enable &= ~(1 << ch)
        self.write(0x205, enable)

        a1_lo, a1_hi = _split_35(a1)
        b0_lo, b0_hi = _split_35(b0)
        b1_lo, b1_hi = _split_35(b1)
        self.write_multi(
            [base, base+1, base+2, base+3, base+4, base+5],
            [a1_lo, a1_hi, b0_lo, b0_hi, b1_lo, b1_hi]
        )

    # ------------------------------------------------------------------
    # DAC
    # ------------------------------------------------------------------

    def set_dac(self, ch, value):
        """Set DAC value directly (24-bit signed). Only effective when servo_on=0."""
        self.write(0x100 + ch, _to_signed(value, 24))

    def read_dac(self, ch):
        """Read DAC register value (24-bit signed)."""
        return _from_signed(self.read(0x100 + ch), 32)

    def set_output_gain(self, gain0, gain1):
        """Set output PGA gain. Values 0-3."""
        self.write(0x103, (gain1 & 3) << 2 | (gain0 & 3))

    def read_output_gain(self):
        """Read output PGA gain. Returns (gain0, gain1), each 0-3."""
        val = self.read(0x103)
        return (val & 0x3, (val >> 2) & 0x3)

    def set_ramp(self, enable):
        """Enable/disable hardware ramp (~6 Hz sawtooth on all DACs)."""
        self.write(0x104, 1 if enable else 0)

    # ------------------------------------------------------------------
    # SPI command interface (shared by ADC, DAC, TransferFunction)
    # ------------------------------------------------------------------

    def spi_command(self, addr, data, data2=0):
        """Send SPI/command trigger. Used for ADC/DAC SPI and TransferFunction."""
        self.write(0x110, addr & 0xFFFF)
        self.write(0x111, data & 0xFFFF)
        if data2:
            self.write(0x114, data2 & 0xFFFF)
        self.write(0x112, 1)  # trigger

    # ------------------------------------------------------------------
    # Servo channel control
    # ------------------------------------------------------------------

    def _ch_addr(self, ch, offset):
        return self.CH_BASE[ch] + offset

    def servo_on(self, ch, on):
        """Enable/disable servo loop for channel."""
        self.write(self._ch_addr(ch, 0x00), 1 if on else 0)

    def set_input_mux(self, ch, source, invert=False):
        """Set servo input source.

        Args:
            ch: channel (0, 1, 2)
            source: INPUT_ADC0..INPUT_DAC2
            invert: negate the input
        """
        self.write(self._ch_addr(ch, 0x01), (source & 7) << 1 | (1 if invert else 0))

    def set_offset(self, ch, value):
        """Set servo input offset (16-bit signed)."""
        self.write(self._ch_addr(ch, 0x02), _to_signed(value, 16))

    def set_limits(self, ch, min_val, max_val, center_when_railed=False):
        """Set output limiter (16-bit signed min/max)."""
        self.write_multi(
            [self._ch_addr(ch, 0x03), self._ch_addr(ch, 0x04),
             self._ch_addr(ch, 0x05)],
            [_to_signed(min_val, 16), _to_signed(max_val, 16),
             1 if center_when_railed else 0]
        )

    def _write_35(self, addr, val):
        """Write a 35-bit coefficient as two registers."""
        lo, hi = _split_35(val)
        self.write_multi([addr, addr + 1], [lo, hi])

    def _read_35(self, addr):
        """Read a 35-bit coefficient from two registers."""
        vals = self.read_multi([addr, addr + 1])
        return _join_35(vals[0], vals[1])

    def set_iir0(self, ch, on, a1=0, a2=0, b0=0, b1=0, b2=0):
        """Set IIR0 (2nd order anti-windup) coefficients.

        All coefficients are 35-bit signed fixed-point (A0_SHIFT=26).
        """
        base = self._ch_addr(ch, 0x10)
        self.write(base, 1 if on else 0)
        self._write_35(base + 0x01, a1)
        self._write_35(base + 0x03, a2)
        self._write_35(base + 0x05, b0)
        self._write_35(base + 0x07, b1)
        self._write_35(base + 0x09, b2)

    def set_iir1(self, ch, on, a1=0, b0=0, b1=0):
        """Set IIR1 (1st order anti-windup) coefficients."""
        base = self._ch_addr(ch, 0x1B)
        self.write(base, 1 if on else 0)
        self._write_35(base + 0x01, a1)
        self._write_35(base + 0x03, b0)
        self._write_35(base + 0x05, b1)

    def set_iir2(self, ch, on, a1=0, b0=0, b1=0):
        """Set IIR2 (1st order, ch0/ch1 only)."""
        assert ch < 2, "IIR2 only available on ch0 and ch1"
        base = self._ch_addr(ch, 0x22)
        self.write(base, 1 if on else 0)
        self._write_35(base + 0x01, a1)
        self._write_35(base + 0x03, b0)
        self._write_35(base + 0x05, b1)

    def set_iir3(self, ch, on, a1=0, b0=0, b1=0):
        """Set IIR3 (1st order, ch0/ch1 only)."""
        assert ch < 2, "IIR3 only available on ch0 and ch1"
        base = self._ch_addr(ch, 0x29)
        self.write(base, 1 if on else 0)
        self._write_35(base + 0x01, a1)
        self._write_35(base + 0x03, b0)
        self._write_35(base + 0x05, b1)

    def read_servo_status(self, ch):
        """Read servo channel output and status.

        Returns dict with:
            dacin: servo output (24-bit signed)
            railed: (min_railed, max_railed)
            relock_hold: bool
        """
        vals = self.read_multi([self._ch_addr(ch, 0x3E),
                                self._ch_addr(ch, 0x3F)])
        status = int(vals[1])
        return {
            'dacin': _from_signed(vals[0], 32),
            'railed': (bool(status & 1), bool(status & 2)),
            'relock_hold': bool(status & 4),
        }

    # ------------------------------------------------------------------
    # Sweep
    # ------------------------------------------------------------------

    def set_sweep(self, ch, on, min_val=0, max_val=0, stepsize=0):
        """Configure sweep generator.

        Args:
            min_val, max_val: 16-bit signed sweep range
            stepsize: 32-bit unsigned (higher = faster sweep)
        """
        base = self._ch_addr(ch, 0x30)
        self.write_multi(
            [base, base+1, base+2, base+3],
            [1 if on else 0, _to_signed(min_val, 16),
             _to_signed(max_val, 16), stepsize & 0xFFFFFFFF]
        )

    # ------------------------------------------------------------------
    # DOUT source select (reg 0x022)
    #
    # Each DOUT pin (0/1/2) drives either its default relock-hold status or the
    # sweep sync (high during the rising min->max half) of a chosen channel.
    # ------------------------------------------------------------------

    REG_DOUT_SRC = 0x022

    @staticmethod
    def _dout_src_code(source):
        """Map a source spec to its 2-bit field value.

        Accepts 'status'/'default'/None -> 0, or a sweep channel as
        'sync0'/'sync1'/'sync2' or int 0/1/2 -> field 1/2/3.
        """
        if source in (None, 'status', 'default'):
            return 0
        if isinstance(source, str):
            s = source.lower()
            if s.startswith('sync'):
                source = int(s[4:])
            else:
                source = int(s)
        ch = int(source)
        if ch not in (0, 1, 2):
            raise ValueError("sweep-sync channel must be 0, 1 or 2")
        return ch + 1

    def set_dout_source(self, pin, source):
        """Route a DOUT pin to a signal source.

        Args:
            pin: DOUT pin index 0, 1 or 2.
            source: 'status'/'default' for the relock-hold status (default
                behavior), or a sweep channel ('sync0'/'sync1'/'sync2' or
                int 0/1/2) to output that channel's sweep sync.
        """
        if pin not in (0, 1, 2):
            raise ValueError("DOUT pin must be 0, 1 or 2")
        code = self._dout_src_code(source)
        reg = int(self.read(self.REG_DOUT_SRC)) & 0x3F
        reg = (reg & ~(0x3 << (2 * pin))) | (code << (2 * pin))
        self.write(self.REG_DOUT_SRC, reg)

    def get_dout_sources(self):
        """Return the source of each DOUT pin as a list of 3 strings:
        'status', or 'sync0'/'sync1'/'sync2'."""
        reg = int(self.read(self.REG_DOUT_SRC)) & 0x3F
        out = []
        for pin in range(3):
            code = (reg >> (2 * pin)) & 0x3
            out.append('status' if code == 0 else 'sync%d' % (code - 1))
        return out

    # ------------------------------------------------------------------
    # Relock
    # ------------------------------------------------------------------

    def set_relock(self, ch, on, input_sel=INPUT_ADC0,
                   min_val=0, max_val=0, stepsize=0):
        """Configure auto-relock.

        Args:
            input_sel: signal to monitor for lock detection (INPUT_* constants)
            min_val, max_val: 16-bit signed lock detection window
            stepsize: relock sweep speed
        """
        base = self._ch_addr(ch, 0x34)
        self.write_multi(
            [base, base+1, base+2, base+3, base+4],
            [1 if on else 0, input_sel & 0xF,
             _to_signed(min_val, 16), _to_signed(max_val, 16),
             stepsize & 0xFFFFFFFF]
        )

    # ------------------------------------------------------------------
    # DigitalDelay (hold source)
    # ------------------------------------------------------------------

    def set_hold_source(self, ch, source):
        """Set hold source for servo channel. Use HOLD_* constants."""
        self.write(self._ch_addr(ch, 0x39), source & 0x1F)

    def set_digital_delay(self, ch, falling=0, rising=0):
        """Set DigitalDelay timing (in clk_dsp cycles = 40 ns each)."""
        self.write_multi(
            [self._ch_addr(ch, 0x3A), self._ch_addr(ch, 0x3B)],
            [falling & 0xFFFFFFFF, rising & 0xFFFFFFFF]
        )

    # ------------------------------------------------------------------
    # LockIn LO shift (per-channel modulation coupling)
    # ------------------------------------------------------------------

    def set_lo_shift(self, ch, shift):
        """Set LockIn LO right-shift for modulation output (0-31)."""
        self.write(self._ch_addr(ch, 0x3C), shift & 0x1F)

    # ------------------------------------------------------------------
    # LockIn demodulator
    # ------------------------------------------------------------------

    def set_lockin_input(self, source):
        """Set LockIn input (0=ADC0, 1=ADC1)."""
        self.write(0x600, source & 1)

    def set_lockin_nco(self, pinc, poff=0):
        """Set LockIn NCO frequency and phase.

        Args:
            pinc: 24-bit phase increment (frequency word)
            poff: 24-bit signed phase offset
        """
        self.write_multi([0x601, 0x602],
                         [pinc & 0xFFFFFF, _to_signed(poff, 24)])

    def set_lockin_iir0(self, on, a1=0, a2=0, b0=0, b1=0, b2=0):
        """Set LockIn pre-filter (2nd order IIR)."""
        self.write(0x610, 1 if on else 0)
        self._write_35(0x611, a1)
        self._write_35(0x613, a2)
        self._write_35(0x615, b0)
        self._write_35(0x617, b1)
        self._write_35(0x619, b2)

    def set_lockin_iir1(self, on, a1=0, a2=0, b0=0, b1=0, b2=0):
        """Set LockIn post-filter (2nd order IIR)."""
        self.write(0x61B, 1 if on else 0)
        self._write_35(0x61C, a1)
        self._write_35(0x61E, a2)
        self._write_35(0x620, b0)
        self._write_35(0x622, b1)
        self._write_35(0x624, b2)

    def read_lockin(self):
        """Read LockIn output and LO phase.

        Returns dict with:
            out: demodulated output (24-bit signed)
            lo: local oscillator (24-bit signed)
        """
        vals = self.read_multi([0x630, 0x631])
        return {
            'out': _from_signed(vals[0], 32),
            'lo': _from_signed(vals[1], 32),
        }

    # ------------------------------------------------------------------
    # PhaseDetector
    # ------------------------------------------------------------------

    def set_phasedet_input(self, source):
        """Set PhaseDetector input (0=ADC0, 1=ADC1)."""
        self.write(0x700, source & 1)

    def set_phasedet(self, use_ext_clk=False, pinc=0):
        """Configure PhaseDetector.

        Args:
            use_ext_clk: use external 10 MHz reference on DIN[0]
            pinc: 32-bit phase increment (NCO frequency word)
        """
        self.write_multi([0x701, 0x702],
                         [1 if use_ext_clk else 0, pinc & 0xFFFFFFFF])

    def set_phasedet_lp(self, on, a1=0, b0=0):
        """Set PhaseDetector LP filter (1st order, a1 and b0 only)."""
        self.write(0x710, 1 if on else 0)
        self._write_35(0x711, a1)
        self._write_35(0x713, b0)

    def read_phasedet(self):
        """Read PhaseDetector raw phase (32-bit signed)."""
        return _from_signed(self.read(0x730), 32)

    # ------------------------------------------------------------------
    # TransferFunction
    # ------------------------------------------------------------------

    def set_transfer_freq(self, freq_word):
        """Set TransferFunction DDS frequency (32-bit phase increment).

        freq = freq_word * f_clk / 2^32, where f_clk = 100 MHz.
        """
        self.spi_command(0x4000, freq_word & 0xFFFF, (freq_word >> 16) & 0xFFFF)

    def set_transfer_amplitude(self, ch, shift):
        """Set TransferFunction modulation amplitude for channel.

        Args:
            ch: channel (0, 1, 2)
            shift: right-shift (0=full, 31=off), 5-bit
        """
        self.spi_command(0x4100 + ch, shift & 0x1F)

    def read_transfer(self):
        """Read TransferFunction sin/cos outputs."""
        vals = self.read_multi([0x115, 0x116])
        return {
            'sin': _from_signed(vals[0], 32),
            'cos': _from_signed(vals[1], 32),
        }

    # ------------------------------------------------------------------
    # DDR2Logger
    # ------------------------------------------------------------------

    def ddr2_capture(self, n_samples):
        """Start DDR2 capture for n_samples clock cycles.

        Triggers via shared SPI command interface (addr=0x1001xx).
        """
        self.spi_command(0x10010, n_samples & 0xFFFF)

    def ddr2_reset(self):
        """Reset DDR2Logger FIFOs and enter read mode."""
        self.spi_command(0x10000, 0)

    # ------------------------------------------------------------------
    # Convenience / monitoring
    # ------------------------------------------------------------------

    def read_all_adc(self):
        """Read all ADC values in one packet."""
        vals = self.read_multi([0x200, 0x201, 0x202, 0x203])
        return {
            'raw0': _from_signed(vals[0], 32),
            'raw1': _from_signed(vals[1], 32),
            'filt0': _from_signed(vals[2], 32),
            'filt1': _from_signed(vals[3], 32),
        }

    def read_all_servo(self):
        """Read servo output and status for all 3 channels."""
        addrs = []
        for ch in range(3):
            addrs.extend([self._ch_addr(ch, 0x3E), self._ch_addr(ch, 0x3F)])
        vals = self.read_multi(addrs)
        result = {}
        for ch in range(3):
            status = int(vals[ch * 2 + 1])
            result[ch] = {
                'dacin': _from_signed(vals[ch * 2], 32),
                'railed': (bool(status & 1), bool(status & 2)),
                'relock_hold': bool(status & 4),
            }
        return result

    def snapshot(self):
        """Read a comprehensive status snapshot (ADC + servo + LockIn + PhaseDet)."""
        addrs = [
            0x200, 0x201, 0x202, 0x203,  # ADC
            0x33E, 0x33F,  # ch0
            0x43E, 0x43F,  # ch1
            0x53E, 0x53F,  # ch2
            0x630, 0x631,  # LockIn
            0x730,         # PhaseDet
        ]
        vals = self.read_multi(addrs)
        v = [int(x) for x in vals]
        return {
            'adc_raw': (_from_signed(v[0], 32), _from_signed(v[1], 32)),
            'adc_filt': (_from_signed(v[2], 32), _from_signed(v[3], 32)),
            'ch0': {'dacin': _from_signed(v[4], 32),
                    'railed': (bool(v[5] & 1), bool(v[5] & 2)),
                    'relock_hold': bool(v[5] & 4)},
            'ch1': {'dacin': _from_signed(v[6], 32),
                    'railed': (bool(v[7] & 1), bool(v[7] & 2)),
                    'relock_hold': bool(v[7] & 4)},
            'ch2': {'dacin': _from_signed(v[8], 32),
                    'railed': (bool(v[9] & 1), bool(v[9] & 2)),
                    'relock_hold': bool(v[9] & 4)},
            'lockin': {'out': _from_signed(v[10], 32),
                       'lo': _from_signed(v[11], 32)},
            'phasedet': _from_signed(v[12], 32),
        }


    # ------------------------------------------------------------------
    # High-level convenience methods (physical units)
    # ------------------------------------------------------------------

    def set_dac_voltage(self, ch, voltage, output_gain=None):
        """Set DAC output voltage. Only effective when servo_on=0.

        Args:
            ch: channel (0, 1, 2)
            voltage: output voltage in V
            output_gain: if provided, set output PGA gain (0-3) for ch0/ch1
        """
        if ch < 2:
            gain = output_gain if output_gain is not None else 0
            vmin, vmax = OUTPUT_RANGES[gain]
        else:
            vmin, vmax = AD5791_RANGE
        self.set_dac(ch, volts_to_dac24(voltage, vmin, vmax))

    def set_sweep_hz(self, ch, center_v, vpp, freq_hz, vmin=-1.0, vmax=1.0):
        """Configure sweep with physical units.

        Args:
            center_v: center voltage
            vpp: peak-to-peak amplitude (full swing); output spans center +/- vpp/2
            freq_hz: sweep frequency
            vmin, vmax: output range (must match PGA setting)
        """
        mn, mx, step = sweep_params(center_v, vpp, freq_hz, vmin, vmax)
        self.set_sweep(ch, True, min_val=mn, max_val=mx, stepsize=step)

    def set_servo_lowpass(self, ch, freq_hz, gain_db=0.0):
        """Configure servo IIR0 as a 2nd-order low-pass filter.

        Uses IIR0 (2nd order, update_every=27) with IIR1 as unity passthrough.
        IIR2/IIR3 left off (ch0/ch1) or N/A (ch2).

        Args:
            ch: channel (0, 1, 2)
            freq_hz: corner frequency in Hz
            gain_db: filter gain in dB
        """
        c0 = iir2_coeffs('lowpass', freq_hz, Q=0.707, gain_db=gain_db,
                          a0_shift=26, update_every=27, fs=DSP_CLK_HZ)
        self.set_iir0(ch, True, **c0)
        # IIR1 as unity passthrough
        a0 = 1 << 26
        self.set_iir1(ch, True, a1=0, b0=a0, b1=0)

    def set_servo_pi(self, ch, freq_hz, gain_db=0.0, gain_limit_db=81.0):
        """Configure servo as proportional-integral controller.

        IIR1 as PI, IIR0 off (passthrough).

        Args:
            ch: channel
            freq_hz: PI corner frequency (crossover)
            gain_db: proportional gain in dB
            gain_limit_db: integral gain limit (81 = infinite)
        """
        c1 = iir1_coeffs('pi', freq_hz, gain_db=gain_db,
                          gain_limit_db=gain_limit_db,
                          a0_shift=26, fs=DSP_CLK_HZ)
        self.set_iir0(ch, False)  # passthrough
        self.set_iir1(ch, True, **c1)

    def set_servo_pid(self, ch, pi_freq_hz, pi_gain_db=0.0,
                      pd_freq_hz=None, pd_gain_db=0.0, pd_gain_limit_db=20.0):
        """Configure servo as PID controller.

        IIR0 off (passthrough), IIR1 as PI, IIR2 as PD (ch0/ch1 only).

        Args:
            ch: channel (0 or 1 for PD stage)
            pi_freq_hz: PI crossover frequency
            pi_gain_db: PI gain in dB
            pd_freq_hz: PD crossover (None = skip PD)
            pd_gain_db: PD gain in dB
            pd_gain_limit_db: PD high-frequency rolloff
        """
        self.set_iir0(ch, False)
        c_pi = iir1_coeffs('pi', pi_freq_hz, gain_db=pi_gain_db,
                            a0_shift=26, fs=DSP_CLK_HZ)
        self.set_iir1(ch, True, **c_pi)
        if pd_freq_hz is not None and ch < 2:
            c_pd = iir1_coeffs('pd', pd_freq_hz, gain_db=pd_gain_db,
                                gain_limit_db=pd_gain_limit_db,
                                a0_shift=26, fs=DSP_CLK_HZ)
            self.set_iir2(ch, True, **c_pd)

    def set_lockin_freq(self, freq_hz, phase_deg=0.0):
        """Set LockIn demodulation frequency and phase.

        Args:
            freq_hz: demodulation frequency in Hz
            phase_deg: phase offset in degrees
        """
        pinc = freq_to_lockin_pinc(freq_hz)
        poff = int(round((1 << 24) * phase_deg / 360.0))
        self.set_lockin_nco(pinc, poff)

    def set_lockin_lowpass(self, freq_hz, Q=0.707, gain_db=0.0, stage='both'):
        """Set LockIn IIR filter(s) as low-pass.

        LockIn uses IIRfilter2ndOrderSlow (A0_SHIFT=32, update_every=26).

        Args:
            freq_hz: corner frequency
            Q: quality factor
            gain_db: gain in dB
            stage: 'pre', 'post', or 'both'
        """
        c = iir2_coeffs('lowpass', freq_hz, Q=Q, gain_db=gain_db,
                         a0_shift=32, update_every=26, fs=DSP_CLK_HZ)
        if stage in ('pre', 'both'):
            self.set_lockin_iir0(True, **c)
        if stage in ('post', 'both'):
            self.set_lockin_iir1(True, **c)

    def set_phasedet_freq(self, freq_hz, use_ext_clk=False):
        """Set PhaseDetector frequency in Hz.

        Args:
            freq_hz: detection frequency (PhaseDetector DDS at 100 MHz)
            use_ext_clk: lock to external 10 MHz on DIN[0]
        """
        pinc = freq_to_phasedet_pinc(freq_hz)
        self.set_phasedet(use_ext_clk=use_ext_clk, pinc=pinc)

    def set_transfer_freq_hz(self, freq_hz):
        """Set TransferFunction modulation frequency in Hz."""
        self.set_transfer_freq(freq_to_transfer_pinc(freq_hz))

    def set_relock_rate(self, ch, sweep_rate_v_per_s, input_sel=INPUT_ADC0,
                        lock_min_v=None, lock_max_v=None,
                        vmin=-1.0, vmax=1.0):
        """Configure relock with physical units.

        Args:
            ch: channel
            sweep_rate_v_per_s: relock sweep rate in V/s
            input_sel: signal to monitor for lock detection
            lock_min_v, lock_max_v: lock detection window in V
            vmin, vmax: range of the monitored signal
        """
        step = relock_stepsize(sweep_rate_v_per_s, vmin, vmax)
        mn = volts_to_raw16(lock_min_v, vmin, vmax) if lock_min_v is not None else 0
        mx = volts_to_raw16(lock_max_v, vmin, vmax) if lock_max_v is not None else 0
        self.set_relock(ch, True, input_sel=input_sel,
                        min_val=mn, max_val=mx, stepsize=step)

    def set_hold_delay_us(self, ch, falling_us=0.0, rising_us=0.0):
        """Set DigitalDelay timing in microseconds."""
        self.set_digital_delay(ch,
                               falling=delay_us_to_cycles(falling_us),
                               rising=delay_us_to_cycles(rising_us))


if __name__ == '__main__':
    dev = ServoDevice()
    st = dev.status()
    print(f"Firmware ID: 0x{st['firmware_id']:08X}")
    print(f"PLL locked:  {st['pll_locked']}")
    print(f"RX packets:  {st['rx_packets']}")

    adc = dev.read_all_adc()
    print(f"\nADC raw:  ch0={adc['raw0']:+8d}  ch1={adc['raw1']:+8d}")
    print(f"ADC filt: ch0={adc['filt0']:+8d}  ch1={adc['filt1']:+8d}")

    servo = dev.read_all_servo()
    for ch in range(3):
        s = servo[ch]
        print(f"Ch{ch}: dacin={s['dacin']:+8d}  railed={s['railed']}  hold={s['relock_hold']}")
