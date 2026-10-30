#Requires -Version 5.1
<#
.SYNOPSIS
Read-only, opt-in context summary for WAYFINDER.
.DESCRIPTION
Reads top-level manifest signals, command availability, and local Git state.
Does not execute discovered helpers, read credential/config contents, use the network,
install packages, or write files. Hardware probing and local path disclosure are opt-in.
Run in the existing PowerShell session to see already-loaded custom helper functions.
.PARAMETER RepoRoot
An existing project directory. Defaults to the current directory.
.PARAMETER IncludeHardware
Query basic CPU/RAM/GPU names with CIM when available; does not estimate usable VRAM.
.PARAMETER IncludeLocalPaths
Include the resolved project path. Keep omitted for a shareable summary.
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$RepoRoot = (Get-Location).Path,
    [string]$AiWikiRoot = $env:AIWIKI_ROOT,
    [string]$RuntimeRoot = $env:AIWIKI_RUNTIME_ROOT,
    [string]$BrowserStagingRoot = $env:BROWSER_STAGING_ROOT,
    [switch]$IncludeHardware,
    [switch]$IncludeLocalPaths
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoItem = Get-Item -LiteralPath $RepoRoot -ErrorAction Stop
if (-not $repoItem.PSIsContainer) {
    throw 'RepoRoot must be an existing directory.'
}
$repo = $repoItem.FullName

$commandNames = @(
    'git', 'node', 'bun', 'pnpm', 'npm', 'yarn', 'py', 'python', 'dotnet',
    'codex', 'claude', 'opencode', 'hermes', 'gh',
    'Search', 'qsr', 'qsp', 'qsb', 'Skills', 'Copy-In', 'Copy', 'Execute',
    'Import-SvelteLabDemo'
)
$commands = @(
    foreach ($name in $commandNames) {
        $found = @(Get-Command -Name $name -ErrorAction SilentlyContinue)
        [pscustomobject]@{
            name = $name
            available = ($found.Count -gt 0)
            commandTypes = @($found | ForEach-Object { [string]$_.CommandType } | Select-Object -Unique)
        }
    }
)

$signals = @(
    'AGENTS.md', 'CLAUDE.md', 'INTENT.md', 'intent.md', 'README.md', '.thoughts',
    '.ai', '.agents', '.claude', '.opencode', 'package.json', 'bun.lock', 'bun.lockb',
    'pnpm-lock.yaml', 'package-lock.json', 'yarn.lock', 'pnpm-workspace.yaml',
    'svelte.config.js', 'svelte.config.ts', 'vite.config.ts', 'angular.json',
    'pyproject.toml', 'requirements.txt', 'composer.json', 'global.json',
    'settings.gradle.kts', 'build.gradle.kts', 'gradlew.bat'
)
$present = @(
    foreach ($name in $signals) {
        $candidate = Join-Path -Path $repo -ChildPath $name
        if (Test-Path -LiteralPath $candidate) {
            (Get-Item -LiteralPath $candidate -Force).Name
        }
    }
) | Select-Object -Unique

$package = [ordered]@{
    status = 'absent'
    declaredPackageManager = $null
    frameworkSignals = @()
    scriptNames = @()
    note = 'Names are discovery hints, not approval to run package scripts.'
}
$packagePath = Join-Path -Path $repo -ChildPath 'package.json'
if (Test-Path -LiteralPath $packagePath -PathType Leaf) {
    try {
        if ((Get-Item -LiteralPath $packagePath).Length -gt 1048576) {
            $package.status = 'not-read-over-1MiB'
        }
        else {
            $manifest = Get-Content -LiteralPath $packagePath -Raw | ConvertFrom-Json
            $package.status = 'parsed'
            $properties = @($manifest.PSObject.Properties | ForEach-Object { $_.Name })
            if ($properties -contains 'packageManager') {
                $manager = [string]$manifest.packageManager
                if ($manager -match '^(npm|pnpm|yarn|bun)@[0-9A-Za-z.+_-]+$') {
                    $package.declaredPackageManager = $manager
                }
            }
            if (($properties -contains 'scripts') -and $null -ne $manifest.scripts) {
                # Script bodies can contain sensitive values or mutate state: never emit them.
                $package.scriptNames = @($manifest.scripts.PSObject.Properties | ForEach-Object { $_.Name } |
                    Where-Object { $_ -match '^[a-zA-Z0-9:_-]{1,80}$' } | Sort-Object)
            }
            $allowedFrameworks = @(
                'svelte', '@sveltejs/kit', 'react', '@angular/core', 'vue', 'next',
                'vite', 'vitest', '@playwright/test', 'typescript'
            )
            $frameworks = @(
                foreach ($section in @('dependencies', 'devDependencies')) {
                    if (($properties -contains $section) -and $null -ne $manifest.$section) {
                        foreach ($dependency in $manifest.$section.PSObject.Properties) {
                            if ($allowedFrameworks -contains $dependency.Name) {
                                $dependency.Name
                            }
                        }
                    }
                }
            )
            $package.frameworkSignals = @($frameworks | Sort-Object -Unique)
        }
    }
    catch {
        # Do not echo manifest contents or parser error excerpts into reports.
        $package.status = 'parse-failed-inspect-locally'
    }
}

