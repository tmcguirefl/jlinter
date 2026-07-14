#!/usr/bin/env bash
# smoke.sh — minimal regression for jlinter (uses private ~/j9.8 when present)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=jenv.sh
source "$ROOT/scripts/jenv.sh"
BIN="$ROOT/bin/jlinter"
F="$ROOT/fixtures"
fail=0

echo "smoke: JLINTER_JCONSOLE=${JLINTER_JCONSOLE:-unset}"

run_expect() {
  local expect="$1"; shift
  local label="$1"; shift
  set +e
  out=$("$BIN" "$@" 2>&1)
  ec=$?
  set -e
  if [[ "$ec" -ne "$expect" ]]; then
    echo "FAIL $label: expected exit $expect got $ec"
    echo "$out"
    fail=1
  else
    echo "ok   $label (exit $ec)"
  fi
}

run_expect 0 good_text   -f text "$F/good_mean.ijs"
run_expect 0 good_md     -f markdown "$F/good_mean.ijs"
run_expect 1 bad_text    -f text "$F/bad_undefined.ijs"
run_expect 1 bad_json    -f json "$F/bad_undefined.ijs"
run_expect 1 bad_control -f text "$F/bad_control.ijs"

set +e
out=$(cat "$F/good_mean.ijs" | "$BIN" --stdin -f text 2>&1)
ec=$?
set -e
if [[ "$ec" -ne 0 ]]; then
  echo "FAIL stdin_good: expected 0 got $ec"
  echo "$out"
  fail=1
else
  echo "ok   stdin_good (exit $ec)"
fi

if [[ "$fail" -ne 0 ]]; then
  echo "smoke: FAILED"
  exit 1
fi
echo "smoke: all passed"
