[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ArtifactRoot,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$CheckLog,

    [string]$HarnessLog,
    [string]$JsonOutputPath,

    [ValidateRange(0, 100)]
    [double]$MinimumSemanticCoverage = 100,

    [switch]$NoExit
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$skillRoot = Split-Path -Parent $PSScriptRoot
$briefPath = Join-Path $skillRoot 'assets\fixture-v2\bmo-home-source-brief.json'
$baselineRoot = Join-Path $skillRoot 'assets\starter'
$wikiRoot = $skillRoot
1..4 | ForEach-Object { $wikiRoot = Split-Path -Parent $wikiRoot }
$contractScript = Join-Path $wikiRoot '00_Kit\scripts\Test-AgentArtifactContract.ps1'

foreach ($required in @($briefPath, $contractScript)) {
    if (-not (Test-Path -LiteralPath $required -PathType Leaf)) {
        throw "Required file is missing: $required"
    }
}

$resolvedArtifact = [System.IO.Path]::GetFullPath($ArtifactRoot).TrimEnd('\')
if (-not (Test-Path -LiteralPath $resolvedArtifact -PathType Container)) {
    throw "Artifact root does not exist: $resolvedArtifact"
}

$brief = Get-Content -LiteralPath $briefPath -Raw | ConvertFrom-Json -Depth 100
$tabProperties = @($brief.needsNavigator.tabs.PSObject.Properties)

$requiredLiterals = @(
    @($brief.hero.campaigns | ForEach-Object id)
    @($brief.hero.campaigns | ForEach-Object title)
    @($tabProperties | ForEach-Object Name)
    @($tabProperties | ForEach-Object { $_.Value | ForEach-Object heading })
    @($brief.helpChoose.cards | ForEach-Object heading)
    @($brief.footer.groups)
    @($brief.header.primaryNav)
    @($brief.mobileAppBanner.heading)
    'REFERENCE DEMO'
) | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) } | Select-Object -Unique

$arguments = @{
    ArtifactRoot = $resolvedArtifact
    BaselineRoot = $baselineRoot
    EntryRelativePath = 'src\routes\+page.svelte'
    RequiredRelativePath = @(
        'package.json'
        'src\routes\+layout.svelte'
        'src\lib\data\bmo-home.ts'
    )
    RequiredLiteral = $requiredLiterals
    ForbiddenPattern = @(
        '\bfetch\s*\('
        '\bXMLHttpRequest\b'
        '\bWebSocket\b'
        '\blocalStorage\b'
        '\bsessionStorage\b'
        'googletagmanager'
        'google-analytics'
        '\bOneTrust\b'
        '\bAdobe\b.{0,80}\b(?:analytics|launch)\b'
        '<input[^>]+type\s*=\s*[''"]?password'
        '<form\b'
    )
    MinimumRequiredLiteralPercent = $MinimumSemanticCoverage
    CheckLog = $CheckLog
    NoExit = $true
    PassThru = $true
}
if ($HarnessLog) { $arguments.HarnessLog = $HarnessLog }
if ($JsonOutputPath) { $arguments.JsonOutputPath = $JsonOutputPath }

$report = & $contractScript @arguments

if (-not $NoExit -and $report.verdict -ne 'PASS') {
    exit 2
}

$report
