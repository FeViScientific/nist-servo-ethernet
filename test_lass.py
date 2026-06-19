#!/usr/bin/env python3
"""LASS register read/write test for bare Ethernet build.

LASS packet format (big-endian):
  [8 bytes] Transaction ID (echoed back)
  For each operation:
    [4 bytes] Command(8 bits) + Address(24 bits)
    [4 bytes] Data (write value, or placeholder for read)

  Command byte: bit 0 = read (1) / write (0)
  Response: same packet with read data filled in.
"""

import socket
import struct
import sys

IP = "192.168.7.140"
PORT = 803
TIMEOUT = 1.0

def lass_rw(sock, operations, txn_id=0):
    """Send LASS packet with list of (read/write, addr, data) operations.

    operations: list of (is_read, addr, data) tuples
    Returns list of response data words.
    """
    # Build packet: 8-byte txn ID + pairs of (cmd+addr, data)
    msg = struct.pack(">II", txn_id >> 32, txn_id & 0xFFFFFFFF)
    for is_read, addr, data in operations:
        cmd = 0x10 if is_read else 0x00  # Read flag is bit 28 (0x10 << 24)
        msg += struct.pack(">I", (cmd << 24) | (addr & 0xFFFFFF))
        msg += struct.pack(">I", data)

    sock.sendto(msg, (IP, PORT))
    try:
        resp, _ = sock.recvfrom(4096)
        # Parse response: skip 8-byte header, then extract data words
        results = []
        for i in range(len(operations)):
            offset = 8 + i * 8 + 4  # skip header + cmd word, get data word
            if offset + 4 <= len(resp):
                results.append(struct.unpack(">I", resp[offset:offset+4])[0])
            else:
                results.append(None)
        return results
    except socket.timeout:
        return None

def lass_write(sock, addr, data):
    """Write 32-bit data to address."""
    lass_rw(sock, [(False, addr, data)])  # response consumed by lass_rw

def lass_read(sock, addr):
    """Read 32-bit data from address."""
    resp = lass_rw(sock, [(True, addr, 0)])
    if resp and len(resp) >= 1:
        return resp[0]
    return None

def main():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.settimeout(TIMEOUT)

    print("=== LASS Register Test ===\n")

    # Read firmware ID
    val = lass_read(sock, 0x20)
    if val is None:
        print("FAIL: No response from FPGA. Check connection.")
        sys.exit(1)
    print(f"Firmware ID:  0x{val:08X}  {'PASS' if val == 0x0000ADC1 else 'FAIL (expected 0x0000ADC1)'}")

    # Read status
    val = lass_read(sock, 0x21)
    print(f"Status:       0x{val:08X}  (bit 0 = PLL locked: {val & 1})")

    # Scratch register read/write test
    print("\n--- Scratch R/W Test ---")
    test_patterns = [0x00000000, 0xFFFFFFFF, 0xA5A5A5A5, 0x12345678, 0xDEADBEEF]
    all_pass = True
    for pattern in test_patterns:
        lass_write(sock, 0x00, pattern)
        readback = lass_read(sock, 0x00)
        ok = readback == pattern
        if not ok:
            all_pass = False
        print(f"  Write 0x{pattern:08X}, Read 0x{readback:08X}  {'PASS' if ok else 'FAIL'}")

    # Second scratch register
    lass_write(sock, 0x01, 0xCAFEBABE)
    val = lass_read(sock, 0x01)
    ok = val == 0xCAFEBABE
    if not ok:
        all_pass = False
    print(f"  Scratch1: Write 0xCAFEBABE, Read 0x{val:08X}  {'PASS' if ok else 'FAIL'}")

    # Verify scratch0 wasn't clobbered by scratch1 write
    val = lass_read(sock, 0x00)
    ok = val == 0xDEADBEEF
    if not ok:
        all_pass = False
    print(f"  Scratch0 preserved: 0x{val:08X}  {'PASS' if ok else 'FAIL'}")

    # Packet counters
    print("\n--- Counters ---")
    rx = lass_read(sock, 0x10)
    tx = lass_read(sock, 0x11)
    uptime = lass_read(sock, 0x12)
    print(f"  RX packets: {rx}")
    print(f"  TX packets: {tx}")
    print(f"  Uptime:     {uptime} (~{uptime * 80e-9:.3f} sec)")

    # LED test
    print("\n--- LED Test ---")
    lass_write(sock, 0x02, 0x55)
    val = lass_read(sock, 0x02)
    print(f"  LED reg: 0x{val:02X} (alternating pattern on board LEDs)")

    # Read unimplemented address
    val = lass_read(sock, 0xFF)
    print(f"\n  Unimplemented addr 0xFF: 0x{val:08X}  {'PASS' if val == 0xDEADDEAD else 'unexpected'}")

    # Multi-operation test
    print("\n--- Multi-op in single packet ---")
    lass_write(sock, 0x00, 0x11111111)
    lass_write(sock, 0x01, 0x22222222)
    resp = lass_rw(sock, [
        (True, 0x00, 0),
        (True, 0x01, 0),
        (True, 0x20, 0),
    ])
    if resp:
        print(f"  scratch0=0x{resp[0]:08X} scratch1=0x{resp[1]:08X} fwid=0x{resp[2]:08X}")
        ok = resp[0] == 0x11111111 and resp[1] == 0x22222222 and resp[2] == 0x0000ADC1
        if not ok:
            all_pass = False
        print(f"  {'PASS' if ok else 'FAIL'}")

    # DAC register tests
    print("\n--- DAC Register R/W Test ---")
    dac_regs = {0x100: "DAC0", 0x101: "DAC1", 0x102: "DAC2"}
    for addr, name in dac_regs.items():
        # Write positive value
        lass_write(sock, addr, 0x007FFFFF)  # max positive 24-bit
        val = lass_read(sock, addr)
        ok = val == 0x007FFFFF
        if not ok:
            all_pass = False
        print(f"  {name} +max: write 0x007FFFFF, read 0x{val:08X}  {'PASS' if ok else 'FAIL'}")

        # Write negative value (sign-extended on readback)
        lass_write(sock, addr, 0x00800000)  # -8388608 in 24-bit signed
        val = lass_read(sock, addr)
        ok = val == 0xFF800000  # sign-extended to 32-bit
        if not ok:
            all_pass = False
        print(f"  {name} -max: write 0x00800000, read 0x{val:08X}  {'PASS' if ok else 'FAIL'}")

        # Zero
        lass_write(sock, addr, 0)
        val = lass_read(sock, addr)
        ok = val == 0
        if not ok:
            all_pass = False
        print(f"  {name} zero: write 0, read 0x{val:08X}  {'PASS' if ok else 'FAIL'}")

    # Gain register
    lass_write(sock, 0x103, 0x0F)
    val = lass_read(sock, 0x103)
    ok = val == 0x0F
    if not ok:
        all_pass = False
    print(f"  Gain: write 0x0F, read 0x{val:08X}  {'PASS' if ok else 'FAIL'}")

    # Set DACs to midscale (0) for safe default
    for addr in dac_regs:
        lass_write(sock, addr, 0)

    print(f"\n{'ALL TESTS PASSED' if all_pass else 'SOME TESTS FAILED'}")
    sock.close()

if __name__ == "__main__":
    main()
