#!/usr/bin/env python3
"""Set DAC output values via LASS.

Usage:
    python3 set_dac.py <dac> <value>
    python3 set_dac.py 0 0x100000       # DAC0 positive
    python3 set_dac.py 1 -0x100000      # DAC1 negative
    python3 set_dac.py 2 0              # DAC2 midscale
    python3 set_dac.py gain 3           # output PGA gain ch0=3, or gain 0x0F for both max
    python3 set_dac.py ramp 0           # ramp DAC0 through full range
    python3 set_dac.py read             # read all DAC values
"""

import socket
import struct
import sys
import time

IP = "192.168.7.140"
PORT = 803
TIMEOUT = 1.0

DAC_ADDRS = {0: 0x100, 1: 0x101, 2: 0x102}
GAIN_ADDR = 0x103

def lass_write(sock, addr, data):
    msg = struct.pack(">II", 0, 0)  # txn ID
    msg += struct.pack(">I", (0x00 << 24) | (addr & 0xFFFFFF))
    msg += struct.pack(">I", data & 0xFFFFFFFF)
    sock.sendto(msg, (IP, PORT))
    sock.recvfrom(4096)

def lass_read(sock, addr):
    msg = struct.pack(">II", 0, 0)
    msg += struct.pack(">I", (0x10 << 24) | (addr & 0xFFFFFF))
    msg += struct.pack(">I", 0)
    sock.sendto(msg, (IP, PORT))
    resp, _ = sock.recvfrom(4096)
    return struct.unpack(">I", resp[12:16])[0]

def to_signed24(val):
    """Convert to 24-bit signed, return as unsigned for register write."""
    val = int(val)
    if val < -0x800000 or val > 0x7FFFFF:
        print(f"Warning: value {val} out of 24-bit signed range, will be truncated")
    return val & 0xFFFFFF

def from_signed32(val):
    """Convert unsigned 32-bit readback to signed."""
    if val >= 0x80000000:
        return val - 0x100000000
    return val

def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.settimeout(TIMEOUT)

    cmd = sys.argv[1].lower()

    if cmd == "read":
        for ch, addr in DAC_ADDRS.items():
            val = lass_read(sock, addr)
            sval = from_signed32(val)
            print(f"DAC{ch}: 0x{val:08X} ({sval})")
        val = lass_read(sock, GAIN_ADDR)
        print(f"Gain: 0x{val:02X} (ch0={val & 3}, ch1={(val >> 2) & 3})")

    elif cmd == "ramp":
        if len(sys.argv) > 2:
            ch = int(sys.argv[2])
            addr = DAC_ADDRS[ch]
            print(f"Ramping DAC{ch} from Python (Ctrl+C to stop)")
            step = 0x010000
            try:
                val = -0x800000
                while True:
                    lass_write(sock, addr, val & 0xFFFFFF)
                    val += step
                    if val > 0x7FFFFF:
                        val = -0x800000
                    time.sleep(0.001)
            except KeyboardInterrupt:
                lass_write(sock, addr, 0)
                print("\nStopped, DAC set to 0")
        else:
            lass_write(sock, 0x104, 1)
            print("Hardware ramp enabled on all DACs (~6 Hz sawtooth)")

    elif cmd == "stop":
        lass_write(sock, 0x104, 0)
        print("Ramp stopped")

    elif cmd == "gain":
        val = int(sys.argv[2], 0)
        lass_write(sock, GAIN_ADDR, val & 0xF)
        print(f"Gain set to 0x{val & 0xF:X} (ch0={val & 3}, ch1={(val >> 2) & 3})")

    elif cmd == "ramp":
        ch = int(sys.argv[2])
        addr = DAC_ADDRS[ch]
        print(f"Ramping DAC{ch} through full range (Ctrl+C to stop)")
        step = 0x010000  # ~65k steps across 24-bit range
        try:
            val = -0x800000
            while True:
                lass_write(sock, addr, val & 0xFFFFFF)
                val += step
                if val > 0x7FFFFF:
                    val = -0x800000
                time.sleep(0.001)
        except KeyboardInterrupt:
            lass_write(sock, addr, 0)
            print("\nStopped, DAC set to 0")

    else:
        ch = int(cmd)
        val = int(sys.argv[2], 0)
        reg_val = to_signed24(val)
        lass_write(sock, DAC_ADDRS[ch], reg_val)
        readback = lass_read(sock, DAC_ADDRS[ch])
        print(f"DAC{ch} = {val} (0x{reg_val:06X}), readback: 0x{readback:08X}")

    sock.close()

if __name__ == "__main__":
    main()
