#!/usr/bin/env python3
"""
test_flash_mosi.py - flash write-debug diagnostic for the `flash_top` variant
(firmware ID 0xBA5E0F1A), using FlashSpiDevice from base_device.

flash_top is the clocks+Badger scaffold with flash_spi bolted on PLUS a 64-bit
MOSI capture: the bits actually driven onto the MOSI pad are sampled at each SCK
rising edge into regs 0x048/0x049 (frozen on the first 64 bits, so the
command+address header always survives).

The SCK-edge counter already proved the FPGA emits exactly 8*len clean clocks.
The remaining FPGA-side unknown is the DATA on MOSI. This test:

  1. Confirms we're talking to the flash variant.
  2. RDID round-trip + verifies the FPGA drove 0x9F,0,0,0 on MOSI.
  3. The decisive write test: WREN, then read status -- is WEL (bit1) set?
  4. A short PAGE PROGRAM with capture + readback.

Usage: python3 test_flash_mosi.py [HOST]
Writes test_flash_mosi_results.txt.
"""
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from base_device import FlashSpiDevice   # noqa: E402

OUT = []


def log(s):
    print(s); OUT.append(str(s))


def hexb(bs):
    return ' '.join('%02X' % b for b in bytes(bs))


def main():
    host = sys.argv[1] if len(sys.argv) > 1 else '192.168.7.140'
    dev = FlashSpiDevice(host)

    log("FLASH MOSI DIAGNOSTIC  host=%s" % host)
    log("=" * 60)

    fwid = dev.firmware_id()
    log("[1] firmware ID = 0x%08X (expect 0x%08X) -> %s"
        % (fwid, dev.EXPECT_FWID, "OK" if fwid == dev.EXPECT_FWID else "WRONG BITSTREAM"))
    if fwid != dev.EXPECT_FWID:
        log("    Not the flash_top variant; program base/flash.bit. Aborting.")
        _write(); return

    # 2. RDID + MOSI capture
    jedec = dev.read_id()
    drove = dev.mosi_capture(4)
    log("[2] RDID: JEDEC readback = %s (expect 20 20 16)" % hexb(jedec))
    log("    MOSI drove           = %s (expect 9F 00 00 00)" % hexb(drove))
    log("    -> MOSI command byte %s" % ("CORRECT" if drove and drove[0] == 0x9F else "WRONG"))
    log("    SCK edges last xfer  = %d (expect 32)" % dev.sck_count())

    # 3. Decisive: does WREN set the WEL status bit?
    dev.wren()
    wren_drove = dev.mosi_capture(1)
    sr = dev.rdsr()
    wel = (sr >> 1) & 1
    log("[3] WREN then RDSR: status = 0x%02X  WEL(bit1) = %d -> %s"
        % (sr, wel, "WREN REACHES FLASH" if wel else "WREN NOT LANDING"))
    log("    MOSI drove for WREN  = %s (expect 06)" % hexb(wren_drove))

    # 4. Short PAGE PROGRAM with capture + readback
    addr = 0x3C0000          # scratch sector 60
    data = bytes([0xDE, 0xAD, 0xBE, 0xEF])
    dev.erase_sector(addr)
    blank = dev.flash_read(addr, 4)
    log("[4] erased sector 0x%06X -> %s (expect FF FF FF FF)" % (addr, hexb(blank)))

    dev.wren()
    pp = bytes([0x02, (addr >> 16) & 0xFF, (addr >> 8) & 0xFF, addr & 0xFF]) + data
    dev.xfer(pp)             # PAGE PROGRAM (8 bytes)
    log("    PP MOSI drove = %s" % hexb(dev.mosi_capture(len(pp))))
    log("    PP expected   = %s" % hexb(pp))
    dev.wait_wip()
    back = dev.flash_read(addr, 4)
    log("    readback after PP = %s (wrote %s) -> %s"
        % (hexb(back), hexb(data), "PROGRAM OK" if back == data else "PROGRAM FAILED"))

    dev.erase_sector(addr)   # restore blank

    log("=" * 60)
    log("KEY: if [3] shows WEL=1 but [4] readback stays FF, the data phase /")
    log("CS-deassert timing of PAGE PROGRAM is the suspect, not WREN or clocking.")
    _write()


def _write():
    with open('test_flash_mosi_results.txt', 'w') as f:
        f.write("\n".join(OUT) + "\n")
    print("\nWrote test_flash_mosi_results.txt")


if __name__ == '__main__':
    main()