$gitInfo = [ordered]@{
    status = 'git-unavailable'
    revision = $null
    dirty = $null
    statusEntryCount = $null
    note = 'No remote URLs, diff contents, filenames, or credential config are emitted.'
}
$gitCommands = @(Get-Command -Name git -CommandType Application -ErrorAction SilentlyContinue)
if ($gitCommands.Count -gt 0) {
    $gitExecutable = $gitCommands[0].Source
    try {
        $inside = @(& $gitExecutable --no-optional-locks -C $repo rev-parse --is-inside-work-tree 2>$null)
        if (($LASTEXITCODE -eq 0) -and (($inside -join '') -eq 'true')) {
            $gitInfo.status = 'worktree'
            $revision = @(& $gitExecutable --no-optional-locks -C $repo rev-parse --verify --quiet HEAD 2>$null)
            if ($LASTEXITCODE -eq 0) {
                $candidateRevision = ($revision -join '').Trim()
                if ($candidateRevision -match '^[0-9a-f]{40,64}$') {
                    $gitInfo.revision = $candidateRevision
                }
            }
            $statusLines = @(& $gitExecutable --no-optional-locks -C $repo status --porcelain=v1 --untracked-files=normal --ignore-submodules=all 2>$null)
            if ($LASTEXITCODE -eq 0) {
                $gitInfo.statusEntryCount = $statusLines.Count
                $gitInfo.dirty = ($statusLines.Count -gt 0)
                $gitInfo.note = 'Snapshot only; submodule changes are not inspected. Never infer change ownership from this count.'
            }
            else {
                $gitInfo.status = 'worktree-status-unavailable'
            }
        }
        else {
            $gitInfo.status = 'not-a-readable-worktree'
        }
    }
    catch {
        $gitInfo.status = 'git-probe-failed-inspect-locally'
    }
}

$hardware = [ordered]@{ status = 'not-requested' }
if ($IncludeHardware) {
    if (Get-Command -Name Get-CimInstance -ErrorAction SilentlyContinue) {
        try {
            $system = Get-CimInstance -ClassName Win32_ComputerSystem
            $processors = @(Get-CimInstance -ClassName Win32_Processor)
            $video = @(Get-CimInstance -ClassName Win32_VideoController)
            $hardware = [ordered]@{
                status = 'observed-via-cim'
                totalRamGiB = [math]::Round(([double]$system.TotalPhysicalMemory / 1GB), 1)
                cpuNames = @($processors | ForEach-Object { $_.Name })
                logicalProcessors = ($processors | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum
                gpuNames = @($video | ForEach-Object { $_.Name })
                note = 'Installed hardware, not free headroom; usable VRAM, free RAM, disk space and workload load still require relevant checks.'
            }
        }
        catch {
            $hardware = [ordered]@{ status = 'cim-unavailable-or-denied' }
        }
    }
    else {
        $hardware = [ordered]@{ status = 'cim-command-unavailable' }
    }
}

function Test-ConfiguredRoot([string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) { return $null }
    return (Test-Path -LiteralPath $Path -PathType Container -ErrorAction SilentlyContinue)
}
$pathChecks = [ordered]@{
    aiWiki = (Test-ConfiguredRoot $AiWikiRoot)
    localRuntime = (Test-ConfiguredRoot $RuntimeRoot)
    browserStaging = (Test-ConfiguredRoot $BrowserStagingRoot)
}
$displayRepo = '<local-project>'
if ($IncludeLocalPaths) { $displayRepo = $repo }

[ordered]@{
    schemaVersion = 1
    observedAtUtc = [DateTime]::UtcNow.ToString('o')
    powershellVersion = [string]$PSVersionTable.PSVersion
    operatingSystem = [Environment]::OSVersion.VersionString
    project = $displayRepo
    topLevelSignals = @($present)
    package = $package
    git = $gitInfo
    commands = $commands
    knownRootPresence = $pathChecks
    hardware = $hardware
    limitations = @(
        'Does not recursively audit a monorepo or read applicable instructions.',
        'Does not verify harness versions, auth, quota, model identity, or provider capabilities.',
        'Does not execute discovered helpers or package scripts.',
        'A context snapshot is not an installation, acceptance result, or authorization.'
    )
} | ConvertTo-Json -Depth 8
