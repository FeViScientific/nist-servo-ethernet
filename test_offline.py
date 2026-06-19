#!/usr/bin/env python3
"""
test_offline.py - Offline validation of the flash/config/network features.

No FPGA required. Validates the pure-logic and GUI layers:
  B1  config_regs: 210 unique, no overlap with flash control regs
  B2  register snapshot serialize/parse round-trip + CRC/version guard
  B3  GUI blob (SLBL): save/load round-trip; blank->None; corrupt CRC->None
  B4  network block (NCF1): byte-exact FPGA block, checksum, blank/bad->None, input forms
  B5  all GUI panels get->apply->get stable + apply pushes to device (offscreen Qt)
  B6  MainWindow aggregate save->perturb->load restores exactly
  B7  three flash sectors distinct; Python word-packing matches HDL buffer order

Writes results to test_offline_results.txt and prints a summary.
Run:  python3 test_offline.py
"""

import sys
import os
import io
import json
import struct
import zlib
import traceback

RESULTS = []


def check(name, cond, detail=""):
    RESULTS.append((name, bool(cond), detail))
    print(f"  [{'PASS' if cond else 'FAIL'}] {name}" + (f"  ({detail})" if detail else ""))
    return bool(cond)


# In-memory flash model shared by several tests
def make_flash_device():
    from servo_device import ServoDevice as S
    dev = object.__new__(S)
    flash = bytearray(b'\xff' * 0x400000)
    SECT = S._F_SECTOR

    def erase(a):
        base = a & ~(SECT - 1)
        flash[base:base + SECT] = b'\xff' * SECT

    def program(a, d):
        flash[a:a + len(d)] = bytes(d)

    def read(a, n):
        return bytes(flash[a:a + n])

    dev.flash_erase_sector = erase
    dev.flash_program = program
    dev.flash_read = read
    return dev, flash, S


# ---------------------------------------------------------------------------
def test_B1_config_regs():
    print("B1: config_regs")
    from servo_device import ServoDevice as S
    regs = S.config_regs()
    check("B1.1 count == 210", len(regs) == 210, f"got {len(regs)}")
    check("B1.2 all unique", len(set(regs)) == len(regs))
    flash_ctrl = set([0x044, 0x045, 0x046]) | set(range(0x800, 0x880))
    check("B1.3 no overlap with flash regs", not (set(regs) & flash_ctrl))
    check("B1.4 includes stream dest 0x030", 0x030 in regs)
    check("B1.5 includes ch2 base 0x500", 0x500 in regs)
    check("B1.6 includes PD lp 0x714", 0x714 in regs)


def test_B2_register_snapshot():
    print("B2: register snapshot serialize/parse")
    dev, flash, S = make_flash_device()
    regs = S.config_regs()
    vals = [(i * 2654435761) & 0xFFFFFFFF for i in range(len(regs))]
    blob = dev._config_serialize(regs, vals)
    magic, ver, _, count = struct.unpack('<4sBBH', blob[:8])
    check("B2.1 magic SLLC", magic == S.CONFIG_MAGIC)
    check("B2.2 version", ver == S.CONFIG_VERSION)
    check("B2.3 count", count == len(regs))
    total = 8 + count * 6 + 4
    crc = struct.unpack_from('<I', blob, total - 4)[0]
    check("B2.4 crc valid", zlib.crc32(blob[:total - 4]) & 0xFFFFFFFF == crc)
    pairs = [struct.unpack_from('<HI', blob, 8 + 6 * i) for i in range(count)]
    check("B2.5 addr round-trip", [a for a, _ in pairs] == regs)
    check("B2.6 value round-trip", [v for _, v in pairs] == vals)


def test_B3_gui_blob():
    print("B3: GUI blob (SLBL)")
    dev, flash, S = make_flash_device()
    addr = S.GUI_SETTINGS_FLASH_ADDR
    payload = json.dumps({'version': 1, 'x': [1, 2, 3], 's': 'abc'}).encode()
    n = dev.flash_save_blob(addr, payload)
    check("B3.1 save returns len", n == len(payload))
    check("B3.2 load round-trip", dev.flash_load_blob(addr) == payload)
    check("B3.3 blank -> None", dev.flash_load_blob(0x100000) is None)
    # corrupt one byte of the framed blob
    flash[addr + 10] ^= 0xFF
    check("B3.4 corrupt CRC -> None", dev.flash_load_blob(addr) is None)


