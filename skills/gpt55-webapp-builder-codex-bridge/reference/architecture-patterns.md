# Architecture Patterns

## Pattern A - Human-run script bridge

Use when you want maximum clarity and minimum infrastructure.

```txt
ChatGPT creates script/package -> user downloads -> user reviews -> user runs -> user pastes output back
```

Best for:

- repo-local fixes,
- AI Wiki skill installs,
- prompt packs,
- one-off automation,
- high-risk operations that should not be hidden.

Weakness:

- manual loop,
- no live filesystem access,
- user must paste logs back.

## Pattern B - Browser-only helper

Use browser APIs for low-risk tasks:

- copy-to-clipboard buttons,
- file picker/import/export,
- local preview of generated text/files,
- worker/WASM processing.

Do not expect a plain web page to execute native commands.

## Pattern C - Server executor

Use a backend job queue or container/VM executor.

Best for:

- SaaS builder products,
- remote repo operations,
- API orchestration,
- repeatable background jobs,
- audit logs.

Keep provider API keys on the server. Never expose upstream model/API secrets to browser code.

## Pattern D - MCP tool host

Use MCP when you want a provider-neutral tool boundary.

Best for:

- vault search/read,
- repo context tools,
- narrow local utilities,
- interoperable agent tools.

Default MCP tools should be read-oriented. Write tools need explicit policy and user intent.

## Pattern E - Browser extension + native messaging

Use only after simpler bridges are proven.

Best for:

- local shell bridge from a browser UI,
- installed power-user workflow,
- tighter clipboard/filesystem integration.

Risks:

- extension permissions,
- native host registration,
- installer/update security,
- allowed-origin mistakes,
- model-to-OS attack surface.

## Pattern F - Desktop companion / local daemon

Use if the product truly needs local-agent ergonomics.

Best for:

- Cursor-like local repo access,
- persistent local jobs,
- file watchers,
- native shell execution,
- signed update channel.

Do not start here unless the manual script bridge is clearly too slow.
