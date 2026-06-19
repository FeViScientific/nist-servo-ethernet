#!/usr/bin/env python3
"""Receive and parse UDP stream data from SuperLaserLand Ethernet.

Each UDP packet contains 4 samples x 32 bytes = 128 bytes.
Each sample: [16-bit marker 0x2323] [240-bit LoggerData]

LoggerData layout (MSB first, 240 bits = 30 bytes):
  Byte offset  Width  Field
  0-1          16     ADCraw[1]       (signed)
  2-3          16     ADCraw[0]       (signed)
  4-5          16     TRANSFERcos     (signed)
  6-7          16     TRANSFERsin     (signed)
  8-9          16     DACin[2][23:8]  (signed, top 16 of 24)
  10-11        16     DACin[1][23:8]  (signed)
  12-13        16     DACin[0][23:8]  (signed)
  14-17        32     PHASEDETraw     (signed)
  18-19        16     LOCKINout[23:8] (signed, top 16 of 24)
  20-21        16     ADCout[1][23:8] (signed)
  22-23        16     ADCout[0][23:8] (signed)
  24-25        16     {10'b0, DOUT[2:0], DIN[2:0]}
  26-29        32     counter         (unsigned, free-running at 100 MHz)

Usage:
    python3 stream_recv.py                  # print 10 packets
    python3 stream_recv.py -n 100           # print 100 packets
    python3 stream_recv.py -n 0             # continuous (Ctrl+C to stop)
    python3 stream_recv.py --check          # validate stream integrity
    python3 stream_recv.py --csv            # output as CSV
"""

import socket
import struct
import sys
import argparse
import time


# stream_tx.v serializes with byte_cnt^1, swapping bytes within 16-bit words.
# All 16-bit fields arrive little-endian. 32-bit fields arrive as two LE 16-bit words.
FIELDS_16 = [
    ('adc_raw1',    0),
    ('adc_raw0',    2),
    ('tf_cos',      4),
    ('tf_sin',      6),
    ('dacin2',      8),
    ('dacin1',      10),
    ('dacin0',      12),
    # 14-17: PHASEDETraw (32-bit, handled separately)
    ('lockin_out',  18),
    ('adc_filt1',   20),
    ('adc_filt0',   22),
    ('din_dout',    24),    # unsigned
    # 26-29: counter (32-bit, handled separately)
]


def _read_le16s(data, offset):
    """Read little-endian signed 16-bit."""
    return struct.unpack('<h', data[offset:offset+2])[0]


def _read_le16u(data, offset):
    """Read little-endian unsigned 16-bit."""
    return struct.unpack('<H', data[offset:offset+2])[0]


def _read_le32(data, offset):
    """Read 32-bit value stored as two LE 16-bit words (high word first)."""
    hi = struct.unpack('<H', data[offset:offset+2])[0]
    lo = struct.unpack('<H', data[offset+2:offset+4])[0]
    return (hi << 16) | lo


def _read_le32s(data, offset):
    """Read signed 32-bit value stored as two LE 16-bit words."""
    val = _read_le32(data, offset)
    if val >= 0x80000000:
        val -= 0x100000000
    return val


def parse_sample(data):
    """Parse a 32-byte sample (2-byte marker + 30-byte LoggerData)."""
    if len(data) < 32:
        return None
    marker = _read_le16u(data, 0)
    if marker != 0x2323:
        return None

    result = {'marker': marker}
    payload = data[2:32]  # 30 bytes of LoggerData

    for name, offset in FIELDS_16:
        if name == 'din_dout':
            result[name] = _read_le16u(payload, offset)
        else:
            result[name] = _read_le16s(payload, offset)

    result['phasedet'] = _read_le32s(payload, 14)
    result['counter'] = _read_le32(payload, 26)

    # Extract DIN/DOUT
    result['din'] = result['din_dout'] & 0x7
    result['dout'] = (result['din_dout'] >> 3) & 0x7
    return result


def parse_packet(data):
    """Parse a 128-byte packet into 4 samples."""
    samples = []
    for i in range(4):
        s = parse_sample(data[i*32:(i+1)*32])
        if s:
            samples.append(s)
    return samples


