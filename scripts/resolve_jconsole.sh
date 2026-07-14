# shellcheck shell=bash
# Shared: printf absolute path to jconsole on stdout and return 0, else 1.
# Order:
#   1) $JLINTER_JCONSOLE
#   2) $JCONSOLE
#   3) $HOME/j9.8/bin/jconsole   (this account's private install)
#   4) /Applications/j9.8/bin/jconsole  (system install, last resort)
#   5) first jconsole on PATH that is not the macOS Java stub path /usr/bin

jlinter_resolve_jconsole() {
  local c
  for c in \
    "${JLINTER_JCONSOLE:-}" \
    "${JCONSOLE:-}" \
    "${HOME}/j9.8/bin/jconsole" \
    "/Applications/j9.8/bin/jconsole"
  do
    if [[ -n "$c" && -x "$c" ]]; then
      printf '%s\n' "$c"
      return 0
    fi
  done
  if command -v jconsole >/dev/null 2>&1; then
    c="$(command -v jconsole)"
    # Prefer not /usr/bin/jconsole (macOS JavaLauncher stub) if a real one exists
    if [[ "$c" != "/usr/bin/jconsole" && -x "$c" ]]; then
      printf '%s\n' "$c"
      return 0
    fi
  fi
  return 1
}
