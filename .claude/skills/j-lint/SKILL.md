---
name: j-lint
description: Lint J (.ijs) scripts with the project's headless jlinter (wraps debug/lint) and fix until clean. Use after writing or editing J code, or when the user asks to check J syntax/static errors.
---

# J lint skill

## When to use

- You created or modified any `.ijs` file.
- The user asks to lint, check, or validate J code.
- Before claiming a J script is correct.

## How to run

From the jlinter repo (or with `bin/jlinter` on PATH):

```bash
./bin/jlinter -f markdown path/to/file.ijs
```

For machine-readable output:

```bash
./bin/jlinter -f json path/to/file.ijs
```

Stdin snippet:

```bash
./bin/jlinter --stdin -f text <<'EOF'
mean =: +/ % #
demo =: 3 : 0
  mean y
)
EOF
```

Exit codes: **0** clean, **1** findings or load fail, **2** tool usage error.

If `jconsole` is not found, use this account’s private install:

```bash
source ./scripts/jenv.sh
# or: export JLINTER_JCONSOLE=$HOME/j9.8/bin/jconsole
```

Do not point development at `/Applications/j9.8` on multi-account machines that share that system tree.
## Fix loop

1. Run jlinter on the target script.
2. Read findings (line + message). Prefer markdown format in the agent transcript.
3. Edit the script to fix **one cluster** of related issues (undefined name, valence/shape, control structure, missing `)`).
4. Re-run jlinter.
5. Stop only when Status is **PASS**, load is **ok**, and exit code is **0**.

## Interpreting results

Stock `debug/lint` flags:

- Undefined names
- Invalid verb valences
- Non-noun results at ends of blocks
- Syntax / spelling errors
- No-effect sentences
- Missing trailing `)` on explicit defs

Load failures (control errors, ill-formed scripts) appear under load / as a synthetic finding when the static table is empty.

## Directives (only when needed)

- `NB.?lintonly …` — set up values for the checker without affecting real load semantics.
- `NB.?lintsaveglobals` — carry globals from an early verb into later ones for path analysis.

Prefer real fixes over silencing the checker.

## Do not

- Open Qt/`jqt` for linting.
- Declare success while exit code is 1.
- Ignore load failures even when the findings table is empty.
