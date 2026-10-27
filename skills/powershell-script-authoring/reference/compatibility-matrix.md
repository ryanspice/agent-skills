# Compatibility Matrix

## Ryan-local / AI Wiki / modern dev

Use `pwsh` and PS7-compatible code.

Good:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File "script.ps1"
Set-Content -LiteralPath $Path -Encoding utf8NoBOM
```

## Client / production / unknown environment

Detect first or write conservative code.

Check:

```powershell
$PSVersionTable
Get-Command pwsh, powershell -ErrorAction SilentlyContinue | Select-Object Name, Source, Version
```

Use fallback helpers for UTF-8 no-BOM and relative paths if Windows PowerShell 5.1 is possible.

## When to avoid PS7-only features

- client machines with unknown shell state
- production recovery scripts
- scripts intended for older Windows Server
- deployment documentation sent to non-technical users
- vendor environments where only Windows PowerShell is guaranteed

## Runtime wording

Say "pwsh-first" for modern/local work. Say "Windows PowerShell-compatible" only when intentionally targeting 5.1.
