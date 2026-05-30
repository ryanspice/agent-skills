# Human-Run Script Request

## Task

Create a reviewable script/package for:

```txt
[task]
```

## Required script behavior

- PowerShell 7 first.
- Parameters for all paths.
- `-DryRun` mode.
- `-Force` only for overwrite/delete.
- Clear path preflight.
- Backup before destructive changes.
- Temp files cleaned in `finally`.
- No secrets written to logs.
- Final verification output.

## Response format

```txt
What it will do
What it will not do
Dry-run command
Apply command
Verify command
Expected output to paste back
```