def print_sample(s, header=False):
    if header:
        print(f'{"counter":>12s} {"adc0":>7s} {"adc1":>7s} '
              f'{"filt0":>7s} {"filt1":>7s} '
              f'{"dac0":>7s} {"dac1":>7s} {"dac2":>7s} '
              f'{"lockin":>7s} {"phdet":>10s} '
              f'{"sin":>7s} {"cos":>7s} '
              f'{"DIN":>3s} {"DOUT":>4s}')
    print(f'{s["counter"]:12d} {s["adc_raw0"]:+7d} {s["adc_raw1"]:+7d} '
          f'{s["adc_filt0"]:+7d} {s["adc_filt1"]:+7d} '
          f'{s["dacin0"]:+7d} {s["dacin1"]:+7d} {s["dacin2"]:+7d} '
          f'{s["lockin_out"]:+7d} {s["phasedet"]:+10d} '
          f'{s["tf_sin"]:+7d} {s["tf_cos"]:+7d} '
          f'{s["din"]:3d} {s["dout"]:4d}')


def cmd_print(args):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(('0.0.0.0', 5000))
    sock.settimeout(5)

    n = args.n
    count = 0
    printed_header = False
    try:
        while n == 0 or count < n:
            data, addr = sock.recvfrom(2048)
            samples = parse_packet(data)
            for s in samples:
                if not printed_header:
                    print_sample(s, header=True)
                    printed_header = True
                print_sample(s)
                count += 1
                if n > 0 and count >= n:
                    break
    except socket.timeout:
        print(f'Timeout after {count} samples', file=sys.stderr)
    except KeyboardInterrupt:
        print(f'\nStopped after {count} samples', file=sys.stderr)
    sock.close()


def cmd_check(args):
    """Validate stream integrity: check markers, counter continuity, packet rate."""
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(('0.0.0.0', 5000))
    sock.settimeout(5)

    n_packets = args.n if args.n > 0 else 500
    prev_counter = None
    bad_markers = 0
    gaps = 0
    total_samples = 0
    counter_diffs = []
    t0 = time.time()

    try:
        for _ in range(n_packets):
            data, addr = sock.recvfrom(2048)
            if len(data) != 128:
                print(f'Bad packet size: {len(data)}')
                continue

            samples = parse_packet(data)
            for s in samples:
                total_samples += 1
                if s is None:
                    bad_markers += 1
                    continue
                if prev_counter is not None:
                    diff = (s['counter'] - prev_counter) & 0xFFFFFFFF
                    counter_diffs.append(diff)
                    # Expected: 100 MHz / 500 Hz = 200,000 counts between samples
                    if diff < 100000 or diff > 400000:
                        gaps += 1
                prev_counter = s['counter']
    except socket.timeout:
        pass
    except KeyboardInterrupt:
        pass

    elapsed = time.time() - t0
    sock.close()

    print(f'=== Stream Integrity Check ===')
    print(f'Duration:       {elapsed:.1f} s')
    print(f'Packets:        {n_packets}')
    print(f'Total samples:  {total_samples}')
    print(f'Sample rate:    {total_samples / elapsed:.1f} Hz')
    print(f'Bad markers:    {bad_markers}')
    print(f'Counter gaps:   {gaps}')
    if counter_diffs:
        avg = sum(counter_diffs) / len(counter_diffs)
        mn = min(counter_diffs)
        mx = max(counter_diffs)
        print(f'Counter diff:   avg={avg:.0f}  min={mn}  max={mx}')
        print(f'Implied rate:   {100e6 / avg:.1f} Hz')
        print(f'Expected:       200000 counts (500 Hz at 100 MHz)')


def cmd_csv(args):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(('0.0.0.0', 5000))
    sock.settimeout(5)

    names = [f[0] for f in FIELDS_16] + ['phasedet', 'counter']
    print(','.join(names))

    n = args.n
    count = 0
    try:
        while n == 0 or count < n:
            data, addr = sock.recvfrom(2048)
            for s in parse_packet(data):
                vals = [str(s[n]) for n in names]
                print(','.join(vals))
                count += 1
                if n > 0 and count >= n:
                    break
    except (socket.timeout, KeyboardInterrupt):
        pass
    sock.close()


def main():
    p = argparse.ArgumentParser(description='Receive SuperLaserLand stream data')
    p.add_argument('-n', type=int, default=20, help='Number of samples (0=continuous)')
    p.add_argument('--check', action='store_true', help='Validate stream integrity')
    p.add_argument('--csv', action='store_true', help='Output as CSV')
    args = p.parse_args()

    if args.check:
        cmd_check(args)
    elif args.csv:
        cmd_csv(args)
    else:
        cmd_print(args)


if __name__ == '__main__':
    main()
