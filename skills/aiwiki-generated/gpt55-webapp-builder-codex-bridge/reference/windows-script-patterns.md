# Windows Script Patterns

## PowerShell defaults

Use PowerShell 7 first:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File "<DOWNLOADS_ROOT>\script.ps1" -DryRun
```

Fallback to `powershell.exe` only when needed.

## Safe apply script shape

A generated apply script should normally support:

```txt
-RepoPath
-ArchivePath
-DryRun
-Force
-CleanTemp
```

For broad changes, use `-DryRun` by default and require an explicit apply/force flag.

## Path preflight

Always validate important paths:

```powershell
if (-not (Test-Path -LiteralPath $RepoPath -PathType Container)) {
  throw "RepoPath not found: $RepoPath"
}
```

Use `-LiteralPath` for user paths.

## Clipboard

```powershell
Set-Clipboard -Value $Text
$Text = Get-Clipboard -Raw
```

Use explicit user-triggered clipboard operations. Avoid secrets.

## Hash verification

```powershell
Get-FileHash -Algorithm SHA256 -LiteralPath "<DOWNLOADS_ROOT>\package.tar.gz"
```

## TAR on Windows

Windows includes `tar.exe` on modern Windows builds.

Common commands:

```powershell
tar -tzf "package.tar.gz"
tar -xzf "package.tar.gz" -C "C:\Temp\review"
tar -czf "package.tar.gz" "package-folder"
```

Prefer extracting into a clean temp/review folder, then copying expected contents.

## Parent-driven cleanup

```powershell
$tempRoot = Join-Path $env:TEMP ("builder-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
try {
  # work
}
finally {
  Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
}
```

## Python subprocess runner shape

```python
subprocess.run(
    argv,
    cwd=cwd,
    shell=False,
    text=True,
    capture_output=True,
    timeout=120,
    check=False,
)
```

Prefer `argv` arrays over shell strings.
