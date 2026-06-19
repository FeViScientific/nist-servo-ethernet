#!/usr/bin/env python3
"""CLI interface for SuperLaserLand Ethernet servo.

Usage:
    python3 servo_cli.py status
    python3 servo_cli.py adc
    python3 servo_cli.py dac read
    python3 servo_cli.py dac set 0 0.1          # AOUT0 = 0.1V
    python3 servo_cli.py dac zero                # all DACs to 0
    python3 servo_cli.py sweep 0 0.5 200         # AOUT0: 0.5V peak-to-peak, 200 Hz
    python3 servo_cli.py sweep off 0             # stop sweep on ch0
    python3 servo_cli.py dout 0 sync 0           # DOUT0 = ch0 sweep sync (rising-half high)
    python3 servo_cli.py dout 0 status           # DOUT0 = relock-hold status (default)
    python3 servo_cli.py servo on 1              # servo on ch1
    python3 servo_cli.py servo off 1             # servo off ch1
    python3 servo_cli.py servo off               # all servos off
    python3 servo_cli.py iir0 1 lowpass 5000     # ch1 IIR0 = 5kHz lowpass
    python3 servo_cli.py iir1 1 pi 1000 20       # ch1 IIR1 = PI, 1kHz, 20dB
    python3 servo_cli.py mux 1 0                 # ch1 input = ADC0
    python3 servo_cli.py mux 1 0 invert          # ch1 input = -ADC0
    python3 servo_cli.py limits 1 -0.5 0.5       # ch1 limits +/-0.5V
    python3 servo_cli.py led                      # test LEDs
    python3 servo_cli.py reset                    # reset all to safe state
    python3 servo_cli.py snapshot                 # full status dump
    python3 servo_cli.py reg read 0x200           # raw register read
    python3 servo_cli.py reg write 0x002 0x55     # raw register write
    python3 servo_cli.py monitor [interval_ms]    # continuous monitoring
"""

import sys
import os
import time

sys.path.insert(0, os.path.dirname(__file__))
from servo_device import (
    ServoDevice, iir1_coeffs, iir2_coeffs, sweep_params,
    volts_to_dac24, dac24_to_volts, volts_to_raw16,
    OUTPUT_RANGES, INPUT_RANGES, AD5791_RANGE, DSP_CLK_HZ,
    INPUT_ADC0, INPUT_ADC1, INPUT_ADCDIFF, INPUT_LOCKIN, INPUT_PHASEDET,
    INPUT_DAC0, INPUT_DAC1, INPUT_DAC2,
)


def get_output_range(ch, gain=0):
    if ch == 2:
        return AD5791_RANGE
    return OUTPUT_RANGES[gain]


def cmd_status(dev, args):
    st = dev.status()
    print(f"Firmware ID:     0x{st['firmware_id']:08X}")
    print(f"PLL locked:      {st['pll_locked']}")
    print(f"AD9783 PLL:      {st['ad9783_pll_locked']}")
    print(f"RX packets:      {st['rx_packets']}")
    print(f"TX packets:      {st['tx_packets']}")
    print(f"Uptime:          {st['uptime_ticks']} ticks")


def cmd_adc(dev, args):
    n = int(args[0]) if args else 1
    for i in range(n):
        adc = dev.read_all_adc()
        print(f"AIN0: raw={adc['raw0']:+6d}  filt={adc['filt0']:+8d}  |  "
              f"AIN1: raw={adc['raw1']:+6d}  filt={adc['filt1']:+8d}")
        if n > 1 and i < n - 1:
            time.sleep(0.2)


def cmd_dac(dev, args):
    if not args or args[0] == 'read':
        for ch in range(3):
            raw = dev.read_dac(ch)
            vmin, vmax = get_output_range(ch)
            v = dac24_to_volts(raw, vmin, vmax)
            print(f"AOUT{ch}: {v:+.5f} V  (raw={raw:+d})")
    elif args[0] == 'zero':
        for ch in range(3):
            dev.set_dac(ch, 0)
        print("All DACs set to 0")
    elif args[0] == 'set':
        ch = int(args[1])
        voltage = float(args[2])
        vmin, vmax = get_output_range(ch)
        raw = volts_to_dac24(voltage, vmin, vmax)
        dev.set_dac(ch, raw)
        readback = dev.read_dac(ch)
        rb_v = dac24_to_volts(readback, vmin, vmax)
        print(f"AOUT{ch} = {voltage} V -> raw={raw}, readback={rb_v:+.5f} V")
    else:
        print("Usage: dac [read|zero|set <ch> <voltage>]")


