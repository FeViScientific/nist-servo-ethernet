#!/usr/bin/env python3
"""
test_flash.py - consolidated config-flash (M25P32 / ISSI IS25LP032) diagnostic.

Merges the former one-off scripts -- test_flash_diag, _diag2, _diag3, _diag4 and
test_flash_count -- into a single run over one rsync round-trip. Each diagnostic
is a "stage"; by default every stage runs in order and the whole transcript is
written to test_flash_results.txt.

Stages (run all, or name a subset on the command line):
  id        RDID 0x9F JEDEC id + byte-alignment probe (expect ISSI 9D 40 16)
  status    RDSR 0x05 status register (protection + busy bits)
  wren      WREN 0x06 -> WEL should set (is the command/MOSI path reaching flash?)
  read      READ 0x03 of several regions (are address bytes honored? alignment)
  count     SCK rising-edge count per transfer vs 8*len (flash_spi reg 0x047)
  buffer    transfer-buffer RAM integrity (lbus 0x800-0x87F), no flash involved
  unprotect WREN + WRSR 0x00 (clear block-protect bits)
  accept    SECTOR ERASE / PAGE PROGRAM write-acceptance (poll WIP), read back
  length    PAGE PROGRAM length dependence (1..256 data bytes)
  program   erase + program + verify a known pattern on the scratch sector

All write stages operate only on the scratch sector (default 0x3C0000, sector
60) and leave it erased.

Usage:
  python3 test_flash.py [HOST] [--scratch 0xADDR] [--out FILE] [stage ...]
  python3 test_flash.py                          # all stages, default host
  python3 test_flash.py 192.168.7.140 id status  # just two stages
"""
import argparse
import sys
import time

DEFAULT_HOST = '192.168.7.140'
DEFAULT_SCRATCH = 0x3C0000   # sector 60
SCK_COUNT = 0x047            # flash_spi SCK rising-edge counter
FLASH_BUF = 0x800
FLASH_BUSY = 0x046

STAGE_ORDER = ['id', 'status', 'wren', 'read', 'count', 'buffer',
               'unprotect', 'accept', 'length', 'program']


