#!/usr/bin/env bash
# verify_jal_install.sh — prove this tree is a valid local JAL package for ~/j9.8
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=jenv.sh
source "$ROOT/scripts/jenv.sh"
# shellcheck source=resolve_jconsole.sh
source "$ROOT/scripts/resolve_jconsole.sh"

JCONSOLE="$(jlinter_resolve_jconsole)" || {
  echo "verify: jconsole not found" >&2
  exit 2
}

echo "verify: engine  $JCONSOLE"

ADDONS="$("$JCONSOLE" <<'EOF' 2>/dev/null | tr -d '\r' | tail -n1
9!:35]0
smoutput jpath '~addons'
2!:55 ]0
EOF
)"
[[ -n "$ADDONS" ]] || ADDONS="$HOME/j9.8/addons"
echo "verify: ~addons $ADDONS"

case "$ADDONS" in
  /Applications/*|/System/*)
    echo "verify: refusing system addons tree: $ADDONS" >&2
    exit 1
    ;;
esac
[[ -d "$ADDONS" && -w "$ADDONS" ]] || {
  echo "verify: addons not writable: $ADDONS" >&2
  exit 1
}

STAGE_ROOT="$ROOT/.local-addons-stage"
STAGE="$STAGE_ROOT/debug/jlinter"
LIST="$STAGE_ROOT/files.list"
rm -rf "$STAGE_ROOT"
mkdir -p "$STAGE"

# Validate manifest + write FILES list (all control words inside a verb)
"$JCONSOLE" <<EOF
9!:35]0
validate=. 3 : 0
0!:0 <y
ok=. (0 < # CAPTION) *. (0 < # VERSION) *. ('debug/jlinter' -: FOLDER)
if. -. ok do.
  smoutput 'bad CAPTION/VERSION/FOLDER'
  smoutput CAPTION;VERSION;FOLDER
  1 return.
end.
files=. a: -.~ <;._2 (FILES , LF)
files=. ~. files , <'manifest.ijs'
missing=. 0\$a:
for_f. files do.
  rel=. >f
  p=. '$ROOT/' , rel
  if. '/' = {: rel do.
    if. 0 = # 1!:0 ::(0:"_) < }: p do. missing=. missing , <rel end.
  else.
    if. -. 1:@(1!:4) :: 0: < p do. missing=. missing , <rel end.
  end.
end.
if. # missing do.
  smoutput 'MISSING FILES entries:'
  smoutput ; LF , each missing
  1 return.
end.
(; LF , each files) 1!:2 <'$LIST'
smoutput 'CAPTION=';CAPTION
smoutput 'VERSION=';VERSION
smoutput 'FOLDER=';FOLDER
0
)
2!:55 validate '$ROOT/manifest.ijs'
EOF

echo "verify: manifest CAPTION/VERSION/FOLDER/FILES OK"

while IFS= read -r rel || [[ -n "${rel:-}" ]]; do
  [[ -z "${rel:-}" ]] && continue
  src="$ROOT/$rel"
  if [[ "$rel" == */ ]]; then
    base=$(dirname "${rel%/}")
    name=$(basename "${rel%/}")
    mkdir -p "$STAGE/$base"
    if [[ -d "$src" ]]; then
      rm -rf "$STAGE/$base/$name"
      cp -R "$src" "$STAGE/$base/$name"
    fi
  else
    mkdir -p "$STAGE/$(dirname "$rel")"
    cp "$src" "$STAGE/$rel"
  fi
done < "$LIST"

[[ -f "$STAGE/jlinter.ijs" && -f "$STAGE/report.ijs" && -f "$STAGE/manifest.ijs" ]] || {
  echo "verify: staged package incomplete:" >&2
  find "$STAGE" -type f | sort >&2
  exit 1
}

TARGET="$ADDONS/debug/jlinter"
mkdir -p "$ADDONS/debug"
rm -rf "$TARGET"
mkdir -p "$TARGET"
cp -R "$STAGE"/. "$TARGET"/

echo "verify: installed $TARGET (file install, not symlink)"
ls -la "$TARGET" | head

FIXTURE="$ROOT/fixtures/good_mean.ijs"
"$JCONSOLE" <<EOF
9!:35]0
check=. 3 : 0
smoutput 'install' ; jpath '~install'
smoutput 'addons ' ; jpath '~addons'
load 'debug/jlinter'
if. 3 ~: 4!:0 <'report_jlinter_' do. smoutput 'report_jlinter_ missing' [ 1 return. end.
r=. report_jlinter_ 'text';y
c=. exitcode_jlinter_ ''
smoutput r
if. 0 ~: c do. smoutput 'expected exitcode 0' [ 1 return. end.
load jpath '~addons/debug/jlinter/mcp_j_lint.ijs'
if. 3 ~: 4!:0 <'mcp_j_lint_z_' do. smoutput 'mcp_j_lint_z_ missing' [ 1 return. end.
smoutput mcp_j_lint_z_ ('{"path":"' , y , '","format":"json"}')
0
)
2!:55 check '$FIXTURE'
EOF

echo "verify: shortname load + report + mcp adapter OK"
echo "verify: PASS — package installable under $ADDONS"
echo "github once published:  install 'github:tmcguirefl/jlinter'"
