#!/usr/bin/env python3
"""
base_device.py - Python drivers for the minimal `base/` FPGA project and its
component-test variants.

The base project is the clocks+Badger scaffold (firmware ID 0xBA5E0001); the
variants bolt one component onto it and bump the firmware ID:

    BaseDevice      base_top      0xBA5E0001  scratch / LED / uptime
    FlashSpiDevice  flash_top     0xBA5E0F1A  flash_spi shift engine + MOSI capture
    BitBangDevice   bitbang_top   0xBA5E0B1B  raw-pin bit-bang of the flash

All three speak the LASS/lbus UDP protocol via Bedrock's lbus_access, exactly
like ServoDevice, but stay self-contained so the base project does not depend on
the full servo firmware's Python.
"""
import os
import sys
import time
import struct

# lbus_access lives in Bedrock (one level up from base/)
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'Bedrock', 'badger'))
from lbus_access import lbus_access   # noqa: E402


# ---------------------------------------------------------------------------
# Base lbus client
# ---------------------------------------------------------------------------
class BaseDevice:
    """Thin lbus register client for the base scaffold and every variant."""

    FW_ID      = 0x020
    ETH_LOCKED = 0x021
    SCRATCH0   = 0x000
    SCRATCH1   = 0x001
    LED        = 0x002
    UPTIME     = 0x012

    def __init__(self, host='192.168.7.140', port=803, timeout=1.0):
        self.dev = lbus_access(host, timeout=timeout, port=port, allow_burst=True)

    # --- raw register access ---------------------------------------------
    def read(self, addr):
        return int(self.dev.exchange([addr])[0])

    def write(self, addr, value):
        self.dev.exchange([addr], [int(value) & 0xFFFFFFFF])

    def read_multi(self, addrs):
        return [int(v) for v in self.dev.exchange(list(addrs))]

    def write_multi(self, addrs, values):
        self.dev.exchange(list(addrs), [int(v) & 0xFFFFFFFF for v in values])

    # --- base status ------------------------------------------------------
    def firmware_id(self):
        return self.read(self.FW_ID) & 0xFFFFFFFF

    def eth_clk_locked(self):
        return bool(self.read(self.ETH_LOCKED) & 1)

    def uptime(self):
        return self.read(self.UPTIME) & 0xFFFFFFFF

    def set_led(self, value):
        self.write(self.LED, value & 0xFF)

    def scratch_roundtrip(self, value=0xA5A5_1234):
        """Write/read the scratch register; returns True if it survived."""
        self.write(self.SCRATCH0, value)
        return (self.read(self.SCRATCH0) & 0xFFFFFFFF) == (value & 0xFFFFFFFF)

    def expect_firmware(self, expected, name):
        fwid = self.firmware_id()
        if fwid != expected:
            raise RuntimeError(
                "wrong bitstream: firmware ID 0x%08X, expected 0x%08X (%s)"
                % (fwid, expected, name))
        return fwid


# ---------------------------------------------------------------------------
# M25P32 opcodes / geometry (shared by both flash drivers)
# ---------------------------------------------------------------------------
F_WREN, F_RDSR, F_READ, F_PP, F_SE, F_RDID = 0x06, 0x05, 0x03, 0x02, 0xD8, 0x9F
F_WRSR = 0x01
PAGE, SECTOR = 256, 0x10000


def decode_status(sr):
    """Decode an M25P32 status register byte.

    WIP(0)=write in progress, WEL(1)=write enable latch, BP2:0(4:2)=block
    protect (nonzero => some sectors write-protected; PP/SE silently ignored),
    SRWD(7)=status register write disable.
    """
    return {
        'raw':  sr & 0xFF,
        'wip':  sr & 0x01,
        'wel':  (sr >> 1) & 1,
        'bp':   (sr >> 2) & 0x07,
        'srwd': (sr >> 7) & 1,
    }


def status_str(sr):
    s = decode_status(sr)
    return ("0x%02X  WIP=%d WEL=%d BP=%d (BP2:0=%s) SRWD=%d"
            % (s['raw'], s['wip'], s['wel'], s['bp'],
               format(s['bp'], '03b'), s['srwd']))


