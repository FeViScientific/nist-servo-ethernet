#!/usr/bin/env bash
# run_sim_tests.sh - compile and run the RTL (iverilog) testbenches for the
# flash/network features and write a results file. No FPGA required.
#
# Usage: ./run_sim_tests.sh
# Output: test_sim_results.txt (and stdout)

set -u
cd "$(dirname "$0")"

IVERILOG=${IVERILOG:-iverilog}
VVP=${VVP:-vvp}
OUT=test_sim_results.txt
TMP=$(mktemp -d)
: > "$OUT"

fail=0

run_tb() {
    local name="$1"; shift
    echo "=== $name ===" | tee -a "$OUT"
    if ! "$IVERILOG" -g2012 -o "$TMP/$name.vvp" "$@" >>"$OUT" 2>&1; then
        echo "  COMPILE FAILED" | tee -a "$OUT"; fail=1; return
    fi
    "$VVP" "$TMP/$name.vvp" 2>&1 | grep -E "PASS|FAIL|ALL|RESULT" | tee -a "$OUT"
    if "$VVP" "$TMP/$name.vvp" 2>&1 | grep -q "FAIL"; then fail=1; fi
}

echo "RTL SIMULATION TESTS - $(date 2>/dev/null || echo)" | tee -a "$OUT"
run_tb flash_spi        tb_flash_spi.v flash_spi.v
run_tb net_config_loader tb_net_config_loader.v net_config_loader.v flash_spi.v
run_tb sweep            tb_sweep.v Sweep.v

echo "" | tee -a "$OUT"
if [ "$fail" -eq 0 ]; then
    echo "SIM RESULT: ALL PASS" | tee -a "$OUT"
else
    echo "SIM RESULT: FAILURES PRESENT" | tee -a "$OUT"
fi
rm -rf "$TMP"
echo "Wrote $OUT"
exit "$fail"
