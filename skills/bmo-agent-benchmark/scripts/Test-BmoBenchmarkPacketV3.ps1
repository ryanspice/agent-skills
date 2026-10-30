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

$fixtureRoot = Join-Path $SkillRoot 'assets\fixture-v3'
$starterRoot = Join-Path $SkillRoot 'assets\starter'
$artifactValidatorPath = Join-Path $PSScriptRoot 'Test-BmoBenchmarkArtifactV3.ps1'
$browserProbePath = Join-Path $PSScriptRoot 'Test-BmoBrowserArtifactV3.mjs'
$runnerPath = Join-Path $PSScriptRoot 'Invoke-BmoAgentBenchmarkV3.ps1'
$wikiRoot = $SkillRoot
for ($i = 0; $i -lt 4; $i++) {
    $wikiRoot = Split-Path -Parent $wikiRoot
}
$sharedArtifactContractPath = Join-Path $wikiRoot '00_Kit\scripts\Test-AgentArtifactContract.ps1'
$paths = [ordered]@{
    brief = Join-Path $fixtureRoot 'bmo-home-source-brief.json'
    specification = Join-Path $fixtureRoot 'implementation-spec.md'
    reasoning_kernel = Join-Path $fixtureRoot 'visible-reasoning-kernel.md'
    policy = Join-Path $fixtureRoot 'policy-spiceflow-v0.4-bmo.md'
    source_archive = Join-Path $fixtureRoot 'source-archive-manifest.json'
    standard_condition = Join-Path $fixtureRoot 'condition-standard.md'
    action_condition = Join-Path $fixtureRoot 'condition-action-first.md'
    pass1_template = Join-Path $fixtureRoot 'pass1-task-template.md'
    pass2_template = Join-Path $fixtureRoot 'pass2-task-template.md'
    matrix = Join-Path $fixtureRoot 'matrix-v3.json'
}

foreach ($entry in $paths.GetEnumerator()) {
    Add-Check -Name "file_$($entry.Key)" -Passed (Test-Path -LiteralPath $entry.Value -PathType Leaf) -Detail $entry.Value
}
Add-Check 'script_artifact_validator_v3' (
    Test-Path -LiteralPath $artifactValidatorPath -PathType Leaf
) $artifactValidatorPath
Add-Check 'script_browser_probe_v3' (
    Test-Path -LiteralPath $browserProbePath -PathType Leaf
) $browserProbePath
Add-Check 'script_runner_v3' (
    Test-Path -LiteralPath $runnerPath -PathType Leaf
) $runnerPath
Add-Check 'script_shared_artifact_contract' (
    Test-Path -LiteralPath $sharedArtifactContractPath -PathType Leaf
) $sharedArtifactContractPath

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
$policyText = [System.IO.File]::ReadAllText($paths.policy)
$sourceArchive = [System.IO.File]::ReadAllText($paths.source_archive) | ConvertFrom-Json -Depth 30
$artifactValidatorText = [System.IO.File]::ReadAllText($artifactValidatorPath)
$browserProbeText = [System.IO.File]::ReadAllText($browserProbePath)
$runnerText = [System.IO.File]::ReadAllText($runnerPath)
$sharedArtifactContractText = [System.IO.File]::ReadAllText($sharedArtifactContractPath)

