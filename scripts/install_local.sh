#!/usr/bin/env bash
# Symlink this checkout into the private J install's ~addons/tmcguire/jlinter:
#   $HOME/j9.8/addons/tmcguire/jlinter  →  this repo
#
# Then:  load 'tmcguire/jlinter'
# Prefer this account's ~/j9.8 engine; does not write under /Applications/j9.8.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=resolve_jconsole.sh
source "$ROOT/scripts/resolve_jconsole.sh"

JCONSOLE="$(jlinter_resolve_jconsole)" || {
  echo "install_local: jconsole not found; set JLINTER_JCONSOLE to \$HOME/j9.8/bin/jconsole" >&2
  exit 2
}

ADDONS="$("$JCONSOLE" <<'EOF' 2>/dev/null | tr -d '\r' | tail -n1
9!:35]0
smoutput jpath '~addons'
2!:55 ]0
EOF
)"

if [[ -z "$ADDONS" || ! -d "$ADDONS" ]]; then
  # Fallback to the known private install layout
  ADDONS="${HOME}/j9.8/addons"
fi

if [[ ! -d "$ADDONS" ]]; then
  echo "install_local: addons dir missing: $ADDONS" >&2
  exit 2
fi
if [[ ! -w "$ADDONS" ]]; then
  echo "install_local: addons dir not writable: $ADDONS" >&2
  echo "  expected private install under \$HOME/j9.8 (not /Applications/j9.8)" >&2
  exit 1
fi

# Refuse accidental writes into the multi-account system apps tree
case "$ADDONS" in
  /Applications/*|/System/*)
    echo "install_local: refusing to install into system tree: $ADDONS" >&2
    echo "  point JLINTER_JCONSOLE at \$HOME/j9.8/bin/jconsole" >&2
    exit 1
    ;;
esac

TARGET_DIR="$ADDONS/tmcguire"
TARGET="$TARGET_DIR/jlinter"
mkdir -p "$TARGET_DIR"

FORCE=0
if [[ "${1:-}" == "--force" || "${1:-}" == "-f" ]]; then
  FORCE=1
fi

if [[ -e "$TARGET" && ! -L "$TARGET" ]]; then
  if [[ "$FORCE" -eq 1 ]]; then
    echo "install_local: removing existing non-symlink install at $TARGET"
    rm -rf "$TARGET"
  else
    echo "install_local: $TARGET exists and is not a symlink; refuse to overwrite" >&2
    echo "  (real install left by verify_jal_install.sh is fine for load 'tmcguire/jlinter')" >&2
    echo "  use: $0 --force   to replace it with a checkout symlink for live edits" >&2
    exit 1
  fi
fi

ln -sfn "$ROOT" "$TARGET"
echo "install_local: engine   $JCONSOLE"
echo "install_local: ~addons  $ADDONS"
echo "install_local: link     $TARGET -> $ROOT"
echo "Try:  \$HOME/j9.8/bin/jconsole"
echo "      load 'tmcguire/jlinter'"