def test_B4_network_block():
    print("B4: network block (NCF1)")
    dev, flash, S = make_flash_device()
    r = dev.set_network_config(0xAA0055000123, (192, 168, 7, 140))
    block = dev.flash_read(S.NET_CONFIG_FLASH_ADDR, 16)
    expect = bytes([0x4E, 0x43, 0x46, 0x31, 0xAA, 0x00, 0x55, 0x00, 0x01, 0x23,
                    0xC0, 0xA8, 0x07, 0x8C, 0x26, 0x04])
    check("B4.1 byte-exact FPGA block", block == expect, block.hex())
    rc = dev.read_network_config()
    check("B4.2 read round-trip", rc and rc['ip'] == (192, 168, 7, 140)
          and rc['mac'] == 'aa:00:55:00:01:23')
    dev.flash_erase_sector(S.NET_CONFIG_FLASH_ADDR)
    check("B4.3 blank -> None", dev.read_network_config() is None)
    dev.set_network_config(0xAA0055000123, (192, 168, 7, 140))
    flash[S.NET_CONFIG_FLASH_ADDR + 5] ^= 0xFF   # corrupt MAC byte (checksum mismatch)
    check("B4.4 bad checksum -> None", dev.read_network_config() is None)
    # input forms
    b2 = dev.set_network_config(bytes([0xAA, 0, 0x55, 0, 1, 0x23]), 0xC0A8078C)
    check("B4.5 bytes-MAC / int-IP forms", b2['ip'] == (192, 168, 7, 140))


def test_B8_dout_source():
    print("B8: DOUT source select (reg 0x022)")
    from servo_device import ServoDevice as S
    dev = object.__new__(S)
    regs = {S.REG_DOUT_SRC: 0}
    dev.read = lambda a: regs.get(a, 0)
    dev.write = lambda a, v: regs.__setitem__(a, int(v) & 0xFFFFFFFF)

    # default: all status
    check("B8.1 default all status", dev.get_dout_sources() == ['status', 'status', 'status'])
    # route DOUT1 -> sweep sync ch2, leave others; field [3:2] = code 3
    dev.set_dout_source(1, 'sync2')
    check("B8.2 pin1 -> sync2 field", regs[S.REG_DOUT_SRC] == (3 << 2), hex(regs[S.REG_DOUT_SRC]))
    check("B8.3 others untouched", dev.get_dout_sources() == ['status', 'sync2', 'status'])
    # route DOUT0 -> sync0 (int form), DOUT2 -> sync1; check independent packing
    dev.set_dout_source(0, 0)
    dev.set_dout_source(2, 'sync1')
    check("B8.4 independent fields", dev.get_dout_sources() == ['sync0', 'sync2', 'sync1'],
          hex(regs[S.REG_DOUT_SRC]))
    # bit layout: pin0=1, pin1=3, pin2=2 -> 0b10_11_01 = 0x2D
    check("B8.5 bit packing", regs[S.REG_DOUT_SRC] == 0x2D, hex(regs[S.REG_DOUT_SRC]))
    # reset a pin back to status
    dev.set_dout_source(1, 'status')
    check("B8.6 back to status", dev.get_dout_sources() == ['sync0', 'status', 'sync1'])
    # invalid inputs rejected
    try:
        dev.set_dout_source(3, 'status'); ok = False
    except ValueError:
        ok = True
    check("B8.7 bad pin rejected", ok)
    try:
        dev.set_dout_source(0, 'sync3'); ok = False
    except ValueError:
        ok = True
    check("B8.8 bad channel rejected", ok)


def test_B7_sectors_and_byteorder():
    print("B7: flash sectors + byte order")
    from servo_device import ServoDevice as S
    secs = {S.NET_CONFIG_FLASH_ADDR & ~(S._F_SECTOR - 1),
            S.GUI_SETTINGS_FLASH_ADDR & ~(S._F_SECTOR - 1),
            S.CONFIG_FLASH_ADDR & ~(S._F_SECTOR - 1)}
    check("B7.1 three distinct sectors", len(secs) == 3, str([hex(x) for x in sorted(secs)]))
    # Python packs bytes little-endian into 32-bit words; byte0 -> bits[7:0],
    # matching flash_spi.v buffer layout.
    word = struct.unpack('<I', bytes([0x03, 0x3D, 0xAB, 0xCD]))[0]
    check("B7.2 word packing byte0=[7:0]", (word & 0xFF) == 0x03 and ((word >> 24) & 0xFF) == 0xCD,
          hex(word))


