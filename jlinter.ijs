NB. debug/tmcguirefl/jlinter - headless wrapper around debug/lint
NB.
NB. After install from GitHub / JAL:
NB.   load 'debug/tmcguirefl/jlinter/jlinter'
NB.   echo report_jlinter_ 'markdown';'path/to/script.ijs'
NB.   echo exitcode_jlinter_ ''
NB.
NB. Optional MCP adapter (j-mcp j_tool_register):
NB.   load '~addons/debug/tmcguirefl/jlinter/mcp_j_lint.ijs'

NB. Capture this script's directory *before* any require (which would
NB. change {: 4!:3 '').
JLINTER_DIR_z_=: 3 : 0 ''
  me=. > {: 4!:3 ''
  slash=. me i: '/'
  (slash + 1) {. me
)

require 'debug/lint'
require 'convert/json'

NB. Load report module from the package directory.
load JLINTER_DIR_z_ , 'report.ijs'
