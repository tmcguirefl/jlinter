# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Goal

Provide a **headless** J lint tool so agents can check and correct generated J without Qt. Core analysis is the stock addon `debug/lint`; this project is a report/CLI wrapper packaged as JAL addon **`debug/tmcguirefl/jlinter`**.

## Commands

```bash
./bin/jlinter path/to/file.ijs
./bin/jlinter -f json path/to/file.ijs
./bin/jlinter -f text path/to/file.ijs
cat src.ijs | ./bin/jlinter --stdin
./scripts/smoke.sh
./scripts/install_local.sh       # symlink checkout into ~/j9.8/addons/debug/tmcguirefl/jlinter
./scripts/verify_jal_install.sh  # real copy install + shortname load prove JAL layout
source ./scripts/jenv.sh         # PATH + JLINTER_JCONSOLE + JHOME for this shell
```

**This account uses a private J install** so development never touches `/Applications/j9.8` (other accounts use the system install):

| Item | Path |
|------|------|
| Engine | `$HOME/j9.8/bin/jconsole` |
| Addons | `$HOME/j9.8/addons` (`~addons`) |
| User/config | `$HOME/j9.8-user` (`~user`) |

Override when needed: `JLINTER_JCONSOLE`, `JHOME`. Resolution order is in `scripts/resolve_jconsole.sh`.

## GitHub / JAL packaging

This tree is a valid addon for:

```j
install 'github:tmcguirefl/jlinter'
load 'debug/tmcguirefl/jlinter/jlinter'
```

Key rules ([Developers Guide](https://code.jsoftware.com/wiki/Addons/Developers_Guide), [Pacman Github](https://code.jsoftware.com/wiki/Pacman#Github)):

- Root `manifest.ijs` must define **CAPTION**, **VERSION**, **FOLDER**, **FILES**
- `FOLDER=: 'debug/tmcguirefl/jlinter'` (lowercase, no spaces)
- Prefer lower-case paths; GitHub repo often named `debug_jlinter` (category_folder)
- Bump **VERSION** when you want published rebuilds
- Do not put non-noun definitions in `manifest.ijs`

## After changing J code

1. Run `./scripts/smoke.sh` (or at least `./bin/jlinter` on `fixtures/*`).
2. Expect:
   - `fixtures/good_mean.ijs` → exit 0
   - `fixtures/bad_undefined.ijs` → exit 1 with undefined name / length findings
   - `fixtures/bad_control.ijs` → exit 1 (control / load failure)
3. If public API / packaging changes, update `VERSION` and `history.txt`.

## Key files

| Path | Role |
|------|------|
| `manifest.ijs` | JAL/Pacman manifest (`FOLDER` debug/tmcguirefl/jlinter) |
| `jlinter.ijs` | entry for `load 'debug/tmcguirefl/jlinter/jlinter'` |
| `report.ijs` | locale `jlinter`: `report`, `exitcode`, formatters |
| `mcp_j_lint.ijs` | `mcp_j_lint_z_` for j-mcp |
| `bin/jlinter` | bash CLI |
| `fixtures/` | regression samples |
| `history.txt` | version changelog |

## Implementation notes

- Call stock lint as `1 lint <file>` with `IFGUI_lint_ =: 0` so results always return as a table (msglevel 1).
- Prefer file I/O for CLI report isolation.
- Control errors may not populate `emsgs`; the load probe surfaces them.
- Exit code is `1` if findings **or** load fail.
- JSON uses `convert/json` `enc_json` for strings; findings array is hand-joined for reliable list-of-objects shape.

## Working with J

- Prefer `$HOME/j9.8/bin/jconsole` on this account (never `/Applications/j9.8` for jlinter work).
- Avoid `/usr/bin/jconsole` (macOS Java stub).
- Explicit defs use `verb =: 3 : 0` … `)`.
- Control words only inside explicit definitions.
