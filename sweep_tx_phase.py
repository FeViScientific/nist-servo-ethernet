#!/usr/bin/env python3
"""Sweep tx_phase 0-7 and test ping at each setting.
Uses raw UDP to write the tx_phase register (no ARP needed for write).
Then tests if ping works.

Note: The first write might not arrive if ARP hasn't resolved yet.
We send the write as a broadcast to bypass ARP.
"""
import subprocess
import socket
import struct
import time
import sys

IP = "192.168.7.140"
PORT = 803

def lass_write_raw(phase):
    """Send LASS write packet to set tx_phase register (addr 0x03)."""
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.settimeout(0.5)
    # Transaction ID + write addr 0x03 + data
    msg = struct.pack(">II", 0, 0)  # 8-byte txn ID
    msg += struct.pack(">I", 0x00000003)  # write (cmd=0x00), addr=0x03
    msg += struct.pack(">I", phase)       # data
    sock.sendto(msg, (IP, PORT))
    sock.close()

def test_ping():
    """Return True if ping succeeds."""
    try:
        result = subprocess.run(
            ["ping", "-c", "1", "-W", "1", IP],
            capture_output=True, timeout=3
        )
        return result.returncode == 0
    except:
        return False

# Flush ARP cache
subprocess.run(["sudo", "ip", "neigh", "flush", IP], capture_output=True)

print("Sweeping tx_phase 0-7...")
print("(LEDs show current phase on lower 3 bits)\n")

for phase in range(8):
    # Clear ARP entry before each test
    subprocess.run(["sudo", "ip", "neigh", "del", IP, "dev", "enp0s31f6"],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    # Send write multiple times (in case first one is lost)
    for _ in range(3):
        lass_write_raw(phase)
        time.sleep(0.05)

    time.sleep(0.3)  # Let PHY settle

    ok = test_ping()
    print(f"  tx_phase={phase} ({phase*45:3d} deg): {'PING OK' if ok else 'no response'}")

print("\nDone. Set the working phase with:")
print("  python3 -c \"import socket,struct; s=socket.socket(socket.AF_INET,socket.SOCK_DGRAM); s.sendto(struct.pack('>IIII',0,0,3,PHASE),('" + IP + "'," + str(PORT) + "))\"")