class _M25P32Mixin:
    """M25P32 protocol built on a raw `xfer(tx) -> rx` transaction primitive.

    A subclass must provide xfer(data): drive `data` out MOSI in one CS-framed
    transaction and return the same number of MISO bytes.
    """

    def read_id(self):
        return tuple(self.xfer([F_RDID, 0, 0, 0])[1:4])

    def wren(self):
        self.xfer([F_WREN])

    def rdsr(self):
        return self.xfer([F_RDSR, 0])[1]

    def write_status(self, value):
        """Write the status register (clears/sets BP and SRWD). Needs WREN."""
        self.wren()
        self.xfer([F_WRSR, value & 0xFF])
        self.wait_wip()

    def unprotect(self):
        """Clear block-protect (BP2:0) and SRWD so all sectors are writable."""
        self.write_status(0x00)

    def wait_wip(self, timeout=10.0):
        t0 = time.time()
        while time.time() - t0 < timeout:
            if (self.rdsr() & 0x01) == 0:
                return
        raise TimeoutError("flash write/erase did not complete")

    def flash_read(self, addr, n):
        out = bytearray()
        while n > 0:
            chunk = min(n, self._max_read_chunk())
            tx = bytes([F_READ, (addr >> 16) & 0xFF, (addr >> 8) & 0xFF, addr & 0xFF])
            out += self.xfer(tx + b'\x00' * chunk)[4:]
            addr += chunk
            n -= chunk
        return bytes(out)

    def erase_sector(self, addr):
        self.wren()
        self.xfer([F_SE, (addr >> 16) & 0xFF, (addr >> 8) & 0xFF, addr & 0xFF])
        self.wait_wip()

    def program(self, addr, data):
        data = bytes(data)
        off = 0
        while off < len(data):
            page_off = addr & (PAGE - 1)
            chunk = min(PAGE - page_off, len(data) - off, self._max_pp_chunk())
            self.wren()
            tx = bytes([F_PP, (addr >> 16) & 0xFF, (addr >> 8) & 0xFF, addr & 0xFF])
            self.xfer(tx + data[off:off + chunk])
            self.wait_wip()
            addr += chunk
            off += chunk

    # chunking limits -- overridden where a transport caps transaction size
    def _max_read_chunk(self):
        return PAGE

    def _max_pp_chunk(self):
        return PAGE


