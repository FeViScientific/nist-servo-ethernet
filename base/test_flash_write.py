#!/usr/bin/env python3
"""
test_flash_write.py - figure out how to WRITE the M25P32, using the safe
bit-bang driver (bitbang_top, firmware 0xBA5E0B1B).

Bit-bang is deterministic -- the host holds each SPI level statically and reads
MISO long after it has settled, so there is no timing race. That makes it the
right tool for nailing down the write procedure, independent of the flash_spi
shift engine.

The whole test is built around READING THE STATUS REGISTER (RDSR) at every step,
because the status bits explain write behavior:

    WIP  (bit0)  write/erase in progress
    WEL  (bit1)  write-enable latch (set by WREN; PP/SE need it)
    BP2:0(4:2)   block protect -- if NONZERO, PP/SE are SILENTLY IGNORED for
                 protected sectors even with WEL=1. The likeliest reason a
                 program "succeeds" but the data never changes.
    SRWD (bit7)  status register write disable

Procedure proved here:  unprotect (WRSR=0x00) -> WREN -> PP/SE -> poll WIP.

Usage: python3 test_flash_write.py [HOST]
Writes test_flash_write_results.txt.
"""
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from base_device import BitBangDevice, status_str, decode_status   # noqa: E402

OUT = []


def log(s):
    print(s); OUT.append(str(s))


def hexb(bs):
    return ' '.join('%02X' % b for b in bytes(bs))


def main():
    host = sys.argv[1] if len(sys.argv) > 1 else '192.168.7.140'
    dev = BitBangDevice(host)
    addr = 0x3C0000          # scratch sector 60, well clear of the bitstream
    data = bytes([0xDE, 0xAD, 0xBE, 0xEF])

    log("FLASH WRITE DEBUG (bit-bang, safe)  host=%s" % host)
    log("=" * 64)

    fwid = dev.firmware_id()
    log("[0] firmware ID = 0x%08X (expect 0x%08X) -> %s"
        % (fwid, dev.EXPECT_FWID, "OK" if fwid == dev.EXPECT_FWID else "WRONG BITSTREAM"))
    if fwid != dev.EXPECT_FWID:
        log("    Not the bitbang_top variant; program base/bitbang.bit. Aborting.")
        _write(); return

    jedec = dev.read_id()
    log("[1] RDID JEDEC = %s (expect 20 20 16) -> %s"
        % (hexb(jedec), "OK" if jedec == (0x20, 0x20, 0x16) else "MISMATCH"))

    # --- status as found -------------------------------------------------
    sr = dev.rdsr()
    log("[2] status (as found) = %s" % status_str(sr))
    bp = decode_status(sr)['bp']
    if bp:
        log("    !! BP bits set => sectors are WRITE-PROTECTED. PP/SE will be")
        log("       silently ignored until cleared. Clearing via WRSR=0x00...")
        dev.unprotect()
        sr = dev.rdsr()
        log("    status after unprotect = %s -> %s"
            % (status_str(sr), "CLEARED" if decode_status(sr)['bp'] == 0 else "STILL SET"))
    else:
        log("    BP=0: no block protection, writes are allowed.")

    # --- WREN sets WEL ----------------------------------------------------
    dev.wren()
    sr = dev.rdsr()
    wel = decode_status(sr)['wel']
    log("[3] after WREN: status = %s" % status_str(sr))
    log("    WEL=%d -> %s" % (wel, "write-enable latch SET" if wel else "WREN NOT LANDING"))

    # --- erase, watching WIP ---------------------------------------------
    log("[4] SECTOR ERASE 0x%06X ..." % addr)
    dev.wren()
    dev.xfer([0xD8, (addr >> 16) & 0xFF, (addr >> 8) & 0xFF, addr & 0xFF])
    sr = dev.rdsr()
    log("    status right after SE cmd = %s (WIP should be 1)" % status_str(sr))
    dev.wait_wip()
    sr = dev.rdsr()
    log("    status after erase done   = %s (WIP=0, WEL auto-cleared)" % status_str(sr))
    blank = dev.flash_read(addr, 4)
    log("    readback = %s -> %s" % (hexb(blank), "ERASED" if blank == b'\xff' * 4 else "NOT ERASED"))

    # --- program, watching WIP -------------------------------------------
    log("[5] PAGE PROGRAM %s @ 0x%06X ..." % (hexb(data), addr))
    dev.wren()
    log("    status before PP = %s (WEL must be 1)" % status_str(dev.rdsr()))
    dev.xfer([0x02, (addr >> 16) & 0xFF, (addr >> 8) & 0xFF, addr & 0xFF] + list(data))
    sr = dev.rdsr()
    log("    status right after PP cmd = %s (WIP should be 1)" % status_str(sr))
    dev.wait_wip()
    sr = dev.rdsr()
    log("    status after PP done      = %s" % status_str(sr))
    back = dev.flash_read(addr, 4)
    log("    readback = %s (wrote %s) -> %s"
        % (hexb(back), hexb(data), "PROGRAM OK" if back == data else "PROGRAM FAILED"))

    # --- restore ----------------------------------------------------------
    dev.erase_sector(addr)
    log("[6] restored scratch sector to blank")

    log("=" * 64)
    if back == data:
        log("RESULT: writes work bit-banged. Procedure: (unprotect ->) WREN -> PP")
        log("        -> poll WIP. If flash_spi still fails, it's engine timing.")
    else:
        log("RESULT: write FAILED even bit-banged. Watch [2]/[3]: if BP stayed")
        log("        set or WEL never latched, that is the cause; otherwise the")
        log("        flash/board is not accepting PP (check WP#/HOLD# pins).")
    _write()


def _write():
    with open('test_flash_write_results.txt', 'w') as f:
        f.write("\n".join(OUT) + "\n")
    print("\nWrote test_flash_write_results.txt")


if __name__ == '__main__':
    main()