class FlashDiag:
    def __init__(self, dev, scratch):
        self.dev = dev
        self.xfer = dev._flash_xfer
        self.scratch = scratch
        self.out = []

    # -- shared helpers ------------------------------------------------------
    def log(self, s=''):
        print(s)
        self.out.append(str(s))

    def hr(self, ch='='):
        self.log(ch * 64)

    def rdsr(self):
        return self.xfer(bytes([0x05, 0x00]))[1]

    @staticmethod
    def decode_sr(sr):
        return (f"0x{sr:02X}  WIP={sr & 1} WEL={(sr >> 1) & 1} "
                f"BP0={(sr >> 2) & 1} BP1={(sr >> 3) & 1} BP2={(sr >> 4) & 1} "
                f"SRWD={(sr >> 7) & 1}")

    @staticmethod
    def sr_short(sr):
        return f"0x{sr:02X}(WIP={sr & 1},WEL={(sr >> 1) & 1})"

    def scratch_addr(self):
        s = self.scratch
        return (s >> 16) & 0xFF, (s >> 8) & 0xFF, s & 0xFF

    def wait_idle(self, n=600):
        for _ in range(n):
            if not (self.rdsr() & 1):
                return

    def poll_wip(self, label, n=60):
        """Poll RDSR after a write; report whether WIP was ever seen high."""
        seen_wip = False
        self.log(f"   polling RDSR after {label}:")
        t0 = time.time()
        for k in range(n):
            sr = self.rdsr()
            if sr & 1:
                seen_wip = True
            if k < 6 or (sr & 1):
                self.log(f"     t={time.time() - t0:6.3f}s {self.sr_short(sr)}")
            if not (sr & 1) and seen_wip:
                self.log(f"     t={time.time() - t0:6.3f}s {self.sr_short(sr)}  <- WIP cleared")
                break
        return seen_wip

    def erase_scratch(self):
        a2, a1, a0 = self.scratch_addr()
        self.xfer(bytes([0x06]))             # WREN
        self.xfer(bytes([0xD8, a2, a1, a0]))  # sector erase
        self.wait_idle()

    # -- stages --------------------------------------------------------------
    def stage_id(self):
        self.log("[id] RDID 0x9F, raw 7-byte response (find where 9D 40 16 lands):")
        try:
            for i in range(3):
                rx = self.xfer(bytes([0x9F] + [0] * 6))
                self.log(f"   {i}: {rx.hex()}  -> id bytes[1:4] = {rx[1:4].hex()}")
            self.log("   (expect ISSI 9D 40 16 at bytes[1:4])")
        except Exception as e:
            self.log(f"   ERROR: {e}")

    def stage_status(self):
        self.log("[status] RDSR 0x05 status register x3:")
        try:
            for _ in range(3):
                self.log(f"   {self.decode_sr(self.rdsr())}")
        except Exception as e:
            self.log(f"   ERROR: {e}")

    def stage_wren(self):
        self.log("[wren] WREN 0x06 then RDSR (WEL should be 1):")
        try:
            self.xfer(bytes([0x06]))
            sr = self.rdsr()
            self.log(f"   after WREN: {self.decode_sr(sr)}")
            self.log(f"   => WREN {'EFFECTIVE (WEL set)' if (sr >> 1) & 1 else 'NOT effective (WEL=0)'}")
            self.xfer(bytes([0x04]))  # WRDI
        except Exception as e:
            self.log(f"   ERROR: {e}")

    def stage_read(self):
        self.log("[read] READ 0x03 of known regions, 16 bytes (addresses honored?):")
        seen = {}
        try:
            for addr in (0x000000, 0x010000, 0x100000, self.scratch, 0x3D0000,
                         0x3E0000, 0x3F0000):
                data = self.dev.flash_read(addr, 16)
                seen[addr] = data.hex()
                self.log(f"   @0x{addr:06X}: {data.hex()}")
            distinct = len(set(seen.values()))
            self.log(f"   => {distinct} distinct results across {len(seen)} addresses "
                     f"({'addresses honored' if distinct > 1 else 'SAME data - address may be ignored'})")
        except Exception as e:
            self.log(f"   ERROR: {e}")

    def stage_count(self):
        self.log("[count] SCK rising-edge count per transfer vs 8*len (reg 0x047):")
        self.log(f"   {'len':>4} {'sck_count':>10} {'expect(8*len)':>14}  result")
        bad = 0
        try:
            for n in (1, 2, 3, 4, 5, 6, 7, 8, 12, 16, 20, 64, 65, 256, 260):
                self.xfer(bytes([0x9F] + [0] * (n - 1)))  # non-destructive padded RDID
                cnt = int(self.dev.read(SCK_COUNT)) & 0xFFFF
                exp = 8 * n
                ok = (cnt == exp)
                bad += (not ok)
                self.log(f"   {n:>4} {cnt:>10} {exp:>14}  {'OK' if ok else 'MISMATCH'}")
            if bad == 0:
                self.log("   => FPGA emits 8*len clocks for every length (clocking CORRECT)")
            else:
                self.log(f"   => {bad} lengths MISMATCH (note the first to break, esp. 5 = "
                         "crosses the 4-byte word boundary)")
        except Exception as e:
            self.log(f"   ERROR: {e}")

    def stage_buffer(self):
        self.log("[buffer] transfer-buffer RAM integrity (lbus 0x800-0x87F, no flash):")
        try:
            busy = int(self.dev.read(FLASH_BUSY)) & 1
            self.log(f"   flash_busy = {busy}")

            # 1) 32 words write/read
            words = [(0x11223340 + i * 0x01010101) & 0xFFFFFFFF for i in range(32)]
            self.dev.write_multi([FLASH_BUF + i for i in range(32)], words)
            rb = [int(v) & 0xFFFFFFFF for v in
                  self.dev.read_multi([FLASH_BUF + i for i in range(32)])]
            bad = [(i, words[i], rb[i]) for i in range(32) if rb[i] != words[i]]
            if not bad:
                self.log("   1) OK: all 32 words read back correctly")
            else:
                self.log(f"   1) MISMATCH in {len(bad)}/32 words:")
                for i, w, g in bad[:12]:
                    self.log(f"        word[{i:2d}] wrote 0x{w:08X} read 0x{g:08X}")

            # 2) byte-lane check
            test = [0x04030201, 0x08070605, 0xCAFEBABE, 0xDEADBEEF, 0xFF00FF00, 0x00FF00FF]
            self.dev.write_multi([FLASH_BUF + i for i in range(len(test))], test)
            rb2 = [int(v) & 0xFFFFFFFF for v in
                   self.dev.read_multi([FLASH_BUF + i for i in range(len(test))])]
            bad2 = [(i, test[i], rb2[i]) for i in range(len(test)) if rb2[i] != test[i]]
            if not bad2:
                self.log("   2) OK: byte lanes intact")
            else:
                for i, w, g in bad2:
                    self.log(f"   2) word[{i}] wrote 0x{w:08X} read 0x{g:08X}")

            # 3) stability
            vals = {int(self.dev.read(FLASH_BUF + 5)) & 0xFFFFFFFF for _ in range(10)}
            self.log(f"   3) stability of word 5: {[hex(v) for v in vals]}  "
                     f"({'stable' if len(vals) == 1 else 'UNSTABLE'})")
        except Exception as e:
            self.log(f"   ERROR: {e}")

    def stage_unprotect(self):
        self.log("[unprotect] WREN + WRSR 0x00 (clear block-protect / SRWD):")
        try:
            before = self.rdsr()
            self.xfer(bytes([0x06]))        # WREN
            self.xfer(bytes([0x01, 0x00]))  # WRSR = 0x00
            time.sleep(0.05)
            after = self.rdsr()
            self.log(f"   before: {self.decode_sr(before)}")
            self.log(f"   after : {self.decode_sr(after)}")
        except Exception as e:
            self.log(f"   ERROR: {e}")

    def stage_accept(self):
        a2, a1, a0 = self.scratch_addr()
        self.log(f"[accept] write-acceptance on scratch 0x{self.scratch:06X}:")
        try:
            # SECTOR ERASE -> WIP pulse?
            self.log("   SECTOR ERASE 0xD8 (WREN first), watch WIP (erase ~0.6-3s):")
            self.xfer(bytes([0x06]))
            self.log(f"   after WREN: {self.sr_short(self.rdsr())}")
            self.xfer(bytes([0xD8, a2, a1, a0]))
            erased_wip = self.poll_wip("SECTOR ERASE", 60)
            self.log(f"   => SECTOR ERASE {'ACCEPTED (WIP pulsed)' if erased_wip else 'NOT ACCEPTED (WIP never high)'}")
            self.wait_idle()

            # PAGE PROGRAM -> WIP + memory change?
            self.log("   PAGE PROGRAM 0x02 (WREN first), watch WIP, then read back:")
            self.xfer(bytes([0x06]))
            self.log(f"   after WREN: {self.sr_short(self.rdsr())}")
            pat = bytes([0xDE, 0xAD, 0xBE, 0xEF])
            self.xfer(bytes([0x02, a2, a1, a0]) + pat)
            pp_wip = self.poll_wip("PAGE PROGRAM", 40)
            self.wait_idle()
            got = self.dev.flash_read(self.scratch, 4)
            self.log(f"   wrote {pat.hex()}  read {got.hex()}")
            self.log(f"   => PAGE PROGRAM {'WIP pulsed' if pp_wip else 'no WIP'}; "
                     f"memory {'CHANGED' if got == pat else 'unchanged'}")
        except Exception as e:
            self.log(f"   ERROR: {e}")
        finally:
            self.erase_scratch()  # leave blank

    def stage_length(self):
        a2, a1, a0 = self.scratch_addr()
        self.log(f"[length] PAGE PROGRAM length dependence on 0x{self.scratch:06X}:")
        try:
            for ndata in (1, 2, 4, 16, 64, 128, 255, 256):
                self.erase_scratch()
                data = bytes((0x40 + (k & 0x3F)) for k in range(ndata))
                self.xfer(bytes([0x06]))                 # WREN
                wel = (self.rdsr() >> 1) & 1
                self.xfer(bytes([0x02, a2, a1, a0]) + data)
                wip = False
                for _ in range(80):
                    sr = self.rdsr()
                    if sr & 1:
                        wip = True
                    if not (sr & 1) and wip:
                        break
                self.wait_idle()
                got = self.dev.flash_read(self.scratch, min(ndata, 16))
                ok = got == data[:len(got)]
                self.log(f"   PP {ndata:3d} bytes: WEL_before={wel} WIP_pulsed={int(wip)} "
                         f"readback={'OK' if ok else 'NO'} ({got[:8].hex()}...)")
        except Exception as e:
            self.log(f"   ERROR: {e}")
        finally:
            self.erase_scratch()

    def stage_program(self):
        self.log(f"[program] erase + program + verify on scratch 0x{self.scratch:06X}:")
        try:
            pat = bytes([0xDE, 0xAD, 0xBE, 0xEF, 0x01, 0x02, 0x03, 0x04])
            self.dev.flash_erase_sector(self.scratch)
            erased = self.dev.flash_read(self.scratch, 8)
            self.dev.flash_program(self.scratch, pat)
            got = self.dev.flash_read(self.scratch, 8)
            self.log(f"   erased: {erased.hex()}")
            self.log(f"   wrote : {pat.hex()}")
            self.log(f"   read  : {got.hex()}")
            self.log(f"   => program {'WORKS' if got == pat else 'FAILED'}")
        except Exception as e:
            self.log(f"   ERROR: {e}")
        finally:
            try:
                self.dev.flash_erase_sector(self.scratch)
            except Exception:
                pass

    def run(self, stages):
        for name in stages:
            getattr(self, 'stage_' + name)()
            self.hr('-')


