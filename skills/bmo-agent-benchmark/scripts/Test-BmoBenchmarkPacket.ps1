[CmdletBinding()]
param(
    [string]$SkillRoot = (Split-Path -Parent $PSScriptRoot),
    [switch]$Json,
    [switch]$PassThru,
    [switch]$NoExit
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Get-Sha256File {
    param([Parameter(Mandatory)][string]$Path)
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
}

function Get-TreeSha256 {
    param([Parameter(Mandatory)][string]$Root)

    $resolvedRoot = [System.IO.Path]::GetFullPath($Root).TrimEnd('\')
    $rows = Get-ChildItem -LiteralPath $resolvedRoot -File -Recurse |
        Where-Object { $_.FullName -notmatch '\\(?:node_modules|\.svelte-kit|build|\.git)(?:\\|$)' } |
        ForEach-Object {
            $relative = $_.FullName.Substring($resolvedRoot.Length).TrimStart('\').Replace('\', '/')
            '{0}|{1}|{2}' -f $relative, $_.Length, (Get-Sha256File -Path $_.FullName)
        } |
        Sort-Object

    $text = $rows -join "`n"
    $bytes = [System.Text.UTF8Encoding]::new($false).GetBytes($text)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        (($sha.ComputeHash($bytes) | ForEach-Object { $_.ToString('x2') }) -join '').ToUpperInvariant()
    }
    finally {
        $sha.Dispose()
    }
}

$checks = [System.Collections.Generic.List[object]]::new()
function Add-Check {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][bool]$Passed,
        [Parameter(Mandatory)][string]$Detail
    )
    $checks.Add([pscustomobject]@{
        name = $Name
        passed = $Passed
        detail = $Detail
    }) | Out-Null
}

$fixtureRoot = Join-Path $SkillRoot 'assets\fixture-v2'
$starterRoot = Join-Path $SkillRoot 'assets\starter'
$paths = [ordered]@{
    brief = Join-Path $fixtureRoot 'bmo-home-source-brief.json'
    specification = Join-Path $fixtureRoot 'implementation-spec.md'
    reasoning_kernel = Join-Path $fixtureRoot 'visible-reasoning-kernel.md'
    standard_condition = Join-Path $fixtureRoot 'condition-standard.md'
    action_condition = Join-Path $fixtureRoot 'condition-action-first.md'
    pass1_template = Join-Path $fixtureRoot 'pass1-task-template.md'
    pass2_template = Join-Path $fixtureRoot 'pass2-task-template.md'
    matrix = Join-Path $fixtureRoot 'matrix-v2.json'
}

foreach ($entry in $paths.GetEnumerator()) {
    Add-Check -Name "file_$($entry.Key)" -Passed (Test-Path -LiteralPath $entry.Value -PathType Leaf) -Detail $entry.Value
}

$missing = @($checks | Where-Object { -not $_.passed })
if ($missing.Count -gt 0) {
    $report = [ordered]@{
        schemaVersion = '1.0.0'
        ok = $false
        checkedAt = (Get-Date).ToString('o')
        checks = $checks
        assetHashes = @{}
    }
    $rendered = $report | ConvertTo-Json -Depth 20
    if ($Json) { $rendered } else { $checks | Format-Table -AutoSize | Out-String | Write-Output }
    if (-not $NoExit) { exit 2 }
    if ($PassThru) { return $report }
    return
}

$briefText = [System.IO.File]::ReadAllText($paths.brief)
$brief = $briefText | ConvertFrom-Json -Depth 100
$matrix = [System.IO.File]::ReadAllText($paths.matrix) | ConvertFrom-Json -Depth 100