def test_B5_B6_gui():
    print("B5/B6: GUI panels + MainWindow (offscreen Qt)")
    os.environ.setdefault('QT_QPA_PLATFORM', 'offscreen')
    try:
        from unittest.mock import MagicMock
        from PyQt5.QtWidgets import QApplication
    except Exception as e:
        check("B5/B6 Qt available", False, f"skipped: {e}")
        return
    from servo_device import ServoDevice as S
    app = QApplication.instance() or QApplication(sys.argv)
    import servo_gui as g

    dev = MagicMock()
    dev.read_input_gain.return_value = (0, 0)
    dev.read_output_gain.return_value = (0, 0)

    def roundtrip(name, make, mutate):
        p1 = make(); mutate(p1); s1 = p1.get_settings()
        p2 = make(); dev.reset_mock(); p2.apply_settings(s1); s2 = p2.get_settings()
        check(f"B5 {name} get/apply stable", s1 == s2)
        check(f"B5 {name} apply drives device", bool(dev.method_calls))

    roundtrip("InputPanel", lambda: g.InputPanel(dev, 0),
              lambda p: (p.range_combo.setCurrentIndex(1), p.iir_on.setChecked(True),
                         p.iir_freq.setValue(7777)))
    roundtrip("OutputPanel-fast", lambda: g.OutputPanel(dev, 0),
              lambda p: (p.servo_btn.setChecked(True), p.iir0_group.setChecked(True),
                         p.iir0_group._w['freq'].setValue(2222), p.limit_max.setValue(3.1),
                         p.iir2_group.setChecked(True)))
    roundtrip("OutputPanel-slow", lambda: g.OutputPanel(dev, 2),
              lambda p: (p.servo_btn.setChecked(True), p.iir0_group._w['freq'].setValue(999)))
    roundtrip("LockInPanel", lambda: g.LockInPanel(dev),
              lambda p: (p.freq_spin.setValue(50000), p.pre_on.setChecked(True)))
    roundtrip("PhaseDetPanel", lambda: g.PhaseDetPanel(dev),
              lambda p: (p.ext_clk.setChecked(True), p.lp_on.setChecked(True),
                         p.lp_gain.setValue(8)))

    # B6: MainWindow aggregate save->perturb->load
    dev2 = MagicMock()
    dev2.read_input_gain.return_value = (0, 0)
    dev2.read_output_gain.return_value = (0, 0)
    dev2.GUI_SETTINGS_FLASH_ADDR = S.GUI_SETTINGS_FLASH_ADDR
    realdev, flash, _ = make_flash_device()
    dev2.flash_save_blob = realdev.flash_save_blob
    dev2.flash_load_blob = realdev.flash_load_blob
    dev2.status.return_value = {'firmware_id': 0x201, 'pll_locked': True, 'rx_packets': 0,
                               'tx_packets': 0, 'uptime_ticks': 0, 'ad9783_pll_locked': True}
    try:
        win = g.MainWindow(dev2)  # auto-load finds blank flash -> defaults
        win.aout0.servo_btn.setChecked(True)
        win.aout0.iir1_group.setChecked(True); win.aout0.iir1_group._w['freq'].setValue(4321)
        win.ain1.iir_on.setChecked(True); win.ain1.iir_freq.setValue(7777)
        win.lockin.freq_spin.setValue(33333)
        target = json.loads(json.dumps(win.get_all_settings()))
        dev2.flash_save_blob(S.GUI_SETTINGS_FLASH_ADDR,
                             json.dumps(win.get_all_settings()).encode())
        win.aout0.servo_btn.setChecked(False); win.lockin.freq_spin.setValue(1)
        check("B6.1 perturb changed state", win.get_all_settings() != target)
        ok = win._load_settings_flash()
        check("B6.2 load returned True", ok)
        check("B6.3 aggregate restored exactly",
              json.loads(json.dumps(win.get_all_settings())) == target)
    except Exception as e:
        check("B6 MainWindow round-trip", False, f"exception: {e}")
        traceback.print_exc()


def main():
    print("=" * 64)
    print("OFFLINE TEST SUITE - flash/config/network features")
    print("=" * 64)
    for fn in [test_B1_config_regs, test_B2_register_snapshot, test_B3_gui_blob,
               test_B4_network_block, test_B7_sectors_and_byteorder, test_B5_B6_gui,
               test_B8_dout_source]:
        try:
            fn()
        except Exception as e:
            check(f"{fn.__name__} (unexpected exception)", False, str(e))
            traceback.print_exc()

    npass = sum(1 for _, ok, _ in RESULTS if ok)
    nfail = len(RESULTS) - npass
    summary = f"\n{'=' * 64}\nRESULT: {npass}/{len(RESULTS)} passed, {nfail} failed\n{'=' * 64}"
    print(summary)

    with open('test_offline_results.txt', 'w') as f:
        f.write("OFFLINE TEST RESULTS (flash/config/network)\n")
        for name, ok, detail in RESULTS:
            f.write(f"[{'PASS' if ok else 'FAIL'}] {name}" + (f"  ({detail})" if detail else "") + "\n")
        f.write(f"\nTOTAL: {npass}/{len(RESULTS)} passed, {nfail} failed\n")
    print("Wrote test_offline_results.txt")
    sys.exit(1 if nfail else 0)


if __name__ == '__main__':
    main()
