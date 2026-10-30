[CmdletBinding()]
param(
    [string]$OutputPath = '',
    [switch]$Force,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$skillRoot = Split-Path -Parent $PSScriptRoot
$validator = Join-Path $PSScriptRoot 'Test-BmoBenchmarkPacket.ps1'
$localDriveRoot = 'B:' + [System.IO.Path]::DirectorySeparatorChar
$downloadsRoot = Join-Path (Join-Path $localDriveRoot 'Temp') '@Browser'
$runtimeRoot = Join-Path $localDriveRoot 'AI-Wiki.runtime'
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $downloadsRoot 'bmo-agent-benchmark-v0.2.4.tar.gz'
}

function Get-Sha256File {
    param([Parameter(Mandatory)][string]$Path)
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToUpperInvariant()
}

function Write-Utf8TextAtomic {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][AllowEmptyString()][string]$Text
    )
    $full = [System.IO.Path]::GetFullPath($Path)
    [System.IO.Directory]::CreateDirectory((Split-Path -Parent $full)) | Out-Null
    $temporary = "$full.$PID.$([Guid]::NewGuid().ToString('N')).tmp"
    try {
        [System.IO.File]::WriteAllText($temporary, $Text, [System.Text.UTF8Encoding]::new($false))
        [System.IO.File]::Move($temporary, $full, $true)
    }
    finally {
        if (Test-Path -LiteralPath $temporary -PathType Leaf) {
            Remove-Item -LiteralPath $temporary -Force
        }
    }
}

