NB. jlinter report — headless wrapper around addons/debug/lint
NB. Produces text / markdown / json for agent consumption.
NB.
NB. Load: load 'debug/jlinter'  or load this file
NB. Use:  report_jlinter_ 'markdown';'/path/to/script.ijs'
NB.       report_jlinter_ 'json';'source='; , code
NB.       exitcode_jlinter_ ''

cocurrent 'jlinter'

NB. ------------------------------------------------------------
NB. helpers
NB. ------------------------------------------------------------

isfile=: 1:@(1!:4) :: 0:

asbox=: 3 : 0
if. 0 = L. y do. , < y else. , y end.
)

ALNUM=: (a. {~ 65 + i. 26) , (a. {~ 97 + i. 26) , '0123456789'

alnumtag=: 3 : 0
s=. , ": 6!:0 ''
s #~ s e. ALNUM
)

msglines=: 3 : 0
l=. <;._2 LF ,~ y -. CR
l #~ 0 < #@> l
)

normalize=: 3 : 0
if. 0 = # y do. 0 2 $ a: return. end.
if. 2 = $$ y do. y return. end.
if. (1 = $$ y) *. (2 = # y) do. ,: y return. end.
0 2 $ a:
)

empty_locale=: 3 : 0
try. (18!:55) < y catch. end.
i. 0 0
)

NB. stock lint; y boxed path -> findings table
NB. Note: debug/lint may still smoutput "No errors found" / control errors.
runlint=: 3 : 0
require '~addons/debug/lint/lint.ijs'
IFGUI_lint_=: 0
normalize 1 lint y
)

load_probe=: 3 : 0
fn=. > y
loc=. 'jlinterload' , alnumtag ''
try.
  cocurrent loc
  0!:0 < fn
  cocurrent 'jlinter'
  empty_locale loc
  1 ; 'loaded ok'
catch.
  cocurrent 'jlinter'
  stg=. 13!:12 ''
  empty_locale loc
  0 ; stg
end.
)

NB. ------------------------------------------------------------
NB. analyze
NB. ------------------------------------------------------------

lint_file=: 3 : 0
fn=. > y
if. -. isfile < fn do.
  (,: _1 ; 'file not found: ' , fn) ; 0 ; 'file not found'
  return.
end.
ems=. runlint < fn
'lok lmsg'=. load_probe < fn
NB. control-error scripts often leave emsgs empty; promote load fail to a finding
if. (0 = # ems) *. -. lok do.
  ems=. ,: 0 ; ('load failed: ' , LF -.~ lmsg)
end.
ems ; lok ; lmsg
)

lint_source=: 3 : 0
src=. y
if. 0 = L. src do. src=. , src else. src=. > src end.
tmp=. jpath '~temp/jlinter_snippet_' , (alnumtag '') , '.ijs'
if. (0 = # src) +. LF ~: {: src do. src=. src , LF end.
src 1!:2 < tmp
r=. lint_file < tmp
1!:55 :: 0: < tmp
r
)

NB. ------------------------------------------------------------
NB. formatters
NB. ------------------------------------------------------------

