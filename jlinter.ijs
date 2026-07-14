NB. tmcguire/jlinter - headless wrapper around debug/lint
NB.
NB. After install from GitHub / JAL:
NB.   load 'tmcguire/jlinter'
NB.   echo report_jlinter_ 'markdown';'path/to/script.ijs'
NB.   echo exitcode_jlinter_ ''
NB.
NB. Optional MCP adapter (j-mcp j_tool_register):
NB.   load 'tmcguire/jlinter/mcp_j_lint'

require 'debug/lint'
require 'convert/json'

NB. Load report.ijs via shortname/addon path first; avoid relying only on
NB. {: 4!:3 '' after other scripts have been loaded (j-mcp sessions).
(3 : 0) ''
  cands=. jpath each 'tmcguire/jlinter/report.ijs';'~addons/tmcguire/jlinter/report.ijs'
  me=. > {: 4!:3 ''
  slash=. me i: '/'
  cands=. cands , < ((slash + 1) {. me) , 'report.ijs'
  found=. 0
  for_c. cands do.
    p=. > c
    if. 1:@(1!:4) :: 0: < p do.
      load p
      found=. 1
      break.
    end.
  end.
  if. -. found do.
    smoutput 'jlinter: could not find report.ijs among:'
    smoutput ; LF , each cands
  end.
)
