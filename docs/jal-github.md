# JAL / GitHub packaging for jlinter

## Spec sources

- [Addons Developers Guide](https://code.jsoftware.com/wiki/Addons/Developers_Guide) — repo layout, **manifest** nouns, versioning, platforms
- [Pacman](https://code.jsoftware.com/wiki/Pacman) — package manager; **Github** installs

## What Pacman requires

From Pacman:

> Code from github can be installed as an addon if it has the same layout as a pacman addon. In particular it needs a **manifest.ijs** that contains a **FOLDER** definition.
>
> ```j
> install 'github:owner/repo[@commit]'   NB. commit defaults to master
> ```

From the Developers Guide, **required** manifest nouns:

| Noun | Meaning |
|------|---------|
| `CAPTION` | one-line description |
| `VERSION` | `major.minor.build` e.g. `0.1.0` |
| `FOLDER` | install path under `~addons`, e.g. `tmcguire/jlinter` |
| `FILES` | newline list of files and dirs (`dir/` ends with `/`) |

Optional: `DESCRIPTION`, `DEPENDS`, `PLATFORMS`, `RELEASE`, `FILESxxx`.

Only **global noun** definitions are allowed in `manifest.ijs` (character strings or `0 : 0` blocks).

## This repository

| Item | Value |
|------|--------|
| FOLDER | `tmcguire/jlinter` |
| VERSION | see `manifest.ijs` |
| Entry script | `jlinter.ijs` → `load 'tmcguire/jlinter'` |
| GitHub owner | `tmcguirefl` |
| Suggested GitHub repos | `tmcguirefl/jlinter` or `tmcguirefl/debug_jlinter` |

After push:

```j
load 'pacman'
install 'github:tmcguirefl/jlinter'     NB. or @main @v0.1.0 etc.
load 'tmcguire/jlinter'
```

`FOLDER` is **`tmcguire/jlinter`** — a two-level path (category `tmcguire`, package `jlinter`), separate from stock jsoftware categories like `debug/*`. Pacman installs to `~addons/tmcguire/jlinter/`, and the normal shortname load works:

```j
load 'tmcguire/jlinter'
```
## Official catalog (optional)

1. Prove install works: `install 'github:…'`
2. Email **jal@jsoftware.com** to request listing
3. Future updates: **increment VERSION** in `manifest.ijs` (and log in `history.txt`); the JAL build server rebuilds when VERSION changes

## Local dry-run without GitHub

```bash
source ./scripts/jenv.sh          # prefer $HOME/j9.8 engine
./scripts/install_local.sh --force   # copy runtime FILES only into ~addons/tmcguire/jlinter
```

Uses this account’s private install (`~/j9.8`); refuses to write under `/Applications/j9.8`.
**`FILES` in the manifest must stay minimal** (J scripts needed at runtime)—not `bin/`, `docs/`, `fixtures/`, or the rest of the development tree.
## Checklist before `git push`

- [ ] `manifest.ijs` loads as nouns only (`0!:0 <'manifest.ijs'` shows no verbs)
- [ ] `FOLDER` is lowercase path under category (here `tmcguire/jlinter`)
- [ ] `FILES` lists every distributed path (trailing `/` on directories)
- [ ] `VERSION` / `history.txt` present
- [ ] `./scripts/smoke.sh` passes
- [ ] `load` of `jlinter.ijs` defines `report_jlinter_`