Add-Check 'brief_schema' ($brief.schemaVersion -eq '2.0.0') "schema=$($brief.schemaVersion)"
Add-Check 'brief_fixture_id' ($brief.fixture.id -eq 'bmo-personal-home-2026-07') "id=$($brief.fixture.id)"
Add-Check 'brief_source_url' ($brief.source.url -eq 'https://www.bmo.com/en-ca/main/personal/') "url=$($brief.source.url)"
Add-Check 'brief_no_powershell_stringification' (-not ($briefText -match '"@\{')) 'No JSON string begins with a PowerShell object rendering.'

$heroCampaigns = @($brief.hero.campaigns)
$tabProperties = @($brief.needsNavigator.tabs.PSObject.Properties)
$tabCardCounts = @($tabProperties | ForEach-Object { @($_.Value).Count })
$allCards = @($tabProperties | ForEach-Object { @($_.Value) })
$helpCards = @($brief.helpChoose.cards)

Add-Check 'brief_hero_count' ($heroCampaigns.Count -eq 7) "count=$($heroCampaigns.Count)"
Add-Check 'brief_tab_count' ($tabProperties.Count -eq 6) "count=$($tabProperties.Count)"
Add-Check 'brief_six_cards_per_tab' (@($tabCardCounts | Where-Object { $_ -ne 6 }).Count -eq 0) "counts=$($tabCardCounts -join ',')"
Add-Check 'brief_total_card_count' ($allCards.Count -eq 36) "count=$($allCards.Count)"
Add-Check 'brief_help_count' ($helpCards.Count -eq 3) "count=$($helpCards.Count)"
Add-Check 'brief_primary_nav_count' (@($brief.header.primaryNav).Count -eq 7) "count=$(@($brief.header.primaryNav).Count)"
Add-Check 'brief_footer_group_count' (@($brief.footer.groups).Count -eq 7) "count=$(@($brief.footer.groups).Count)"
Add-Check 'brief_acceptance_present' (@($brief.acceptance).Count -ge 10) "count=$(@($brief.acceptance).Count)"

$ctaNodes = @(
    $heroCampaigns | ForEach-Object cta
    $allCards | ForEach-Object cta
    $helpCards | ForEach-Object cta
    $brief.mobileAppBanner.cta
)
$imageNodes = @(
    $heroCampaigns | ForEach-Object image
    $allCards | ForEach-Object image
    $brief.mobileAppBanner.image
)
$invalidCtas = @($ctaNodes | Where-Object { $_ -is [string] -or $null -eq $_ })
$invalidImages = @($imageNodes | Where-Object { $_ -is [string] -or $null -eq $_ })
Add-Check 'brief_ctas_are_objects' ($invalidCtas.Count -eq 0) "invalid=$($invalidCtas.Count)"
Add-Check 'brief_images_are_objects' ($invalidImages.Count -eq 0) "invalid=$($invalidImages.Count)"

$cells = @($matrix.cells)
$waves = @($matrix.waves)
$ids = @($cells | ForEach-Object id)
$targetKeys = @($cells | ForEach-Object targetKey | Sort-Object -Unique)
$dependencyErrors = @(
    $cells |
        Where-Object { $_.pass -eq 2 } |
        Where-Object {
            $dependency = $_.dependsOn
            $producer = @($cells | Where-Object id -eq $dependency)
            $producer.Count -ne 1 -or $producer[0].targetKey -ne $_.targetKey -or $producer[0].pass -ne 1
        }
)

