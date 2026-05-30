# Obsidian Vault — `.gitignore` Reference

## Purpose

A reference sheet for hand-crafting or auditing `.gitignore` files inside Obsidian
vaults, especially vaults that are also code-repo roots or OneDrive-synced folders.

## Source

Guidance from session 2026-05-18: user wanted `node_modules` and standard dev
artifacts excluded from Obsidian's file explorer and graph without initializing
Git. The Two independent ignore layers — Obsidian (via `.gitignore`) and OneDrive
(via folder selection) — proved to be the important distinction.

---

## Coverage map

| Category | Pattern | Why it's needed |
|---|---|---|
| Obsidian internals | `.obsidian/`, `.obsidian/workspace*.json` | App cache, plugin data, UI state |
| Obsidian/Git plugin | `obsidian-git/` | Plugin commit metadata |
| Obsidian trash | `Trash/` or `.trash/` | Deleted files stored locally |
| Node / JS | `node_modules/`, `dist/`, `build/`, `.next/`, `coverage/` | Standard JS/TS dev deps |
| Python | `__pycache__/`, `.venv/`, `venv/` | Python runtime artifacts |
| IDEs | `.idea/`, `.vscode/`, `*.swp` | Editor config/cache |
| OS | `.DS_Store`, `Thumbs.db` | Metadata files macOS/Windows write |
| Secrets | `.env`, `.env.*` | Never commit credentials |
| Archives | `*.zip`, `*.tar.gz` | Backup bundles |

## Two independent ignore layers

### Layer 1 — `.gitignore` (Obsidian native read)

Controls:
- Obsidian file explorer visibility
- Obsidian graph view
- `git` version tracking (if `git init` is done later)

Does NOT control:
- OneDrive cloud sync
- Any other sync mechanism

### Layer 2 — OneDrive folder selection

Controls: What OneDrive uploads to the cloud

To stop syncing a subfolder:
Right-click vault folder → OneDrive → Choose folders → uncheck `node_modules`
(or any other folder in the sync tree).

Already-synced folders are **not** removed from the cloud retroactively by
adding `.gitignore`. They must be excluded explicitly in OneDrive settings.

## `.obsidian/app.json` (local-only fallback)

When `.gitignore` is not available (e.g., Git initialization delayed), use
`.obsidian/app.json` inside the vault:

```json
{
  "userIgnoreFilters": ["node_modules/", ".obsidian/", "dist/", "build/"]
}
```

Restart Obsidian after editing. Not synced by OneDrive or Git.

## OneDrive edge case

If `node_modules` lives *outside* the vault (e.g., `<DEV_ROOT>/node_modules`),
`.gitignore` inside the vault has no effect. OneDrive must be configured at the
folder level, or `node_modules` must be moved outside the OneDrive tree and
symlinked back if sync avoidance is the goal.

## MCP / Hermes interaction

`.gitignore` also affects what Hermes-side MCP tools like `vault_search` /
`vault_read` surface. Ignored paths are not scanned, not listed, not returned
in metadata. This is desirable — it keeps skill/library noise out of agent tool
responses.

But `.gitignore` does NOT block `terminal(ls)` or `read_file` with absolute
paths. An agent can still manually target an ignored path if it knows the path
explicitly. This is the correct behavior.