Add-Check 'artifact_semantic_normalization_enabled' (
    $artifactValidatorText -match 'NormalizeSemanticLiterals\s*=\s*\$true'
) 'The BMO validator enables typography-tolerant semantic literal matching.'
Add-Check 'artifact_semantic_normalization_opt_in' (
    $sharedArtifactContractText -match '\[switch\]\s*\$NormalizeSemanticLiterals' -and
    $sharedArtifactContractText -match 'function\s+Normalize-ArtifactSemanticText'
) 'The shared contract exposes normalization only as an explicit opt-in.'
Add-Check 'browser_external_resource_separation' (
    $browserProbeText -match 'externalResourceErrors' -and
    $browserProbeText -match 'locationUrl\.startsWith\(origin\)'
) 'External resource failures are recorded separately from local runtime failures.'
Add-Check 'browser_tab_interaction_gate' (
    $browserProbeText -match '\[role="tab"\]\[aria-selected="false"\]' -and
    $browserProbeText -match 'interactionPassed'
) 'The browser gate exercises a real inactive tab and reports the result.'
Add-Check 'runner_dependency_block_receipts' (
    $runnerText -match 'blocked-dependency' -and
    $runnerText -match 'function\s+New-BlockedCellReceipt' -and
    $runnerText -match 'cellsBlocked'
) 'Failed dependencies create zero-call terminal receipts without blocking independent cells.'
Add-Check 'runner_score_terminal_counts' (
    $runnerText -match 'attemptedCells' -and
    $runnerText -match 'failedCells' -and
    $runnerText -match 'notDispatchedCellIds'
) 'Scoring separates attempted, failed, blocked, and not-dispatched cells.'
Add-Check 'runner_score_only_matched_repair_pairs' (
    $runnerText -match '\$flashRepair\.Count\s+-ne\s+1\s+-or\s+\$proRepair\.Count\s+-ne\s+1'
) 'Matched-repair output excludes incomplete or undispatched pairs.'
Add-Check 'runner_cost_dual_accounting' (
    $runnerText -match 'conservativeAccountDeltaUsd' -and
    $runnerText -match 'receiptDeltaSumUsd' -and
    $runnerText -match 'campaignInitialBalanceUsd'
) 'Run receipts preserve both per-cell deltas and conservative campaign-level account deltas.'

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
Add-Check 'policy_layer_order' (
    $policyText -match 'Clarity Gate' -and
    $policyText -match 'Coverage Gate' -and
    $policyText -match 'Evidence Gate'
) 'Clarity, Coverage and Evidence gates are present.'
Add-Check 'policy_divergent_focus_excluded' (
    $policyText -match 'Divergent Focus is excluded'
) 'Divergent Focus is excluded from BMO16.'
Add-Check 'policy_packet_contract' (
    @(
        @('GOAL','STATE','SOURCE','FILES','CONSTRAINTS','NON-GOALS','DO','VERIFY','STOP','RETURN','TERMS') |
            Where-Object { $policyText -notmatch [regex]::Escape("``$_``") }
    ).Count -eq 0
) 'All Neanderthal-compatible packet fields are present.'
Add-Check 'source_archive_schema' ($sourceArchive.schemaVersion -eq 'bmo.source-archive.v1') "schema=$($sourceArchive.schemaVersion)"
Add-Check 'source_archive_no_egress' (-not [bool]$sourceArchive.delegateEgress) "delegateEgress=$($sourceArchive.delegateEgress)"
$archivePath = ([string]$sourceArchive.archivePath).Replace(
    '<DEV_ROOT>',
    ('B:' + [System.IO.Path]::DirectorySeparatorChar + 'Dev')
)
$archiveExists = Test-Path -LiteralPath $archivePath -PathType Leaf
Add-Check 'source_archive_exists' $archiveExists $archivePath
if ($archiveExists) {
    Add-Check 'source_archive_hash' (
        (Get-Sha256File -Path $archivePath) -eq [string]$sourceArchive.archiveSha256
    ) "expected=$($sourceArchive.archiveSha256)"
}

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
$initialCells = @($cells | Where-Object { [int]$_.pass -eq 1 })
$repairCells = @($cells | Where-Object { [int]$_.pass -eq 2 })
$frozenSources = @($initialCells | Where-Object { [bool]$_.freezeForRepairs })
$dependencyErrors = @(
    $repairCells |
        Where-Object {
            $dependency = $_.dependsOn
            $producer = @($cells | Where-Object id -eq $dependency)
            $producer.Count -ne 1 -or
            [int]$producer[0].pass -ne 1 -or
            -not [bool]$producer[0].freezeForRepairs -or
            [string]$producer[0].targetKey -eq [string]$_.targetKey -or
            [string]$producer[0].harness -ne [string]$_.harness -or
            [string]$producer[0].condition -ne [string]$_.condition
        }
)
$consumerCountErrors = @(
    $frozenSources |
        Where-Object { @($repairCells | Where-Object dependsOn -eq $_.id).Count -ne 2 }
)
$repairPairErrors = @(
    $frozenSources |
        Where-Object {
            $repairs = @($repairCells | Where-Object dependsOn -eq $_.id)
            @($repairs | Where-Object model -eq 'deepseek-v4-flash').Count -ne 1 -or
            @($repairs | Where-Object model -eq 'deepseek-v4-pro').Count -ne 1
        }
)

Add-Check 'matrix_schema' ($matrix.schemaVersion -eq '3.0.0') "schema=$($matrix.schemaVersion)"
Add-Check 'matrix_cell_count' ($cells.Count -eq 16) "count=$($cells.Count)"
Add-Check 'matrix_unique_ids' (@($ids | Sort-Object -Unique).Count -eq 16) "unique=$(@($ids | Sort-Object -Unique).Count)"
Add-Check 'matrix_exact_ids' (
    @(
        Compare-Object @('F01','F02','F03','F04','F05','F06','F07','F08','F09','F10','F11','F12','P13','P14','P15','P16') @($ids | Sort-Object)
    ).Count -eq 0
) 'Expected F01-F12 and P13-P16.'
Add-Check 'matrix_wave_count' ($waves.Count -eq 4) "count=$($waves.Count)"
Add-Check 'matrix_four_cells_per_wave' (@($waves | Where-Object { @($_.cells).Count -ne 4 }).Count -eq 0) 'Expected four cells in each wave.'
Add-Check 'matrix_target_count' ($targetKeys.Count -eq 16) "count=$($targetKeys.Count)"
Add-Check 'matrix_one_cell_per_target' (@($targetKeys | Where-Object { @($cells | Where-Object targetKey -eq $_).Count -ne 1 }).Count -eq 0) 'Every cell has an isolated target.'
Add-Check 'matrix_initial_count' ($initialCells.Count -eq 8) "count=$($initialCells.Count)"
Add-Check 'matrix_repair_count' ($repairCells.Count -eq 8) "count=$($repairCells.Count)"
Add-Check 'matrix_frozen_source_count' ($frozenSources.Count -eq 4) "count=$($frozenSources.Count)"
Add-Check 'matrix_dependencies' ($dependencyErrors.Count -eq 0) "invalid=$($dependencyErrors.Count)"
Add-Check 'matrix_two_consumers_per_frozen_source' ($consumerCountErrors.Count -eq 0) "invalid=$($consumerCountErrors.Count)"
Add-Check 'matrix_identical_flash_pro_pairs' ($repairPairErrors.Count -eq 0) "invalid=$($repairPairErrors.Count)"
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
Add-Check 'matrix_cycle_cap' ([int]$matrix.design.maxCyclesPerCell -eq 12) "cycles=$($matrix.design.maxCyclesPerCell)"
Add-Check 'matrix_runtime_cap' ([int]$matrix.design.maxRuntimeSecondsPerCell -eq 1200) "seconds=$($matrix.design.maxRuntimeSecondsPerCell)"
Add-Check 'matrix_zero_retries' ([int]$matrix.design.apiRetriesPerCell -eq 0) "retries=$($matrix.design.apiRetriesPerCell)"
Add-Check 'matrix_no_divergent_focus' (-not [bool]$matrix.design.divergentFocus) "divergentFocus=$($matrix.design.divergentFocus)"
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
    $paths.policy,
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
