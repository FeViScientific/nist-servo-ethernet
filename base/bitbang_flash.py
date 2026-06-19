#!/usr/bin/env python3
"""
bitbang_flash.py - self-test for the `bitbang_top` variant (firmware 0xBA5E0B1B).

The driver itself is BitBangDevice in base_device.py: it drives SCK/MOSI/CS as
raw register bits (0x050) and reads MISO (0x051), so the host owns every SPI
edge. This is the lowest-level probe for the PAGE PROGRAM rejection -- no FPGA
shift engine, no FSM timing, just "host sets pins, flash responds".

Usage: python3 bitbang_flash.py [HOST]
Writes bitbang_flash_results.txt.
"""
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from base_device import BitBangDevice   # noqa: E402

OUT = []


def log(s):
    print(s); OUT.append(str(s))


def hexb(bs):
    return ' '.join('%02X' % b for b in bytes(bs))


def main():
    host = sys.argv[1] if len(sys.argv) > 1 else '192.168.7.140'
    dev = BitBangDevice(host)

    log("FLASH BIT-BANG SELF-TEST  host=%s" % host)
    log("=" * 60)

    fwid = dev.firmware_id()
    log("[1] firmware ID = 0x%08X (expect 0x%08X) -> %s"
        % (fwid, dev.EXPECT_FWID, "OK" if fwid == dev.EXPECT_FWID else "WRONG BITSTREAM"))
    if fwid != dev.EXPECT_FWID:
        log("    Not the bitbang_top variant; program base/bitbang.bit. Aborting.")
        _write(); return

    jedec = dev.read_id()
    log("[2] RDID JEDEC = %s (expect 20 20 16) -> %s"
        % (hexb(jedec), "OK" if jedec == (0x20, 0x20, 0x16) else "MISMATCH"))

    dev.wren()
    sr = dev.rdsr()
    wel = (sr >> 1) & 1
    log("[3] WREN then RDSR = 0x%02X  WEL(bit1) = %d -> %s"
        % (sr, wel, "WREN REACHES FLASH" if wel else "WREN NOT LANDING"))

    addr = 0x3C0000          # scratch sector 60
    data = bytes([0xDE, 0xAD, 0xBE, 0xEF])
    dev.erase_sector(addr)
    blank = dev.flash_read(addr, 4)
    log("[4] erased 0x%06X -> %s (expect FF FF FF FF)" % (addr, hexb(blank)))

    dev.program(addr, data)
    back = dev.flash_read(addr, 4)
    log("    program %s -> readback %s -> %s"
        % (hexb(data), hexb(back), "PROGRAM OK" if back == data else "PROGRAM FAILED"))

    dev.erase_sector(addr)   # restore blank
    log("=" * 60)
    log("Bit-bang gives the host full control of every SPI edge: if PAGE PROGRAM")
    log("works here but not via flash_spi, the engine's timing is the culprit;")
    log("if it fails here too, the issue is the board/flash, not the gateware.")
    _write()


def _write():
    with open('bitbang_flash_results.txt', 'w') as f:
        f.write("\n".join(OUT) + "\n")
    print("\nWrote bitbang_flash_results.txt")


if __name__ == '__main__':
    main()
