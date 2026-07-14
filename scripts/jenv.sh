# shellcheck shell=bash
# Sourceable environment for this project (user-local J under $HOME/j9.8).
# Usage:
#   source ./scripts/jenv.sh
#   ./bin/jlinter fixtures/good_mean.ijs
#
# Does not touch /Applications/j9.8.

# Prefer explicit override, then ~/.j9.8 install, then leave unset for caller fallbacks.
if [[ -z "${JLINTER_JCONSOLE:-}" ]]; then
  if [[ -x "${HOME}/j9.8/bin/jconsole" ]]; then
    export JLINTER_JCONSOLE="${HOME}/j9.8/bin/jconsole"
  fi
fi

# j-mcp / libj discovery convention
if [[ -z "${JHOME:-}" && -d "${HOME}/j9.8/bin" ]]; then
  export JHOME="${HOME}/j9.8/bin"
fi

# Help interactive shells pick the local engine first when users type `jconsole`
if [[ -x "${HOME}/j9.8/bin/jconsole" ]]; then
  case ":${PATH}:" in
    *":${HOME}/j9.8/bin:"*) ;;
    *) export PATH="${HOME}/j9.8/bin:${PATH}" ;;
  esac
fi
