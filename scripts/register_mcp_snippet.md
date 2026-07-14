# Snippet: register j_lint via j-mcp tools  (paste / agent steps)

1. `j_session_create` → `name=jlinter`, `sandbox=false`
2. `j_eval` → session `jlinter`, sentence:

```j
load '/Users/tomdevel/jdev/jlinter/mcp_j_lint.ijs'
```

3. `j_tool_register` with body equal to the same load line (so restarts replay definition), schema as in docs/mcp-setup.md, name `j_lint`.
4. `j_lint` → `path=/Users/tomdevel/jdev/jlinter/fixtures/good_mean.ijs`
5. Expect `"ok": true` / `"exit_code": 0`