def main():
    ap = argparse.ArgumentParser(
        description="Consolidated config-flash diagnostic.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="stages: " + " ".join(STAGE_ORDER))
    ap.add_argument('host', nargs='?', default=DEFAULT_HOST,
                    help=f"FPGA IP (default {DEFAULT_HOST})")
    ap.add_argument('stages', nargs='*',
                    help="stages to run (default: all, in order)")
    ap.add_argument('--scratch', type=lambda x: int(x, 0), default=DEFAULT_SCRATCH,
                    help="scratch sector base address (default 0x3C0000)")
    ap.add_argument('--out', default='test_flash_results.txt',
                    help="results file (default test_flash_results.txt)")
    args = ap.parse_args()

    # Allow stage names to appear before the host, e.g. "id status" with no host.
    stages = args.stages
    host = args.host
    if host in STAGE_ORDER:           # first positional was actually a stage
        stages = [host] + stages
        host = DEFAULT_HOST
    if not stages:
        stages = list(STAGE_ORDER)
    unknown = [s for s in stages if s not in STAGE_ORDER]
    if unknown:
        ap.error(f"unknown stage(s): {' '.join(unknown)}; choose from {' '.join(STAGE_ORDER)}")

    from servo_device import ServoDevice
    dev = ServoDevice(host=host)
    diag = FlashDiag(dev, args.scratch)

    diag.log(f"CONFIG-FLASH DIAGNOSTIC  host={host}  scratch=0x{args.scratch:06X}")
    diag.log(f"stages: {' '.join(stages)}")
    diag.hr()
    diag.run(stages)
    diag.log("Interpretation cheatsheet:")
    diag.log("  id bytes[1:4] != 9D 40 16  -> MISO receive/alignment bug (read path)")
    diag.log("  WEL stays 0 after WREN     -> command/MOSI path not reaching flash")
    diag.log("  BP0/BP1/BP2 set            -> block-protect; run 'unprotect' first")
    diag.log("  count MISMATCH             -> FPGA emits wrong SCK count (framing)")
    diag.log("  buffer MISMATCH            -> transfer-buffer RAM broken on hardware")
    diag.log("  accept WIP pulses but readback unchanged -> write accepted, verify/MISO issue")
    diag.log("  length: only 256 programs  -> part rejects partial-page; pad to 256")

    with open(args.out, 'w') as f:
        f.write("\n".join(diag.out) + "\n")
    print(f"\nWrote {args.out}")


if __name__ == '__main__':
    main()
