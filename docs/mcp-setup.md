# Exposing jlinter as an MCP tool

You already run **[j-mcp](https://github.com/tangentstorm/j-mcp)** in Claude Code (tools like `j_eval`, `j_session_create`). That server supports **user-defined tools** whose body is a J verb:

| Meta-tool | Role |
|-----------|------|
| `j_tool_register` | Define `mcp_<name>_z_` in a session and publish it as an MCP tool |
| `j_tool_list` / `j_tool_unregister` | Inspect / drop |
| Persistence | `$XDG_STATE_HOME/j-mcp/tools.json` (reloaded when the backing session is recreated) |

That is the preferred path for jlinter—no second MCP process.

## Architecture

```
Claude Code
   │  tools/call  j_lint { path | source, format? }
   ▼
j-mcp  (stdio)
   │  session_eval → mcp_j_lint_z_ <json_string>
   ▼
J session "jlinter" (or any name you choose)
   load 'debug/tmcguirefl/jlinter/mcp_j_lint'  NB. or path to checkout mcp_j_lint.ijs
   load report.ijs via mcp adapter / jlinter.ijs  →  debug/lint  →  JSON/markdown/text
```

Contract (from j-mcp):

1. Body source defines **`mcp_<toolname>_z_`** (verb in locale `z`).
2. Verb is **monadic**: JSON **string** in → JSON **string** out.
3. j-mcp invokes: `mcp_out_ =. (1!:2&2) (mcp_<name>_z_) '<json>'` and parses stdout as JSON.

## One-time setup (recommended)

### 1. Dedicated session

Create a durable, non-sandbox session (lint needs to `load`/`require` addons and read files):

```text
j_session_create
  name: jlinter
  sandbox: false
```

Optional: pin a profile that preloads the adapter (see “Profile” below).

### 2. Load the adapter body

```text
j_eval
  name: jlinter
  sentence: load '/Users/tomdevel/jdev/jlinter/mcp_j_lint.ijs'
```

This loads `report.ijs` and defines `mcp_j_lint_z_`.

Quick self-check:

```text
j_eval
  name: jlinter
  sentence: 4!:0 <'mcp_j_lint_z_'     NB. expect 3 (verb)
```

### 3. Register the tool

Call `j_tool_register` with:

- **name**: `j_lint`
- **session**: `jlinter`
- **description**: short text for the client’s tool list
- **inputSchema**: JSON Schema for arguments
- **body**: J source that defines `mcp_j_lint_z_`

Because the full body is long, the easiest durable body is “load the adapter file”:

```j
load '/Users/tomdevel/jdev/jlinter/mcp_j_lint.ijs'
```

That single line is a valid body **if** evaluating it leaves `mcp_j_lint_z_` defined as a verb (it does).

**inputSchema** (JSON object, not a stringified schema):

```json
{
  "type": "object",
  "properties": {
    "path": {
      "type": "string",
      "description": "Path to a .ijs file to lint"
    },
    "source": {
      "type": "string",
      "description": "Inline J script text (alternative to path)"
    },
    "format": {
      "type": "string",
      "enum": ["json", "markdown", "text"],
      "description": "Report format; default json",
      "default": "json"
    }
  },
  "additionalProperties": false
}
```

### 4. Verify

```text
j_tool_list
```

Then call the tool:

```text
j_lint
  path: /Users/tomdevel/jdev/jlinter/fixtures/bad_undefined.ijs
  format: json
```

or:

```text
j_lint
  source: |
    mean =: +/ % #
    bad =: 3 : 0
      undefined y
    )
  format: markdown
```

Expected success shape (wrapper always returns JSON):

```json
{
  "ok": false,
  "exit_code": 1,
  "format": "json",
  "path": "/…/bad_undefined.ijs",
  "report": { "ok": false, "findings": [ … ], … }
}
```

Agents should treat `exit_code != 0` or `ok: false` as “fix required”.

## Claude Code agent usage

Once registered, Claude discovers `j_lint` via `tools/list` (alongside `j_eval`, …). Preferred loop:

1. Write/edit `.ijs`
2. Call **`j_lint`** with the path
3. If `ok` is false → edit → re-call until `ok: true` / `exit_code: 0`

Keep using the **`j-lint` skill** (`./bin/jlinter`) when MCP is unavailable; use **`j_lint`** when in-session.

## Profile for auto-load (optional)

Create `~/.local/share/jlinter/profile.ijs` (or any path):

```j
load '/Users/tomdevel/jdev/jlinter/mcp_j_lint.ijs'
```

Then:

```text
j_session_create
  name: jlinter
  sandbox: false
  profile: /absolute/path/to/that/profile.ijs
```

After recreate, re-`j_tool_register` only if the tool entry was offline when the server started (registry persists tool *metadata*, and re-evals body into the session when it comes back—confirm with `j_tool_list` + a smoke call).

## Sandbox note

`sandbox: true` sets J security level and **restricts loads**. Lint’s `require '~addons/debug/lint/lint.ijs'` must succeed. Prefer **`sandbox: false`** for the `jlinter` session. Do not run untrusted user scripts in that session without isolation boundaries of your own.

## Alternative: shell MCP / stdio CLI

If you ever leave j-mcp:

```json
{
  "mcpServers": {
    "jlinter": {
      "command": "node",
      "args": ["/path/to/tiny-stdio-mcp-wrapper.js"],
      "env": {
        "JLINTER_BIN": "/Users/tomdevel/jdev/jlinter/bin/jlinter"
      }
    }
  }
}
```

A tiny wrapper would map `tools/call` → `jlinter -f json <path>`. That duplicates session management you already get for free in j-mcp—use only if you want isolation from the shared J ecosystem.

## Restart checklist

After reboot / new Claude session:

1. Confirm j-mcp server is up (your Claude MCP config).
2. `j_session_list` — is `jlinter` live? If not, create it (and profile if used).
3. `j_tool_list` — is `j_lint` registered? If empty, re-run `j_tool_register` with the load-body.
4. Smoke: `j_lint` on `fixtures/good_mean.ijs` → `ok: true`.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `body did not define mcp_j_lint_z_ as a verb` | body must end up defining that exact name; use `load '…/mcp_j_lint.ijs'` |
| `backing session jlinter is not live` | `j_session_create` again, same name |
| `file not found` | pass absolute paths; relative is training-session cwd dependent |
| empty findings but bad control | check `exit_code` / load message—load probe surfaces control errors |
| sandbox / require failure | recreate session with `sandbox: false` |

## Manual registration payload (for agents)

When calling `j_tool_register`, arguments look like:

```json
{
  "name": "j_lint",
  "session": "jlinter",
  "description": "Static-check a J script or snippet via debug/lint. Returns {ok,exit_code,format,path,report}. Use after editing .ijs to drive a fix loop.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "path": { "type": "string", "description": "Path to .ijs file" },
      "source": { "type": "string", "description": "Inline J source instead of path" },
      "format": {
        "type": "string",
        "enum": ["json", "markdown", "text"],
        "default": "json"
      }
    },
    "additionalProperties": false
  },
  "body": "load '/Users/tomdevel/jdev/jlinter/mcp_j_lint.ijs'"
}
```
