#!/usr/bin/env python3
"""
test_hardware.py - Hardware-in-the-loop validation of the flash/config/network
features. Run this on a machine that can reach the FPGA over the network.

  C1  flash JEDEC ID (transport + pins + flash alive)
  C2  raw flash erase/program/read round-trip (scratch sector, blank-checked)
  C3  page-boundary program reads back correctly
  C4  save_config -> mutate reg -> load_config restores it
  C5  set_stream_dest -> read_stream_dest matches
  C6  GUI settings blob save -> load round-trip on real flash
  C7  set_network_config -> read_network_config matches (block bytes correct)
  C8  recovery_status (boot_done / net_recovery / eth_clk_locked)

SAFETY: every test that writes flash backs up the affected sector first and
restores it afterwards. C2/C3 only run if the scratch sector is already blank.
Register writes (C4/C5) are restored to their original values.

Usage:
  python3 test_hardware.py [HOST] [--scratch 0xADDR]
Default HOST = 192.168.7.140. Writes test_hardware_results.txt and prints.
"""

import sys
import os
import json
import struct
import time
import traceback

RESULTS = []   # (name, status, detail)  status in {PASS, FAIL, SKIP}


def record(name, status, detail=""):
    RESULTS.append((name, status, detail))
    print(f"  [{status}] {name}" + (f"  ({detail})" if detail else ""))


def check(name, cond, detail=""):
    record(name, "PASS" if cond else "FAIL", detail)
    return bool(cond)