fmt_text_row=: 3 : 0
'line msg'=. y
ln=. <. line
msgs=. msglines msg
if. 0 = # msgs do.
  (": ln) , ': ' , msg , LF
else.
  (": ln) , ': ' , (> {. msgs) , LF , ; (LF ,~ '  ' , ])&.> }. msgs
end.
)

fmt_text=: 3 : 0
'ems lok lmsg path'=. 4 {. y , a:
if. 0 = # ems do.
  t=. 'OK  no lint findings' , LF
else.
  t=. (": # ems) , ' finding(s)' , LF , ; <@ fmt_text_row"1 ems
end.
t=. t , 'load: ' , (lok {:: 'FAIL' ; 'ok')
if. -. lok do. t=. t , LF , lmsg end.
t=. t , LF , 'file: ' , path , LF
t
)

fmt_md_row=: 3 : 0
'line msg'=. y
ln=. <. line
one=. LF taketo msg , LF
one=. one rplc '|' ; '\|'
'| ' , (": ln) , ' | ' , one , ' |' , LF
)

fmt_md_detail=: 3 : 0
'line msg'=. y
ln=. <. line
msgs=. msglines msg
bul=. ; (LF ,~ '- ' , ])&.> msgs
('### Line ' , (": ln) , LF , LF) , bul , LF
)

fmt_markdown=: 3 : 0
'ems lok lmsg path'=. 4 {. y , a:
n=. # ems
status=. ((0 = n) *. lok) {:: 'FAIL' ; 'PASS'
out=. '# J lint report' , LF , LF
out=. out , '| Field | Value |' , LF
out=. out , '| --- | --- |' , LF
out=. out , '| File | `' , path , '` |' , LF
out=. out , '| Status | **' , status , '** |' , LF
out=. out , '| Findings | ' , (": n) , ' |' , LF
out=. out , '| Load | ' , (lok {:: 'FAIL' ; 'ok') , ' |' , LF
out=. out , '| Checker | `debug/lint` (headless) |' , LF , LF
if. n do.
  out=. out , '## Findings' , LF , LF
  out=. out , '| Line | Message |' , LF
  out=. out , '| ---: | --- |' , LF
  out=. out , ; <@ fmt_md_row"1 ems
  out=. out , LF , '### Detail' , LF , LF
  out=. out , ; <@ fmt_md_detail"1 ems
else.
  out=. out , 'No static issues found by `debug/lint`.' , LF , LF
end.
if. -. lok do.
  out=. out , '## Load failure' , LF , LF
  out=. out , '```' , LF , (LF -.~ lmsg) , LF , '```' , LF , LF
end.
out=. out , '## Notes for fixers' , LF , LF
out=. out , '- Prefer fixing undefined names, valence/shape errors, and no-effect sentences first.' , LF
out=. out , '- Use `NB.?lintonly` / `NB.?lintsaveglobals` only when the checker lacks init context.' , LF
out=. out , '- Re-run jlinter after each fix until Status is PASS and load is ok.' , LF
out
)

finding_obj_json=: 3 : 0
require 'convert/json'
'line msg'=. y
msgs=. msglines msg
one=. ' ' (I. msg = LF) } msg
one=. one -. CR
'{"line":' , (": <. line) , ',"message":' , (enc_json_json_ one) , ',"messages":' , (enc_json_json_ msgs) , '}'
)

join_comma=: 3 : 0
if. 0 = # y do. '' return. end.
if. 1 = # y do. > {. y return. end.
}. ; (','&,) each y
)

fmt_json=: 3 : 0
require 'convert/json'
'ems lok lmsg path'=. 4 {. y , a:
if. 0 = # ems do.
  farr=. '[]'
else.
  farr=. '[' , (join_comma finding_obj_json each <"1 ems) , ']'
end.
okflag=. ((0 = # ems) *. lok) {:: 'false' ; 'true'
lokflag=. lok {:: 'false' ; 'true'
'{"ok":' , okflag , ',"path":' , (enc_json_json_ path) , ',"count":' , (": # ems) , ',"load_ok":' , lokflag , ',"load_message":' , (enc_json_json_ LF -.~ , lmsg) , ',"findings":' , farr , '}'
)

NB. ------------------------------------------------------------
NB. driver
NB. ------------------------------------------------------------

report=: 3 : 0
args=. asbox y
if. 1 = # args do. args=. 'markdown' ; args end.
'fmt target'=. 2 {. args
fmt=. > fmt
target=. > target
if. 'source=' -: 7 {. target do.
  'ems lok lmsg'=. lint_source 7 }. target
  path=. '<source>'
else.
  'ems lok lmsg'=. lint_file < target
  path=. target
end.
packet=. ems ; lok ; lmsg ; path
EXITCODE=: 0 >. (0 < # ems) +. -. lok
select. fmt
case. 'json' do. fmt_json packet
case. 'text' do. fmt_text packet
case. do. fmt_markdown packet
end.
)

exitcode=: 3 : 0
if. 0 > 4!:0 < 'EXITCODE' do. 0 else. EXITCODE end.
)

cocurrent 'base'
