#!/usr/bin/env bash
# Install a *runtime* copy of tmcguire/jlinter into the private J tree:
#   $HOME/j9.8/addons/tmcguire/jlinter/
#
# Only runtime FILES are placed there (not the whole git checkout).
# Prefer this account's ~/j9.8 engine; does not write under /Applications/j9.8.
#
# Usage:
#   ./scripts/install_local.sh           # copy runtime FILES only
#   ./scripts/install_local.sh --force   # replace existing target
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=resolve_jconsole.sh
source "$ROOT/scripts/resolve_jconsole.sh"

# Must match FILES in manifest.ijs (runtime package only)
RUNTIME_FILES=(
  manifest.ijs
  jlinter.ijs
  report.ijs
  mcp_j_lint.ijs
  history.txt
)

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

if [[ -e "$TARGET" || -L "$TARGET" ]]; then
  if [[ "$FORCE" -eq 1 ]]; then
    echo "install_local: replacing existing target $TARGET"
    rm -rf "$TARGET"
  else
    echo "install_local: $TARGET already exists; refuse to overwrite" >&2
    echo "  use: $0 --force" >&2
    exit 1
  fi
fi

mkdir -p "$TARGET"

for rel in "${RUNTIME_FILES[@]}"; do
  if [[ ! -f "$ROOT/$rel" ]]; then
    echo "install_local: missing source file: $ROOT/$rel" >&2
    exit 1
  fi
  cp "$ROOT/$rel" "$TARGET/$rel"
  echo "install_local: + $rel"
done

# Guard: never leave a symlink to the full checkout
if [[ -L "$TARGET" ]]; then
  echo "install_local: internal error: target is a symlink" >&2
  exit 1
fi

echo "install_local: engine   $JCONSOLE"
echo "install_local: ~addons  $ADDONS"
echo "install_local: target   $TARGET  (runtime files only)"
echo "install_local: listing:"
ls -la "$TARGET"
echo "Try:  load 'tmcguire/jlinter'"
