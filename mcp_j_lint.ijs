NB. MCP adapter for jlinter (j-mcp j_tool_register binding)
NB. Defines monadic verb mcp_j_lint_z_  (JSON string → JSON string).
NB.
NB. Args JSON:
NB.   {"path":"/file.ijs"}
NB.   {"source":"…j code…"}
NB.   optional "format": "json" (default) | "markdown" | "text"
NB.
NB. Result:
NB.   {"ok":bool,"exit_code":0|1,"format":"…","path":"…","report":…}
NB.
NB. Prefer after install:
NB.   load '~addons/debug/tmcguirefl/jlinter/mcp_j_lint.ijs'
NB. or checkout path.

NB. Capture this file's directory before other loads change 4!:3.
JLINTER_MCP_DIR_z_=: 3 : 0 ''
  me=. > {: 4!:3 ''
  slash=. me i: '/'
  (slash + 1) {. me
)

load JLINTER_MCP_DIR_z_ , 'report.ijs'
require 'convert/json'

NB. x=field name, y=2-row object from convert/json
jlint_get_z_=: 4 : 0
if. 0 = # y do. '' return. end.
i=. (0 { y) i. < x
if. i >: {: $ y do. '' return. end.
> (< 1 , i) { y
)

NB. j-mcp requires mcp_<toolname>_z_ as a monadic verb
mcp_j_lint_z_=: 3 : 0
raw=. y
if. 0 = L. raw do. raw=. , raw else. raw=. > raw end.
if. 0 = # raw do. raw=. '{}' end.

obj=. dec_json_json_ :: ((0 0 $ a:)"_) raw
if. 0 = # obj do.
  '{"ok":false,"exit_code":1,"format":"json","path":"","report":"invalid JSON args"}' return.
end.

path=. 'path' jlint_get_z_ obj
src=. 'source' jlint_get_z_ obj
fmt=. 'format' jlint_get_z_ obj
if. 0 = # fmt do. fmt=. 'json' end.
if. -. (< fmt) e. 'json';'markdown';'text' do. fmt=. 'json' end.

if. 0 < # src do.
  target=. 'source=' , src
elseif. 0 < # path do.
  target=. path
elseif. do.
  ('{"ok":false,"exit_code":1,"format":' , (enc_json_json_ fmt) , ',"path":"","report":"missing path or source"}') return.
end.

rep=. report_jlinter_ fmt ; target
ec=. 0 >. exitcode_jlinter_ ''
okflag=. (0 = ec) {:: 'false' ; 'true'
pathout=. path
if. 0 = # pathout do. pathout=. '<source>' end.

if. fmt -: 'json' do.
  '{"ok":' , okflag , ',"exit_code":' , (": ec) , ',"format":"json","path":' , (enc_json_json_ pathout) , ',"report":' , rep , '}'
else.
  '{"ok":' , okflag , ',"exit_code":' , (": ec) , ',"format":' , (enc_json_json_ fmt) , ',"path":' , (enc_json_json_ pathout) , ',"report":' , (enc_json_json_ rep) , '}'
end.
)