def cmd_sweep(dev, args):
    if not args:
        print("Usage: sweep <ch> <Vpp_V> <freq_Hz>  or  sweep off [ch]")
        return
    if args[0] == 'off':
        channels = [int(args[1])] if len(args) > 1 else [0, 1, 2]
        for ch in channels:
            dev.set_sweep(ch, False)
            dev.servo_on(ch, False)
        print(f"Sweep off: ch {channels}")
        return

    ch = int(args[0])
    vpp = float(args[1])
    freq = float(args[2])
    vmin, vmax = get_output_range(ch)

    # Disable IIRs so sweep passes through cleanly
    dev.set_iir0(ch, False)
    dev.set_iir1(ch, False, a1=0, b0=0, b1=0)
    if ch < 2:
        dev.set_iir2(ch, False, a1=0, b0=0, b1=0)
        dev.set_iir3(ch, False, a1=0, b0=0, b1=0)
    dev.set_relock(ch, False)
    dev.set_limits(ch, -0x7FFF, 0x7FFF)

    mn, mx, step = sweep_params(0, vpp, freq, vmin, vmax)
    dev.set_sweep(ch, True, min_val=mn, max_val=mx, stepsize=step)
    dev.servo_on(ch, True)
    print(f"AOUT{ch}: sweep {vpp} Vpp @ {freq} Hz  (min={mn}, max={mx}, step={step})")


def cmd_servo(dev, args):
    if not args:
        print("Usage: servo on|off [ch]")
        return
    on = args[0].lower() == 'on'
    channels = [int(args[1])] if len(args) > 1 else [0, 1, 2]
    for ch in channels:
        dev.servo_on(ch, on)
    print(f"Servo {'ON' if on else 'OFF'}: ch {channels}")


def cmd_iir0(dev, args):
    """IIR0 (2nd order): iir0 <ch> <type> <freq_hz> [gain_db] [Q]"""
    if len(args) >= 2 and args[1] == 'off':
        ch = int(args[0])
        dev.set_iir0(ch, False)
        print(f"Ch{ch} IIR0 OFF")
        return
    if len(args) < 3:
        print("Usage: iir0 <ch> off  or  iir0 <ch> <type> <freq_hz> [gain_db] [Q]")
        print("Types: lowpass, highpass, notch, p, iho, off")
        return
    ch = int(args[0])
    ftype = args[1]
    freq = float(args[2])
    gain = float(args[3]) if len(args) > 3 else 0.0
    Q = float(args[4]) if len(args) > 4 else 0.707

    c = iir2_coeffs(ftype, freq, Q=Q, gain_db=gain,
                     a0_shift=26, update_every=27, fs=DSP_CLK_HZ)
    dev.set_iir0(ch, True, **c)
    print(f"Ch{ch} IIR0: {ftype} @ {freq} Hz, {gain} dB, Q={Q}")
    print(f"  a1={c['a1']:+d}  a2={c['a2']:+d}")
    print(f"  b0={c['b0']:+d}  b1={c['b1']:+d}  b2={c['b2']:+d}")


def cmd_iir1(dev, args):
    """IIR1 (1st order): iir1 <ch> <type> <freq_hz> [gain_db] [gain_limit_db]"""
    if len(args) >= 2 and args[1] == 'off':
        ch = int(args[0])
        dev.set_iir1(ch, False, a1=0, b0=0, b1=0)
        print(f"Ch{ch} IIR1 OFF")
        return
    if len(args) < 3:
        print("Usage: iir1 <ch> off  or  iir1 <ch> <type> <freq_hz> [gain_db] [gain_limit_db]")
        print("Types: lowpass, highpass, allpass, p, i, pi, pd, off")
        return
    ch = int(args[0])
    ftype = args[1]
    freq = float(args[2])
    gain = float(args[3]) if len(args) > 3 else 0.0
    glimit = float(args[4]) if len(args) > 4 else 81.0

    c = iir1_coeffs(ftype, freq, gain_db=gain, gain_limit_db=glimit,
                     a0_shift=26, fs=DSP_CLK_HZ)
    dev.set_iir1(ch, True, **c)
    print(f"Ch{ch} IIR1: {ftype} @ {freq} Hz, {gain} dB, limit={glimit} dB")
    print(f"  a1={c['a1']:+d}  b0={c['b0']:+d}  b1={c['b1']:+d}")