Add-Check 'matrix_schema' ($matrix.schemaVersion -eq '2.0.0') "schema=$($matrix.schemaVersion)"
Add-Check 'matrix_cell_count' ($cells.Count -eq 16) "count=$($cells.Count)"
Add-Check 'matrix_unique_ids' (@($ids | Sort-Object -Unique).Count -eq 16) "unique=$(@($ids | Sort-Object -Unique).Count)"
Add-Check 'matrix_wave_count' ($waves.Count -eq 4) "count=$($waves.Count)"
Add-Check 'matrix_four_cells_per_wave' (@($waves | Where-Object { @($_.cells).Count -ne 4 }).Count -eq 0) 'Expected four cells in each wave.'
Add-Check 'matrix_target_count' ($targetKeys.Count -eq 8) "count=$($targetKeys.Count)"
Add-Check 'matrix_two_passes_per_target' (@($targetKeys | Where-Object { @($cells | Where-Object targetKey -eq $_).Count -ne 2 }).Count -eq 0) 'Expected two cells per target.'
Add-Check 'matrix_dependencies' ($dependencyErrors.Count -eq 0) "invalid=$($dependencyErrors.Count)"
Add-Check 'matrix_harness_balance' (
    @($cells | Where-Object harness -eq 'hermes').Count -eq 8 -and
    @($cells | Where-Object harness -eq 'claudeseek').Count -eq 8
) 'Hermes=8; ClaudeSeek=8'
Add-Check 'matrix_model_balance' (
    @($cells | Where-Object model -eq 'deepseek-v4-flash').Count -eq 12 -and
    @($cells | Where-Object model -eq 'deepseek-v4-pro').Count -eq 4
) 'Flash=12; Pro=4'
Add-Check 'matrix_condition_balance' (
    @($cells | Where-Object condition -eq 'standard').Count -eq 8 -and
    @($cells | Where-Object condition -eq 'action-first').Count -eq 8
) 'standard=8; action-first=8'
Add-Check 'matrix_serial_execution' ($matrix.design.execution -eq 'serial-within-wave') "execution=$($matrix.design.execution)"
Add-Check 'matrix_spend_stop' ([double]$matrix.design.providerSpendStopUsd -gt 0) "usd=$($matrix.design.providerSpendStopUsd)"

$requiredStarterFiles = @(
    'package.json',
    'package-lock.json',
    'vite.config.ts',
    'tsconfig.json',
    'src\routes\+layout.svelte',
    'src\routes\+page.svelte'
)
foreach ($relative in $requiredStarterFiles) {
    Add-Check -Name "starter_$($relative.Replace('\','_').Replace('+','plus'))" `
        -Passed (Test-Path -LiteralPath (Join-Path $starterRoot $relative) -PathType Leaf) `
        -Detail $relative
}
Add-Check 'starter_no_dependencies' (-not (Test-Path -LiteralPath (Join-Path $starterRoot 'node_modules'))) 'The synced starter excludes node_modules.'

$rawPacketChars = @(
    $paths.specification,
    $paths.brief,
    $paths.reasoning_kernel,
    $paths.action_condition,
    $paths.pass2_template
) | ForEach-Object { (Get-Item -LiteralPath $_).Length } | Measure-Object -Sum
Add-Check 'packet_size_margin' ($rawPacketChars.Sum -le 52000) "raw_bytes=$($rawPacketChars.Sum); adapter_limit=$($matrix.design.maxPromptCharacters)"

$assetHashes = [ordered]@{}
foreach ($entry in $paths.GetEnumerator()) {
    $assetHashes[$entry.Key] = Get-Sha256File -Path $entry.Value
}
$assetHashes['starter_tree'] = Get-TreeSha256 -Root $starterRoot

$ok = @($checks | Where-Object { -not $_.passed }).Count -eq 0
$report = [ordered]@{
    schemaVersion = '1.0.0'
    ok = $ok
    checkedAt = (Get-Date).ToString('o')
    counts = [ordered]@{
        campaigns = $heroCampaigns.Count
        tabs = $tabProperties.Count
        cards = $allCards.Count
        helpCards = $helpCards.Count
        cells = $cells.Count
        waves = $waves.Count
    }
    assetHashes = $assetHashes
    checks = $checks
}

if ($Json -and -not $PassThru) {
    $report | ConvertTo-Json -Depth 30
}
elseif (-not $PassThru) {
    $checks | Format-Table -AutoSize | Out-String | Write-Output
    "packet_ok=$ok" | Write-Output
}

if (-not $NoExit -and -not $ok) {
    exit 2
}

if ($PassThru) {
    $report
}
