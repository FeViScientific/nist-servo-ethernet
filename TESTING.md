# Testing the flash / config / network features

Validation is split into three layers. **A** (RTL sim) and **B** (Python logic)
run anywhere with no FPGA. **C** runs against a programmed, network-reachable
board. **D** are manual procedures that require power-cycling and a jumper.

Each automated layer writes a `*_results.txt` file so results can be `rsync`-ed
back from the test machine and reviewed.

## Layer A — RTL simulation (offline, iverilog)

```bash
./run_sim_tests.sh        # -> test_sim_results.txt
```

- `tb_flash_spi.v`: full-duplex transfers of 1 / 5 / 256 / 512 bytes + two
  back-to-back transfers (CS re-framing, busy/done handshake, RX capture).
- `tb_net_config_loader.v`: valid block loads MAC/IP; loopback → recovery;
  bad magic / bad checksum / blank flash → default kept; inverted loopback does
  **not** false-trigger recovery (falls through to the flash load).

## Layer B — Python logic + GUI (offline)

```bash
python3 test_offline.py   # -> test_offline_results.txt   (needs PyQt5 for the GUI checks)
```

Covers `config_regs` (210 regs), register-snapshot serialize/CRC, the GUI blob
and network-block framing (incl. byte-exact match to the FPGA block, blank and
corrupt cases), all five GUI panels' `get→apply` round-trip, and the MainWindow
save→perturb→load aggregate restore.

## Layer C — Hardware-in-the-loop (programmed board)

```bash
python3 test_hardware.py [HOST] [--scratch 0xADDR]   # -> test_hardware_results.txt
```

Default `HOST=192.168.7.140`. **Non-destructive:** every test that writes flash
backs up the affected sector and restores it; the raw-flash test (C2/C3) only
runs if the scratch sector (default `0x3C0000`, sector 60) is already blank, and
otherwise skips rather than risk erasing unknown data; register writes are
restored. Tests: JEDEC ID, raw erase/program/read, page-boundary program,
`save/load_config`, stream destination, GUI blob, network config block, and boot
status.

### rsync workflow
```bash
# from this machine:
rsync -av --exclude='*.bit' --exclude='Bedrock/.git' ./ user@testhost:nist-servo/
# on the test host (FPGA reachable):
cd nist-servo && python3 test_hardware.py
# bring results back:
rsync -av user@testhost:nist-servo/test_hardware_results.txt ./
```
(`Bedrock/` is needed at the test host for `lbus_access.py`; don't exclude it.)

## Layer D — Manual procedures (power-cycle / jumper)

Record outcomes by hand (e.g. in `test_manual_results.txt`). `servo_cli.py`
takes `--host <IP>` to target a specific address.

### D1 — Network identity change, end-to-end
1. `python3 servo_cli.py net-config` — note the current stored config.
2. `python3 servo_cli.py set-net-config AA:00:55:00:01:50 192.168.7.150`
   (pick a free IP on the same subnet).
3. Power-cycle the FPGA (or re-`make program`).
4. `python3 servo_cli.py --host 192.168.7.150 status` → **responds**.
   `python3 servo_cli.py --host 192.168.7.140 status` → **times out**.
5. Restore: `python3 servo_cli.py --host 192.168.7.150 set-net-config AA:00:55:00:01:23 192.168.7.140`,
   power-cycle, confirm it answers at `192.168.7.140` again.

### D2 — Recovery loopback
1. Power **off**. Jumper **DOUT[1] (pin L22) → DIN[1] (pin D21)**.
2. Power **on**.
3. `python3 servo_cli.py --host 192.168.7.140 net-config` → responds at the
   **default** IP even if a different IP is stored; `recovery_active` is True.
4. Power off, **remove the jumper**, power on → boots at the stored config again.

### D3 — Cold-boot autoload
1. With a valid stored network config (from D1 step 2), power-cycle.
2. Confirm the board comes up at the stored MAC/IP automatically (the boot
   loader ran): `servo_cli.py --host <stored IP> net-config` shows `boot_done`
   and the stored address.

## Quick all-offline run
```bash
./run_sim_tests.sh && python3 test_offline.py
```
