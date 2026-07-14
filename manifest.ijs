NB. manifest for debug/tmcguirefl/jlinter
NB. See: https://code.jsoftware.com/wiki/Addons/Developers_Guide
NB. Install from GitHub (this author's repo):
NB.   install 'github:tmcguirefl/jlinter'
NB.   load 'debug/tmcguirefl/jlinter/jlinter'
NB.
NB. Optional repo name synonym often used for JAL mirrors:
NB.   install 'github:tmcguirefl/debug_jlinter'

CAPTION=: 'Headless J script linter for agents and CLI'

DESCRIPTION=: 0 : 0
Headless static checker wrapping stock debug/lint.

Formats findings as markdown, JSON, or plain text for Claude Code
and other agent/CLI workflows. Includes an optional MCP adapter for
j-mcp (j_tool_register) and a bash CLI under bin/.

Usage after install:
  load 'debug/tmcguirefl/jlinter/jlinter'
  echo report_jlinter_ 'markdown';'path/to/script.ijs'
  echo exitcode_jlinter_ ''

CLI (from a checkout or if bin is on PATH):
  jlinter path/to/script.ijs
  jlinter -f json path/to/script.ijs

GitHub install (Pacman) into the current J's ~addons (e.g. ~/j9.8/addons):
  install 'github:tmcguirefl/jlinter'
  load 'debug/tmcguirefl/jlinter/jlinter'

Depends on debug/lint (stock) and convert/json (stock).
)

VERSION=: '0.1.1'

RELEASE=: 'j901'

FOLDER=: 'debug/tmcguirefl/jlinter'

PLATFORMS=: ''

DEPENDS=: 0 : 0
debug/lint
convert/json
)

FILES=: 0 : 0
manifest.ijs
jlinter.ijs
report.ijs
mcp_j_lint.ijs
history.txt
LICENSE
README.md
CLAUDE.md
bin/
docs/
fixtures/
scripts/
.claude/skills/
)
