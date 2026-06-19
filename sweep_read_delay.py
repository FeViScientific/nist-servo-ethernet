#!/usr/bin/env python3
"""Sweep read_delay 0-7 and test LASS reads at each setting."""

import socket
import struct
import time

IP = "192.168.7.140"
PORT = 803

def lass_packet(operations):
    """Build LASS packet. operations: list of (is_read, addr, data)."""
    msg = struct.pack(">II", 0, 0)  # 8-byte txn ID
    for is_read, addr, data in operations:
        cmd = 0x10 if is_read else 0x00
        msg += struct.pack(">I", (cmd << 24) | (addr & 0xFFFFFF))
        msg += struct.pack(">I", data)
    return msg

def lass_transact(sock, operations):
    """Send LASS packet, return response data words."""
    msg = lass_packet(operations)
    sock.sendto(msg, (IP, PORT))
    try:
        resp, _ = sock.recvfrom(4096)
        results = []
        for i in range(len(operations)):
            offset = 8 + i * 8 + 4
            if offset + 4 <= len(resp):
                results.append(struct.unpack(">I", resp[offset:offset+4])[0])
            else:
                results.append(None)
        return results
    except socket.timeout:
        return None

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.settimeout(1.0)

# First write a known value to scratch0
lass_transact(sock, [(False, 0x00, 0xDEADBEEF)])
time.sleep(0.05)

print("Sweeping read_delay 0-7...")
print("Writing 0xDEADBEEF to scratch0, then reading back at each delay\n")
print(f"{'delay':>5} | {'scratch0':>12} | {'firmware_id':>12} | {'status':>12}")
print("-" * 55)

for delay in range(8):
    # Write read_delay register (addr 0x04)
    lass_transact(sock, [(False, 0x04, delay)])
    time.sleep(0.05)

    # Read scratch0 (0x00), firmware ID (0x20), status (0x21)
    resp = lass_transact(sock, [
        (True, 0x00, 0),
        (True, 0x20, 0),
        (True, 0x21, 0),
    ])

    if resp:
        s0 = f"0x{resp[0]:08X}" if resp[0] is not None else "timeout"
        fw = f"0x{resp[1]:08X}" if resp[1] is not None else "timeout"
        st = f"0x{resp[2]:08X}" if resp[2] is not None else "timeout"
        match = " <-- MATCH" if resp[0] == 0xDEADBEEF and resp[1] == 0x0000BEEF else ""
        print(f"  {delay:>3} | {s0:>12} | {fw:>12} | {st:>12}{match}")
    else:
        print(f"  {delay:>3} | {'no response':>12} | {'':>12} | {'':>12}")

sock.close()
