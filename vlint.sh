#!/usr/bin/env bash
#
# vlint.sh - Verilator lint for the SuperLaserLand project RTL.
#
# Lints the project's own Verilog (servo/DSP core, peripheral drivers, board
# glue, streaming, DDR2) and deliberately EXCLUDES files that belong to Badger
# (the Bedrock/badger Ethernet stack) and Xilinx vendor IP (ipcore_dir, mig).
# Those are still made *visible* to Verilator via -y library dirs so that module
# instances in our code resolve during elaboration -- but warnings originating
# inside them are filtered out so you only see issues in code you own.
#
# Usage:
#   ./vlint.sh              Lint the whole project (top-level elaboration)
#   ./vlint.sh <file.v>...  Lint only the given file(s), standalone
#   ./vlint.sh --raw ...    Don't filter out Badger/IP warnings
#   ./vlint.sh --all-warns  Add extra pedantic warnings (-Wall already on)
#
# Mirrors:  alias vlint='verilator --lint-only -Wall'
set -u

cd "$(dirname "$0")"

# --- Verilator invocation -----------------------------------------------------
VERILATOR=${VERILATOR:-verilator}
LINT_FLAGS=(--lint-only -Wall -Wno-fatal)
# PINCONNECTEMPTY: this design intentionally uses the `.pin()` empty-connect
# idiom for unused outputs (submodule debug ports + unused Xilinx primitive
# outputs like PLL_BASE.CLKOUT3-5, OSERDES2.SHIFTOUT/OQ/TQ). It's a style
# warning, not a bug, so suppress it -- but warn each run so you remember it's
# off (an *accidental* empty connect won't be caught while suppressed).
LINT_FLAGS+=(-Wno-PINCONNECTEMPTY)
echo "vlint: NOTE: PINCONNECTEMPTY suppressed (empty .pin() connections not checked)" >&2
# PINMISSING: instances that omit some pins entirely (e.g. rtefi_blob_inst
# leaves out host_raddr). Suppressed for now and handled like PINCONNECTEMPTY --
# but warn each run, since a genuinely forgotten pin won't be caught while off.
LINT_FLAGS+=(-Wno-PINMISSING)
echo "vlint: NOTE: PINMISSING suppressed (instances with omitted pins not checked)" >&2
# TIMESCALEMOD: not every module carries its own `timescale (some rely on the
# included timescale.v / inherit it). Harmless for lint, so suppress -- warn
# each run so it's not forgotten.
LINT_FLAGS+=(-Wno-TIMESCALEMOD)
echo "vlint: NOTE: TIMESCALEMOD suppressed (per-module timescale not checked)" >&2

# Library search dirs: project root (for `include "timescale.v"` and project
# modules) plus the excluded trees so their modules resolve as libraries.
LIB_DIRS=(-I. -y . -y Bedrock/badger -y ipcore_dir -y mig)

# Verilator's default library file extension is .v, which is what we use.

# --- Project (non-Badger) source files ----------------------------------------
# Top module + all of its project-owned dependencies. Badger top-level files
# (rtefi_blob.v, rtefi_center.v, rmii_gmii.v, construct_tx_table.v) and the
# ipcore_dir/* + mig/* vendor IP are intentionally NOT listed here; they are
# pulled in on demand via the -y dirs above.
TOP_MODULE=SuperLaserLand_Ethernet_Bare
PROJECT_SOURCES=(
  SuperLaserLand_Ethernet_Bare.v
  # servo / DSP / control core
  IIRfilter1stOrder.v
  IIRfilter1stOrderAntiWindup.v
  IIRfilter2ndOrderSlow.v
  IIRfilter2ndOrderSlowAntiWindup.v
  Limit.v
  Sweep.v
  Relock.v
  DigitalDelay.v
  LockIn.v
  LPfilter.v
  PhaseDetector.v
  TransferFunction.v
  # peripheral drivers
  LTC2195.v
  AD9783.v
  AD5791.v
  AD8251x2.v
  SPI.v
  FractionalDAC.v
  # board glue (project-written for this Spartan-6 / LAN8720A port)
  ethernet_clkgen_s6.v
  rmii_iob.v
  # streaming + DDR2 capture
  stream_tx.v
  stream_tx_header.v
  DDR2Logger.v
  ddr2_controller.v
)

# --- Output filter: drop warning blocks located in excluded trees -------------
# Verilator prints a header line ("%Warning-XXX: path:line:col: msg") followed
# by indented context lines. We keep/drop whole blocks by the header's path.
filter_foreign() {
  awk '
    /^%(Warning|Error)/ {
      # decide based on the file path in the header
      keep = !($0 ~ /Bedrock\/|ipcore_dir\/|(^|[ :])mig\//)
    }
    { if (keep) print }
    # lines before any header (banners, summaries) print by default
    !/^%(Warning|Error)/ && NR==1 { }
  ' keep=1
}

# --- Parse args ---------------------------------------------------------------
RAW=0
FILES=()
for arg in "$@"; do
  case "$arg" in
    --raw)       RAW=1 ;;
    --all-warns) LINT_FLAGS+=(-Wpedantic) ;;
    -*)          LINT_FLAGS+=("$arg") ;;   # pass through other verilator flags
    *)           FILES+=("$arg") ;;
  esac
done

# --- Run ----------------------------------------------------------------------
run() {
  if [ "$RAW" -eq 1 ]; then
    "$VERILATOR" "${LINT_FLAGS[@]}" "${LIB_DIRS[@]}" "$@" 2>&1
  else
    "$VERILATOR" "${LINT_FLAGS[@]}" "${LIB_DIRS[@]}" "$@" 2>&1 | filter_foreign
  fi
  return "${PIPESTATUS[0]}"
}

if [ "${#FILES[@]}" -gt 0 ]; then
  echo "vlint: linting ${#FILES[@]} file(s) standalone"
  run "${FILES[@]}"
else
  echo "vlint: linting project (top=$TOP_MODULE, Badger + vendor IP excluded)"
  run --top-module "$TOP_MODULE" "${PROJECT_SOURCES[@]}"
fi
