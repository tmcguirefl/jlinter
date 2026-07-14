# jlinter (`tmcguire/jlinter`)

Headless static checker for [J](https://www.jsoftware.com/) scripts, meant for **Claude Code** and other agent workflows.

It wraps the stock J addon [`debug/lint`](https://code.jsoftware.com/wiki/Addons/debug/lint) ([GitHub](https://github.com/jsoftware/debug_lint)), which already returns an `(line; message)` table in `jconsole` (no Qt required). jlinter formats that table as **markdown**, **JSON**, or plain **text**, and exits non-zero when findings or load failures remain.

## Requirements

- J 9.x with `jconsole`
- addon `debug/lint` (`~addons/debug/lint`)
- addon `convert/json` for JSON formatting

### This development account (private J under home)

On the machine where this repo was developed, the **private** install is preferred so work never mutates `/Applications/j9.8` (used by other accounts):

| | Path |
|--|------|
| Engine | `$HOME/j9.8/bin/jconsole` |
| Addons | `$HOME/j9.8/addons` |
| User data | `$HOME/j9.8-user` |

```bash
source ./scripts/jenv.sh          # sets JLINTER_JCONSOLE, JHOME, PATH
./scripts/install_local.sh --force  # copy runtime FILES → ~/j9.8/addons/tmcguire/jlinter
./bin/jlinter fixtures/good_mean.ijs
```

Override when needed: `export JLINTER_JCONSOLE=/path/to/jconsole`.  
Resolution order: `JLINTER_JCONSOLE` → `JCONSOLE` → `$HOME/j9.8/bin/jconsole` → `/Applications/j9.8/bin/jconsole` → PATH.

## Install (J Package Manager / GitHub)

This repo is laid out as a [J addon](https://code.jsoftware.com/wiki/Addons/Developers_Guide) with a valid `manifest.ijs` and `FOLDER=: 'tmcguire/jlinter'`. Pacman can install directly from GitHub without listing on the official JAL menu. See also [Pacman § Github](https://code.jsoftware.com/wiki/Pacman#Github).

```j
load 'pacman'
install 'github:tmcguirefl/jlinter'          NB. or tmcguirefl/debug_jlinter / @commit
load 'tmcguire/jlinter'
echo report_jlinter_ 'markdown';'path/to/script.ijs'
```

`tmcguirefl` is the GitHub owner for this addon once published. Repo names often follow the addon convention `debug_jlinter` when hosted under jsoftware or personal mirrors; the **installed path is always the `FOLDER` from the manifest** (`~addons/tmcguire/jlinter`), not the GitHub name.

After install:

```j
load 'tmcguire/jlinter'
load 'tmcguire/jlinter/mcp_j_lint'   NB. optional MCP adapter
```

### Local install from a checkout (runtime files only)

```bash
source ./scripts/jenv.sh
./scripts/install_local.sh --force
# → copies only FILES from manifest.ijs into
#   $HOME/j9.8/addons/tmcguire/jlinter/
#   (manifest + jlinter.ijs + report.ijs + mcp_j_lint.ijs + history.txt)
```

The full git tree (bin/, docs/, fixtures/, scripts/, …) stays in the development checkout and is **not** symlinked into `~addons`. After editing core `.ijs` sources, re-run `install_local.sh --force` (or GitHub `install`) so `~addons` picks up changes.

Then (using the private engine):

```j
load 'tmcguire/jlinter'
```

## CLI (checkout)

```bash
./bin/jlinter fixtures/good_mean.ijs
./bin/jlinter -f json fixtures/bad_undefined.ijs
./bin/jlinter -f text path/to/script.ijs
cat snippet.ijs | ./bin/jlinter --stdin -f markdown
```

### Exit codes

| Code | Meaning |
|------|---------|
| 0 | no lint findings **and** top-level load ok |
| 1 | findings and/or load failure |
| 2 | usage / missing engine / tool error |

### Formats

**markdown** (default) — human + agent friendly table + detail sections  
**json** — `{ ok, path, count, load_ok, load_message, findings[] }`  
**text** — compact line-oriented report  

## What is checked

From Henry Rich’s `debug/lint`:

- explicit definitions missing trailing `)`
- undefined names / path-dependent defs
- invalid verb valences
- non-noun results at ends of condition blocks / verbs
- syntax errors
- no-effect sentences (`verb verb`, …)

Plus jlinter’s lightweight **load probe**: run the script in an isolated locale and report if top-level load fails (control errors often show up here).

Lint directives (`NB.?lintonly`, `NB.?lintsaveglobals`, …) work as documented on the [wiki](https://code.jsoftware.com/wiki/Addons/debug/lint).

## Claude Code workflow

```bash
./bin/jlinter -f markdown path/to/file.ijs
```

If exit status is 1, fix reported lines and re-run until PASS. Skill: [`.claude/skills/j-lint/SKILL.md`](.claude/skills/j-lint/SKILL.md).

### MCP tool (j-mcp)

Register `j_lint` on **j-mcp** via `j_tool_register`. Adapter: [`mcp_j_lint.ijs`](mcp_j_lint.ijs). Full steps: [`docs/mcp-setup.md`](docs/mcp-setup.md).

### From J

```j
load 'tmcguire/jlinter'   NB. when installed
NB. or: load '/path/to/checkout/jlinter.ijs'
echo report_jlinter_ 'markdown';'/path/to/script.ijs'
echo exitcode_jlinter_ ''
echo report_jlinter_ 'json';'source=',code
```

## Addon layout (JAL)

Required by [Addons Developers Guide](https://code.jsoftware.com/wiki/Addons/Developers_Guide):

| File | Role |
|------|------|
| `manifest.ijs` | `CAPTION`, `VERSION`, `FOLDER`, `FILES`, … |
| `jlinter.ijs` | shortname entry for `load 'tmcguire/jlinter'` |
| `report.ijs` | analysis + formatters (locale `jlinter`) |
| `history.txt` | changelog (version bumps go here + `VERSION=`) |
| `FOLDER` | `tmcguire/jlinter` |

Repo convention for jsoftware hosting: name `debug_jlinter` (category_folder). Personal repos can use any name; **FOLDER in the manifest is what matter for install**.

To publish into the official list later: validate with `install 'github:…'`, then email `jal@jsoftware.com`. Increment **VERSION** whenever you want a rebuild.

## Smoke / install verification

```bash
source ./scripts/jenv.sh
./scripts/smoke.sh                 # CLI fixtures on private engine
./scripts/verify_jal_install.sh    # stage FILES → ~/j9.8/addons/tmcguire/jlinter + shortname load
```

`verify_jal_install.sh` proves the package layout works **without** GitHub by doing a real (non-symlink) install under the private `~addons`. After you push to GitHub:

```j
install 'github:tmcguirefl/jlinter'
```
## Limits

- `debug/lint` focuses on **explicit** definitions; tacit-only scripts with no explicit defs may report little.
- Not a type checker or full side-effect interpreter.
- The CLI isolates the formatted report via temp files so exit codes stay reliable.

## License

MIT (see `LICENSE`). Stock `debug/lint` remains under its upstream license.