def cmd_mux(dev, args):
    """Set input mux: mux <ch> <source> [invert]"""
    if len(args) < 2:
        print("Usage: mux <ch> <source> [invert]")
        print("Sources: 0=ADC0, 1=ADC1, 2=ADCdiff, 3=LOCKIN, 4=PHASEDET, 5-7=DAC0-2")
        return
    ch = int(args[0])
    source = int(args[1])
    invert = len(args) > 2 and args[2].lower() == 'invert'
    dev.set_input_mux(ch, source, invert)
    names = ['ADC0', 'ADC1', 'ADCdiff', 'LOCKIN', 'PHASEDET', 'DAC0', 'DAC1', 'DAC2']
    sign = '-' if invert else '+'
    print(f"Ch{ch} input: {sign}{names[source]}")


def cmd_limits(dev, args):
    """Set output limits: limits <ch> <min_V> <max_V>"""
    if len(args) < 3:
        print("Usage: limits <ch> <min_V> <max_V>")
        return
    ch = int(args[0])
    vmin_out, vmax_out = get_output_range(ch)
    mn = volts_to_raw16(float(args[1]), vmin_out, vmax_out)
    mx = volts_to_raw16(float(args[2]), vmin_out, vmax_out)
    dev.set_limits(ch, mn, mx)
    print(f"Ch{ch} limits: {args[1]} V to {args[2]} V")


def cmd_offset(dev, args):
    """Set input offset: offset <ch> <voltage>"""
    if len(args) < 2:
        print("Usage: offset <ch> <voltage>")
        return
    ch = int(args[0])
    vmin, vmax = get_output_range(ch)
    raw = volts_to_raw16(float(args[1]), vmin, vmax)
    dev.set_offset(ch, raw)
    print(f"Ch{ch} offset: {args[1]} V")


def cmd_led(dev, args):
    if args and args[0] == 'off':
        for ch in range(3):
            dev.servo_on(ch, False)
        dev.write(0x002, 0xFF)
        print("LEDs off")
    elif args and args[0] == 'green':
        for ch in range(3):
            dev.set_limits(ch, -0x7FFF, 0x7FFF)
            dev.servo_on(ch, True)
        print("LEDs green")
    elif args and args[0] == 'red':
        for ch in range(3):
            dev.set_limits(ch, 100, 200)
            dev.servo_on(ch, True)
        print("LEDs red (forced railing)")
    else:
        print("Usage: led green|red|off")


def cmd_reset(dev, args):
    for ch in range(3):
        dev.servo_on(ch, False)
        dev.set_sweep(ch, False)
        dev.set_relock(ch, False)
        dev.set_dac(ch, 0)
        dev.set_limits(ch, -0x7FFF, 0x7FFF)
        dev.set_iir0(ch, False)
        dev.set_iir1(ch, False, a1=0, b0=0, b1=0)
        if ch < 2:
            dev.set_iir2(ch, False, a1=0, b0=0, b1=0)
            dev.set_iir3(ch, False, a1=0, b0=0, b1=0)
    dev.set_ramp(False)
    dev.set_input_gain(0, 0)
    dev.set_output_gain(0, 0)
    dev.set_adc_iir(0, False)
    dev.set_adc_iir(1, False)
    for ch in range(3):
        dev.set_lo_shift(ch, 31)
        dev.set_transfer_amplitude(ch, 31)
    dev.set_lockin_nco(0, 0)
    dev.set_lockin_iir0(False)
    dev.set_lockin_iir1(False)
    dev.set_transfer_freq(0)
    for pin in range(3):
        dev.set_dout_source(pin, 'status')
    print("All channels reset to safe defaults")


def cmd_snapshot(dev, args):
    st = dev.status()
    adc = dev.read_all_adc()
    servo = dev.read_all_servo()

    print(f"FW: 0x{st['firmware_id']:08X}  PLL: {'OK' if st['pll_locked'] else 'UNLOCKED'}  "
          f"RX: {st['rx_packets']}  TX: {st['tx_packets']}")
    print(f"AIN0: raw={adc['raw0']:+6d}  filt={adc['filt0']:+8d}")
    print(f"AIN1: raw={adc['raw1']:+6d}  filt={adc['filt1']:+8d}")

    for ch in range(3):
        s = servo[ch]
        dac_raw = dev.read_dac(ch)
        vmin, vmax = get_output_range(ch)
        dac_v = dac24_to_volts(dac_raw, vmin, vmax)
        servo_on = dev.read(dev.CH_BASE[ch])
        parts = []
        if s['railed'][0]:
            parts.append('RAIL-')
        if s['railed'][1]:
            parts.append('RAIL+')
        if s['relock_hold']:
            parts.append('HOLD')
        status = ' '.join(parts) if parts else 'ok'
        print(f"AOUT{ch}: servo={'ON' if servo_on & 1 else 'off'}  "
              f"dacin={s['dacin']:+8d}  direct={dac_v:+.4f}V  [{status}]")


