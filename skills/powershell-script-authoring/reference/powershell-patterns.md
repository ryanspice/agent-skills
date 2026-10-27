# PowerShell Patterns

## Ryan-local defaults

- Prefer `pwsh -NoProfile -ExecutionPolicy Bypass -File ...`.
- Browser/download source is usually `<DOWNLOADS_ROOT>`.
- Development destination root is usually `<DEV_ROOT>`.
- Canonical AI Wiki root is `<AI_WIKI_ROOT>`.
- Use TAR.GZ for multi-file packages.
- Use build-the-file scripts for medium sized `.ps1` deliverables.

## Build-the-file response pattern

Use a small pasteable block that writes the real script to disk, then runs it. This avoids mangled copy/paste and keeps the command history useful.

## Safe script defaults

- `$ErrorActionPreference = "Stop"`
- `param(...)`
- `-LiteralPath`
- backups before overwrite
- dry-run first when touching durable files
- `-Apply` to mutate
- `-NoSelfDelete` for debugging installers
- `curl.exe` when real curl is needed

## Avoid

- `powershell` by default for Ryan-local work
- Bash-style escaping
- brittle backtick continuations
- hidden destructive actions
- global installs unless requested
- broad `robocopy /MIR` without preservation rules
- printing secrets or `.env` contents