# ---------------------------------------------------------------------------
# flash_spi shift-engine driver (flash_top variant)
# ---------------------------------------------------------------------------
class FlashSpiDevice(BaseDevice, _M25P32Mixin):
    """Drives the flash via the in-FPGA flash_spi shift engine + MOSI capture."""

    EXPECT_FWID = 0xBA5E0F1A

    FLASH_LEN  = 0x044
    FLASH_GO   = 0x045
    FLASH_BUSY = 0x046
    SCK_COUNT  = 0x047
    MOSI_LO    = 0x048
    MOSI_HI    = 0x049
    FLASH_BUF  = 0x800
    BUF_BYTES  = 512

    def __init__(self, host='192.168.7.140', **kw):
        super().__init__(host, **kw)

    # one CS-framed transfer through the shift engine
    def xfer(self, data):
        tx = bytes(data)
        n = len(tx)
        if not (1 <= n <= self.BUF_BYTES):
            raise ValueError("transfer length must be 1..%d (got %d)"
                             % (self.BUF_BYTES, n))
        padded = tx + b'\x00' * (-n % 4)
        words = [struct.unpack_from('<I', padded, 4 * i)[0]
                 for i in range(len(padded) // 4)]
        self.write_multi([self.FLASH_BUF + i for i in range(len(words))], words)
        self.write_multi([self.FLASH_LEN, self.FLASH_GO], [n, 1])
        self._wait_busy()
        rwords = self.read_multi([self.FLASH_BUF + i for i in range(len(words))])
        rx = b''.join(struct.pack('<I', w & 0xFFFFFFFF) for w in rwords)
        return rx[:n]

    def _wait_busy(self, timeout=1.0):
        t0 = time.time()
        while time.time() - t0 < timeout:
            if (self.read(self.FLASH_BUSY) & 1) == 0:
                return
        raise TimeoutError("flash_spi transfer did not complete")

    def _max_read_chunk(self):
        return self.BUF_BYTES - 4   # leave room for the 4-byte cmd+addr header

    def _max_pp_chunk(self):
        return self.BUF_BYTES - 4

    # --- diagnostics ------------------------------------------------------
    def sck_count(self):
        """SCK rising edges emitted in the last transfer (should be 8*len)."""
        return self.read(self.SCK_COUNT) & 0xFFFF

    def mosi_capture(self, n):
        """Bytes the FPGA actually drove on MOSI in the last transfer.

        The capture freezes on the first min(64, 8n) bits; byte0 sits at the
        MSB so the command+address header always survives.
        """
        val = ((self.read(self.MOSI_HI) & 0xFFFFFFFF) << 32) \
            | (self.read(self.MOSI_LO) & 0xFFFFFFFF)
        nbits = min(64, 8 * n)
        val &= (1 << nbits) - 1
        return bytes((val >> (nbits - 8 * (i + 1))) & 0xFF for i in range(nbits // 8))


# ---------------------------------------------------------------------------
# Bit-bang driver (bitbang_top variant)
# ---------------------------------------------------------------------------
class BitBangDevice(BaseDevice, _M25P32Mixin):
    """Bit-bangs the flash by driving SCK/MOSI/CS as raw register bits.

    SPI mode 0: SCK idles low; MOSI is set up with SCK low; the flash latches
    MOSI and presents MISO around the rising edge (MISO sampled after SCK high).
    """

    EXPECT_FWID = 0xBA5E0B1B

    PINS = 0x050     # bit0=SCK, bit1=MOSI, bit2=CS
    MISO = 0x051     # bit0=MISO

    def __init__(self, host='192.168.7.140', **kw):
        super().__init__(host, **kw)
        self.sck = 0
        self.mosi = 0
        self.cs = 1
        self._drive()

    # --- raw pins ---------------------------------------------------------
    def _drive(self):
        self.write(self.PINS, (self.cs << 2) | (self.mosi << 1) | self.sck)

    def _miso(self):
        return self.read(self.MISO) & 1

    def select(self):
        self.cs, self.sck = 0, 0
        self._drive()

    def deselect(self):
        self.sck = 0
        self._drive()
        self.cs = 1
        self._drive()

    # --- byte / transaction ----------------------------------------------
    def xfer_byte(self, tx):
        rx = 0
        for i in range(8):
            self.mosi = (tx >> (7 - i)) & 1
            self.sck = 0
            self._drive()
            self.sck = 1
            self._drive()
            rx = (rx << 1) | self._miso()
            self.sck = 0
            self._drive()
        return rx

    def xfer(self, data):
        self.select()
        rx = bytes(self.xfer_byte(b) for b in bytes(data))
        self.deselect()
        return rx


# ---------------------------------------------------------------------------
# Smoke test: identify whichever variant is loaded and exercise the base regs.
# ---------------------------------------------------------------------------
def main():
    host = sys.argv[1] if len(sys.argv) > 1 else '192.168.7.140'
    dev = BaseDevice(host)
    fwid = dev.firmware_id()
    names = {0xBA5E0001: 'base_top', 0xBA5E0F1A: 'flash_top',
             0xBA5E0B1B: 'bitbang_top'}
    print("host           : %s" % host)
    print("firmware ID    : 0x%08X (%s)" % (fwid, names.get(fwid, 'UNKNOWN')))
    print("eth_clk_locked : %s" % dev.eth_clk_locked())
    print("uptime ticks   : %d" % dev.uptime())
    print("scratch r/w    : %s" % ("OK" if dev.scratch_roundtrip() else "FAIL"))


if __name__ == '__main__':
    main()