function Copy-PackageTree {
    param(
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string]$Destination
    )
    [System.IO.Directory]::CreateDirectory($Destination) | Out-Null
    $sourceFull = [System.IO.Path]::GetFullPath($Source).TrimEnd('\')
    foreach ($directory in Get-ChildItem -LiteralPath $sourceFull -Directory -Recurse) {
        if ($directory.FullName -match '\\(?:node_modules|\.git|\.svelte-kit|build|__pycache__)(?:\\|$)') { continue }
        $relative = $directory.FullName.Substring($sourceFull.Length).TrimStart('\')
        [System.IO.Directory]::CreateDirectory((Join-Path $Destination $relative)) | Out-Null
    }
    foreach ($file in Get-ChildItem -LiteralPath $sourceFull -File -Recurse) {
        if ($file.FullName -match '\\(?:node_modules|\.git|\.svelte-kit|build|__pycache__)(?:\\|$)') { continue }
        if ($file.Name -match '\.(?:pyc|tmp)$') { continue }
        $relative = $file.FullName.Substring($sourceFull.Length).TrimStart('\')
        $destinationFile = Join-Path $Destination $relative
        [System.IO.Directory]::CreateDirectory((Split-Path -Parent $destinationFile)) | Out-Null
        [System.IO.File]::Copy($file.FullName, $destinationFile, $false)
    }
}

function Invoke-HiddenTar {
    param(
        [Parameter(Mandatory)][string[]]$Arguments,
        [Parameter(Mandatory)][string]$WorkingDirectory
    )
    $tar = (Get-Command tar.exe -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
    $psi = [System.Diagnostics.ProcessStartInfo]::new()
    $psi.FileName = $tar
    $psi.WorkingDirectory = $WorkingDirectory
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    foreach ($argument in $Arguments) { $psi.ArgumentList.Add($argument) }
    $process = [System.Diagnostics.Process]::new()
    $process.StartInfo = $psi
    if (-not $process.Start()) { throw 'Failed to start tar.exe.' }
    $stdoutTask = $process.StandardOutput.ReadToEndAsync()
    $stderrTask = $process.StandardError.ReadToEndAsync()
    if (-not $process.WaitForExit(120000)) {
        try { $process.Kill($true) } catch { }
        throw 'tar.exe timed out.'
    }
    $stdout = $stdoutTask.GetAwaiter().GetResult()
    $stderr = $stderrTask.GetAwaiter().GetResult()
    $exitCode = $process.ExitCode
    $process.Dispose()
    if ($exitCode -ne 0) {
        throw "tar.exe failed with exit code ${exitCode}: $stderr"
    }
    [pscustomobject]@{ stdout = $stdout; stderr = $stderr }
}

$validation = & $validator -SkillRoot $skillRoot -NoExit -PassThru
if (-not $validation.ok) {
    throw 'The benchmark packet failed validation; package creation stopped.'
}

$resolvedOutput = [System.IO.Path]::GetFullPath($OutputPath)
$allowedOutputRoots = @($downloadsRoot, $runtimeRoot)
$allowed = $false
foreach ($root in $allowedOutputRoots) {
    $rootFull = [System.IO.Path]::GetFullPath($root).TrimEnd('\')
    if ($resolvedOutput.StartsWith("$rootFull\", [System.StringComparison]::OrdinalIgnoreCase)) {
        $allowed = $true
        break
    }
}
if (-not $allowed) {
    throw "OutputPath must be below: $($allowedOutputRoots -join ', ')"
}
if (-not $resolvedOutput.EndsWith('.tar.gz', [System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'OutputPath must end with .tar.gz.'
}
if ((Test-Path -LiteralPath $resolvedOutput) -and -not $Force) {
    throw "Package already exists. Pass -Force only when replacement is intentional: $resolvedOutput"
}

$stagingBase = Join-Path $runtimeRoot 'package-staging'
[System.IO.Directory]::CreateDirectory($stagingBase) | Out-Null
$stagingRoot = Join-Path $stagingBase ("bmo-agent-benchmark-" + [Guid]::NewGuid().ToString('N'))
$packageRoot = Join-Path $stagingRoot 'bmo-agent-benchmark'

try {
    Copy-PackageTree -Source $skillRoot -Destination $packageRoot
    $manifestFiles = Get-ChildItem -LiteralPath $packageRoot -File -Recurse |
        Sort-Object FullName |
        ForEach-Object {
            [ordered]@{
                path = $_.FullName.Substring($packageRoot.Length).TrimStart('\').Replace('\', '/')
                bytes = $_.Length
                sha256 = Get-Sha256File -Path $_.FullName
            }
        }
    $manifest = [ordered]@{
        schemaVersion = '1.0.0'
        package = 'bmo-agent-benchmark'
        version = '0.2.4'
        createdAt = (Get-Date).ToString('o')
        format = 'tar.gz'
        fixtureValidation = [ordered]@{
            ok = $validation.ok
            counts = $validation.counts
            assetHashes = $validation.assetHashes
        }
        files = @($manifestFiles)
    }
    Write-Utf8TextAtomic -Path (Join-Path $packageRoot 'PACKAGE-MANIFEST.json') -Text (($manifest | ConvertTo-Json -Depth 100) + "`n")

    [System.IO.Directory]::CreateDirectory((Split-Path -Parent $resolvedOutput)) | Out-Null
    if (Test-Path -LiteralPath $resolvedOutput -PathType Leaf) {
        Remove-Item -LiteralPath $resolvedOutput -Force
    }
    Invoke-HiddenTar -Arguments @('-czf', $resolvedOutput, '-C', $stagingRoot, 'bmo-agent-benchmark') -WorkingDirectory $stagingRoot | Out-Null
    $listing = Invoke-HiddenTar -Arguments @('-tzf', $resolvedOutput) -WorkingDirectory $stagingRoot
    $entries = @($listing.stdout -split '\r?\n' | Where-Object { $_ })
    if ('bmo-agent-benchmark/SKILL.md' -notin $entries -or 'bmo-agent-benchmark/PACKAGE-MANIFEST.json' -notin $entries) {
        throw 'Package verification failed: required entries are absent.'
    }

    $packageHash = Get-Sha256File -Path $resolvedOutput
    $sidecar = "$resolvedOutput.sha256"
    Write-Utf8TextAtomic -Path $sidecar -Text ("$packageHash  $([System.IO.Path]::GetFileName($resolvedOutput))`n")
    $result = [ordered]@{
        ok = $true
        package = $resolvedOutput
        sha256 = $packageHash
        sha256Sidecar = $sidecar
        bytes = (Get-Item -LiteralPath $resolvedOutput).Length
        entries = $entries.Count
        visibleWindow = $false
    }
    if ($Json) { $result | ConvertTo-Json -Depth 10 } else { $result | Format-List | Out-String | Write-Output }
}
finally {
    $resolvedStaging = [System.IO.Path]::GetFullPath($stagingRoot)
    $resolvedBase = [System.IO.Path]::GetFullPath($stagingBase).TrimEnd('\')
    if ($resolvedStaging.StartsWith("$resolvedBase\", [System.StringComparison]::OrdinalIgnoreCase) -and
        (Test-Path -LiteralPath $resolvedStaging -PathType Container)) {
        [System.IO.Directory]::Delete($resolvedStaging, $true)
    }
}