def cmd_reg(dev, args):
    if len(args) < 2:
        print("Usage: reg read <addr>  or  reg write <addr> <value>")
        return
    if args[0] == 'read':
        addr = int(args[1], 0)
        val = dev.read(addr)
        signed = val if val < 0x80000000 else val - 0x100000000
        print(f"[0x{addr:03X}] = 0x{val:08X} ({signed:+d})")
    elif args[0] == 'write':
        addr = int(args[1], 0)
        val = int(args[2], 0)
        dev.write(addr, val)
        rb = dev.read(addr)
        print(f"[0x{addr:03X}] <- 0x{val:08X}, readback: 0x{rb:08X}")


def cmd_monitor(dev, args):
    interval = float(args[0]) / 1000.0 if args else 0.5
    print("Monitoring (Ctrl+C to stop)...")
    print(f"{'AIN0':>8s} {'AIN1':>8s} | {'AOUT0':>10s} {'AOUT1':>10s} {'AOUT2':>10s} | status")
    try:
        while True:
            adc = dev.read_all_adc()
            servo = dev.read_all_servo()
            parts = []
            for ch in range(3):
                s = servo[ch]
                if s['railed'][0] or s['railed'][1]:
                    parts.append(f'ch{ch}:RAIL')
                if s['relock_hold']:
                    parts.append(f'ch{ch}:HOLD')
            status = ' '.join(parts) if parts else 'ok'
            print(f"{adc['raw0']:+8d} {adc['raw1']:+8d} | "
                  f"{servo[0]['dacin']:+10d} {servo[1]['dacin']:+10d} {servo[2]['dacin']:+10d} | "
                  f"{status}")
            time.sleep(interval)
    except KeyboardInterrupt:
        print("\nStopped")


def cmd_passthrough(dev, args):
    """Pass input straight to output: passthrough <out_ch> <in_source> [invert]
    Example: passthrough 1 0        # AIN0 -> AOUT1
             passthrough 0 1 invert # -AIN1 -> AOUT0
    """
    if len(args) < 2:
        print("Usage: passthrough <out_ch> <in_source> [invert]")
        print("Sources: 0=ADC0, 1=ADC1, 2=ADCdiff, 3=LOCKIN, 4=PHASEDET")
        return
    ch = int(args[0])
    source = int(args[1])
    invert = len(args) > 2 and args[2].lower() == 'invert'

    # IIR0 P-mode unity (handles full 24-bit range correctly).
    # IIR1 P-mode unity (safe because IIR0 P output is within 18-bit range).
    c0 = iir2_coeffs('p', 1000, gain_db=0, a0_shift=26, update_every=27)
    dev.set_iir0(ch, True, **c0)
    A0 = 1 << 26
    dev.set_iir1(ch, True, a1=0, b0=A0, b1=0)
    if ch < 2:
        dev.set_iir2(ch, False, a1=0, b0=0, b1=0)
        dev.set_iir3(ch, False, a1=0, b0=0, b1=0)
    dev.set_relock(ch, False)
    dev.set_sweep(ch, False)
    dev.set_limits(ch, -0x7FFF, 0x7FFF)
    dev.set_input_mux(ch, source, invert)
    dev.set_offset(ch, 0)
    dev.servo_on(ch, True)

    names = ['ADC0', 'ADC1', 'ADCdiff', 'LOCKIN', 'PHASEDET', 'DAC0', 'DAC1', 'DAC2']
    sign = '-' if invert else ''
    print(f"Passthrough: {sign}{names[source]} -> AOUT{ch}")


def cmd_flash_id(dev, args):
    """Read the M25P32 JEDEC ID (sanity check for the flash transport)."""
    mfg, mtype, cap = dev.flash_read_id()
    print(f"Flash JEDEC ID: 0x{mfg:02X} 0x{mtype:02X} 0x{cap:02X}", end='')
    if (mfg, mtype, cap) == (0x20, 0x20, 0x16):
        print("  (Micron M25P32, OK)")
    else:
        print("  (UNEXPECTED - expected 0x20 0x20 0x16)")


def cmd_net_config(dev, args):
    """Show the stored FPGA MAC/IP and boot/recovery status."""
    nc = dev.read_network_config()
    if nc is None:
        print('Stored network config: NONE (board boots at compiled-in default)')
    else:
        print(f"Stored network config: MAC {nc['mac']}  IP {'.'.join(map(str, nc['ip']))}")
    st = dev.recovery_status()
    print(f"Boot status: eth_clk_locked={st['eth_clk_locked']} "
          f"boot_done={st['boot_done']} recovery_active={st['net_recovery']}")
    if st['net_recovery']:
        print('  -> running on RECOVERY default address (DOUT1->DIN1 loopback detected)')