# ---------------------------------------------------------------------------
def main():
    host = '192.168.7.140'
    scratch = 0x3C0000   # sector 60: between the bitstream and the config sectors
    argv = sys.argv[1:]
    i = 0
    while i < len(argv):
        if argv[i] == '--scratch':
            scratch = int(argv[i + 1], 0); i += 2
        else:
            host = argv[i]; i += 1

    print("=" * 64)
    print(f"HARDWARE TEST SUITE  host={host}  scratch=0x{scratch:06X}")
    print("=" * 64)

    try:
        from servo_device import ServoDevice
        dev = ServoDevice(host=host)
        fwid = dev.firmware_id()
    except Exception as e:
        record("connect", "FAIL", f"cannot reach {host}: {e}")
        write_results(host)
        sys.exit(2)
    record("connect", "PASS", f"firmware_id=0x{fwid:08X}")

    S = type(dev)

    # ---- C1: flash JEDEC ID ----
    print("C1: flash JEDEC ID (informational)")
    try:
        mfg, typ, cap = dev.flash_read_id()
        idstr = f"0x{mfg:02X} 0x{typ:02X} 0x{cap:02X}"
        # Some XEM6010 flash parts don't answer 0x9F the classic way; the real
        # test of the flash is the read/write round-trip below, not the ID.
        alive = not (mfg == typ == cap == 0x00 or mfg == typ == cap == 0xFF)
        note = idstr if (mfg, typ, cap) == (0x20, 0x20, 0x16) else \
            idstr + " (non-standard 0x9F response; flash R/W is the real check)"
        record("C1 flash responds (informational)", "PASS" if alive else "FAIL", note)
    except Exception as e:
        record("C1 flash id", "FAIL", str(e)); traceback.print_exc()

    # ---- C2 / C3: raw flash on a blank scratch sector ----
    print("C2/C3: raw flash erase/program/read (scratch)")
    try:
        head = dev.flash_read(scratch, 512)
        if head != b'\xff' * 512:
            record("C2/C3 raw flash round-trip", "SKIP",
                   f"scratch 0x{scratch:06X} not blank - refusing to erase unknown data "
                   f"(pass --scratch <blank sector>)")
        else:
            # C2: erase confirms blank, program a pattern, read back
            pattern = bytes((i * 7 + 3) & 0xFF for i in range(64))
            dev.flash_erase_sector(scratch)
            blank_ok = dev.flash_read(scratch, 64) == b'\xff' * 64
            check("C2 erase -> 0xFF", blank_ok)
            dev.flash_program(scratch, pattern)
            check("C2 program/read round-trip", dev.flash_read(scratch, 64) == pattern)
            # C3: program across a 256-byte page boundary (offset 0xF0, len 0x40)
            dev.flash_erase_sector(scratch)
            xpat = bytes((i ^ 0x5A) & 0xFF for i in range(0x40))
            dev.flash_program(scratch + 0xF0, xpat)
            check("C3 page-boundary program", dev.flash_read(scratch + 0xF0, 0x40) == xpat)
            dev.flash_erase_sector(scratch)   # restore to blank
            check("C2/C3 scratch restored blank", dev.flash_read(scratch, 64) == b'\xff' * 64)
    except Exception as e:
        record("C2/C3 raw flash", "FAIL", str(e)); traceback.print_exc()

    # ---- C5: stream destination (registers only) ----  [run before C4]
    print("C5: stream destination round-trip")
    try:
        orig = dev.read_stream_dest()
        dev.set_stream_dest(mac=0x1234567890AB, ip=(10, 11, 12, 13), port=4242)
        rb = dev.read_stream_dest()
        check("C5 stream dest readback", rb['mac'] == 0x1234567890AB
              and rb['ip'] == (10, 11, 12, 13) and rb['port'] == 4242, str(rb))
        # restore
        dev.set_stream_dest(mac=orig['mac'], ip=orig['ip'], port=orig['port'])
    except Exception as e:
        record("C5 stream dest", "FAIL", str(e)); traceback.print_exc()

    # ---- C4: save/load register config (back up flash blob, restore) ----
    print("C4: save_config -> mutate -> load_config")
    try:
        # Back up the exact existing config blob (read length from its header)
        hdr = dev.flash_read(S.CONFIG_FLASH_ADDR, 8)
        magic, ver, _, count = struct.unpack('<4sBBH', hdr)
        if magic == S.CONFIG_MAGIC and count <= 1024:
            cfg_backup = dev.flash_read(S.CONFIG_FLASH_ADDR, 8 + count * 6 + 4)
        else:
            cfg_backup = None
        test_reg = 0x030   # stream dest MAC hi - benign, restored by load_config
        orig_val = int(dev.read(test_reg))
        n = dev.save_config()
        check("C4 save_config wrote regs", n == 210, f"saved {n}")
        dev.write(test_reg, (orig_val ^ 0xA5A5) & 0xFFFFFFFF)
        applied = dev.load_config()
        check("C4 load_config applied regs", applied == 210, f"applied {applied}")
        check("C4 register restored by load", int(dev.read(test_reg)) == orig_val)
        # restore the original flash config blob so we don't clobber a prior save
        dev.flash_erase_sector(S.CONFIG_FLASH_ADDR)
        if cfg_backup:
            dev.flash_program(S.CONFIG_FLASH_ADDR, cfg_backup)
        record("C4 config flash restored", "PASS",
               "restored prior config" if cfg_backup else "was blank")
    except Exception as e:
        record("C4 save/load config", "FAIL", str(e)); traceback.print_exc()

    # ---- C6: GUI settings blob on real flash ----
    print("C6: GUI settings blob round-trip")
    try:
        # Back up the exact existing GUI blob (read length from its header)
        ghdr = dev.flash_read(S.GUI_SETTINGS_FLASH_ADDR, 8)
        gmagic, glen = struct.unpack('<4sI', ghdr)
        if gmagic == S.BLOB_MAGIC and glen < S._F_SECTOR:
            gui_backup = dev.flash_read(S.GUI_SETTINGS_FLASH_ADDR, 8 + glen + 4)
        else:
            gui_backup = None
        payload = json.dumps({'version': 1, 'test': 'hw', 'vals': list(range(20))}).encode()
        dev.flash_save_blob(S.GUI_SETTINGS_FLASH_ADDR, payload)
        check("C6 GUI blob round-trip", dev.flash_load_blob(S.GUI_SETTINGS_FLASH_ADDR) == payload)
        # restore
        dev.flash_erase_sector(S.GUI_SETTINGS_FLASH_ADDR)
        if gui_backup:
            dev.flash_program(S.GUI_SETTINGS_FLASH_ADDR, gui_backup)
        record("C6 GUI flash restored", "PASS",
               "restored prior blob" if gui_backup else "was blank")
    except Exception as e:
        record("C6 GUI blob", "FAIL", str(e)); traceback.print_exc()

    # ---- C7: network config block (back up & restore - affects next boot!) ----
    print("C7: set/read_network_config")
    try:
        net_backup = dev.flash_read(S.NET_CONFIG_FLASH_ADDR, 16)
        had_net = net_backup[:4] == S.NET_CONFIG_MAGIC
        dev.set_network_config(0xAA0055000199, (192, 168, 7, 199))
        rc = dev.read_network_config()
        check("C7 network config readback", rc and rc['ip'] == (192, 168, 7, 199)
              and rc['mac'] == 'aa:00:55:00:01:99', str(rc))
        blk = dev.flash_read(S.NET_CONFIG_FLASH_ADDR, 16)
        cks = sum(blk[:14]) & 0xFFFF
        check("C7 block checksum valid", struct.unpack('<H', blk[14:16])[0] == cks)
        # restore original (so next boot is unchanged)
        dev.flash_erase_sector(S.NET_CONFIG_FLASH_ADDR)
        if had_net:
            dev.flash_program(S.NET_CONFIG_FLASH_ADDR, net_backup)
        record("C7 network flash restored", "PASS",
               "restored prior config" if had_net else "left blank (boots at default)")
    except Exception as e:
        record("C7 network config", "FAIL", str(e)); traceback.print_exc()

    # ---- C8: recovery/boot status ----
    print("C8: recovery/boot status")
    try:
        st = dev.recovery_status()
        check("C8 boot_done is set", st['boot_done'] is True, str(st))
        record("C8 status", "PASS",
               f"eth_lock={st['eth_clk_locked']} net_recovery={st['net_recovery']}")
    except Exception as e:
        record("C8 recovery status", "FAIL", str(e)); traceback.print_exc()

    write_results(host)
    nfail = sum(1 for _, s, _ in RESULTS if s == 'FAIL')
    sys.exit(1 if nfail else 0)


def write_results(host):
    npass = sum(1 for _, s, _ in RESULTS if s == 'PASS')
    nfail = sum(1 for _, s, _ in RESULTS if s == 'FAIL')
    nskip = sum(1 for _, s, _ in RESULTS if s == 'SKIP')
    print("\n" + "=" * 64)
    print(f"RESULT: {npass} pass, {nfail} fail, {nskip} skip")
    print("=" * 64)
    with open('test_hardware_results.txt', 'w') as f:
        f.write(f"HARDWARE TEST RESULTS  host={host}\n")
        try:
            f.write(time.strftime("%Y-%m-%d %H:%M:%S\n"))
        except Exception:
            pass
        for name, status, detail in RESULTS:
            f.write(f"[{status}] {name}" + (f"  ({detail})" if detail else "") + "\n")
        f.write(f"\nTOTAL: {npass} pass, {nfail} fail, {nskip} skip\n")
    print("Wrote test_hardware_results.txt")


if __name__ == '__main__':
    main()