def cmd_set_net_config(dev, args):
    """set-net-config <MAC> <IP> - store the FPGA's MAC/IP in flash."""
    if len(args) < 2:
        print('Usage: set-net-config <MAC> <IP>')
        print('   e.g. set-net-config AA:00:55:00:01:23 192.168.7.140')
        return
    mac = int(args[0].replace(':', '').replace('-', ''), 16)
    ip = tuple(int(x) for x in args[1].split('.'))
    r = dev.set_network_config(mac, ip)
    print(f"Stored MAC {r['mac']}  IP {'.'.join(map(str, r['ip']))} to flash.")
    print('Takes effect on NEXT power-cycle/reprogram; then reconnect at the new IP.')
    print('Recovery: jumper DOUT[1]->DIN[1] and power-cycle to force the default.')


def cmd_dout(dev, args):
    """dout [<pin> status|sync <ch>] - route a DOUT pin to a signal source.

    No args: show the current routing of all three DOUT pins.
      dout <pin> status      -> relock-hold status (default)
      dout <pin> sync <ch>   -> sweep sync (high on rising half) of channel <ch>
    """
    if not args:
        srcs = dev.get_dout_sources()
        for pin, s in enumerate(srcs):
            if s == 'status':
                print(f"DOUT[{pin}]: status (relock-hold)")
            else:
                print(f"DOUT[{pin}]: sweep-sync ch{s[4:]}")
        return
    pin = int(args[0])
    if len(args) < 2:
        print('Usage: dout <pin> status   |   dout <pin> sync <ch>')
        return
    what = args[1].lower()
    if what == 'status':
        dev.set_dout_source(pin, 'status')
        print(f"DOUT[{pin}] -> status (relock-hold)")
    elif what == 'sync':
        if len(args) < 3:
            print('Usage: dout <pin> sync <ch>')
            return
        ch = int(args[2])
        dev.set_dout_source(pin, ch)
        print(f"DOUT[{pin}] -> sweep-sync ch{ch} (high on rising half, low on falling)")
    else:
        print('Usage: dout <pin> status   |   dout <pin> sync <ch>')


def cmd_save_config(dev, args):
    """Snapshot the current register config to flash."""
    print("Saving config to flash (erase + program + verify)...")
    n = dev.save_config()
    print(f"Saved {n} registers to flash @ 0x{dev.CONFIG_FLASH_ADDR:06X}")


def cmd_load_config(dev, args):
    """Load config from flash and apply it to the registers."""
    n = dev.load_config()
    if n is None:
        print("No valid config in flash (blank/bad magic/CRC) - registers unchanged")
    else:
        print(f"Loaded and applied {n} registers from flash")


COMMANDS = {
    'status': cmd_status,
    'adc': cmd_adc,
    'dac': cmd_dac,
    'sweep': cmd_sweep,
    'servo': cmd_servo,
    'iir0': cmd_iir0,
    'iir1': cmd_iir1,
    'mux': cmd_mux,
    'limits': cmd_limits,
    'offset': cmd_offset,
    'led': cmd_led,
    'reset': cmd_reset,
    'snapshot': cmd_snapshot,
    'reg': cmd_reg,
    'monitor': cmd_monitor,
    'passthrough': cmd_passthrough,
    'dout': cmd_dout,
    'flash-id': cmd_flash_id,
    'save-config': cmd_save_config,
    'load-config': cmd_load_config,
    'net-config': cmd_net_config,
    'set-net-config': cmd_set_net_config,
}


def main():
    argv = sys.argv[1:]
    host = '192.168.7.140'
    if '--host' in argv:
        i = argv.index('--host')
        if i + 1 >= len(argv):
            print("error: --host requires an IP address argument")
            sys.exit(2)
        host = argv[i + 1]
        del argv[i:i + 2]

    if not argv or argv[0] in ('-h', '--help', 'help'):
        print(__doc__)
        print("Use --host <IP> to target a non-default FPGA address.")
        sys.exit(0)

    dev = ServoDevice(host=host)
    cmd = argv[0]
    args = argv[1:]

    if cmd in COMMANDS:
        COMMANDS[cmd](dev, args)
    else:
        print(f"Unknown command: {cmd}")
        print(f"Available: {', '.join(COMMANDS.keys())}")
        sys.exit(1)


if __name__ == '__main__':
    main()
