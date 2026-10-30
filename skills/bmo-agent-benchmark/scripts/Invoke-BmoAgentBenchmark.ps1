[CmdletBinding()]
param(
    [ValidateSet('Validate', 'Plan', 'DryRun', 'Run', 'Score')]
    [string]$Action = 'Validate',

    [string]$WorkspaceRoot = '',

    [string]$DependencyRoot = '',

    [string]$ApprovedPlanSha256 = '',

    [string]$ConfirmToken = '',

    [ValidateRange(1, 168)]
    [int]$PlanTtlHours = 24,

    [switch]$Resume,
    [switch]$ContinueAfterFailedCell,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$skillRoot = Split-Path -Parent $PSScriptRoot
$fixtureRoot = Join-Path $skillRoot 'assets\fixture-v2'
$starterRoot = Join-Path $skillRoot 'assets\starter'
$packetValidator = Join-Path $PSScriptRoot 'Test-BmoBenchmarkPacket.ps1'
$artifactValidator = Join-Path $PSScriptRoot 'Test-BmoBenchmarkArtifact.ps1'
$matrixPath = Join-Path $fixtureRoot 'matrix-v2.json'
$briefPath = Join-Path $fixtureRoot 'bmo-home-source-brief.json'
$specificationPath = Join-Path $fixtureRoot 'implementation-spec.md'
$reasoningKernelPath = Join-Path $fixtureRoot 'visible-reasoning-kernel.md'
$standardConditionPath = Join-Path $fixtureRoot 'condition-standard.md'
$actionConditionPath = Join-Path $fixtureRoot 'condition-action-first.md'
$pass1TemplatePath = Join-Path $fixtureRoot 'pass1-task-template.md'
$pass2TemplatePath = Join-Path $fixtureRoot 'pass2-task-template.md'

$localDriveRoot = 'B:' + [System.IO.Path]::DirectorySeparatorChar
$devRoot = Join-Path $localDriveRoot 'Dev'
$runtimeRoot = Join-Path $localDriveRoot 'AI-Wiki.runtime'
if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) {
    $WorkspaceRoot = Join-Path $devRoot 'deepseek.workspace\bmo-agent-benchmark\bmo16-v2-20260726'
}
if ([string]::IsNullOrWhiteSpace($DependencyRoot)) {
    $DependencyRoot = Join-Path $devRoot 'deepseek.workspace\bmo-flash-test\matrix-template\node_modules'
}

$fuguAdapter = Join-Path $env:USERPROFILE '.local\bin\Invoke-FuguLane.ps1'
$claudeSeekFlash = Join-Path $env:USERPROFILE '.local\bin\claudeseek-flash.ps1'
$claudeSeekPro = Join-Path $env:USERPROFILE '.local\bin\claudeseek.ps1'
$flashProfile = Join-Path $env:LOCALAPPDATA 'hermes\profiles\code-flash\config.yaml'
$proProfile = Join-Path $env:LOCALAPPDATA 'hermes\profiles\review-pro\config.yaml'
$hermesAgentRoot = Join-Path $env:LOCALAPPDATA 'hermes\hermes-agent'
$hermesExecutable = Join-Path $hermesAgentRoot 'venv\Scripts\hermes.exe'
$hermesParser = Join-Path $hermesAgentRoot 'hermes_cli\_parser.py'
$hermesMain = Join-Path $hermesAgentRoot 'hermes_cli\main.py'
$hermesQueryInput = Join-Path $hermesAgentRoot 'hermes_cli\_query_input.py'

function Write-Utf8TextAtomic {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][AllowEmptyString()][string]$Text
    )

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $parent = Split-Path -Parent $fullPath
    if ($parent) {
        [System.IO.Directory]::CreateDirectory($parent) | Out-Null
    }
    $temporary = "$fullPath.$PID.$([Guid]::NewGuid().ToString('N')).tmp"
    try {
        [System.IO.File]::WriteAllText($temporary, $Text, [System.Text.UTF8Encoding]::new($false))
        [System.IO.File]::Move($temporary, $fullPath, $true)
    }
    finally {
        if (Test-Path -LiteralPath $temporary -PathType Leaf) {
            Remove-Item -LiteralPath $temporary -Force
        }
    }
}

function Write-JsonAtomic {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)]$Value,
        [int]$Depth = 100
    )
    Write-Utf8TextAtomic -Path $Path -Text (($Value | ConvertTo-Json -Depth $Depth) + "`n")
}

function Get-Sha256File {
    param([Parameter(Mandatory)][string]$Path)
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToUpperInvariant()
}

function Get-Sha256Text {
    param([Parameter(Mandatory)][AllowEmptyString()][string]$Text)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.UTF8Encoding]::new($false).GetBytes($Text)
        (($sha.ComputeHash($bytes) | ForEach-Object { $_.ToString('x2') }) -join '').ToUpperInvariant()
    }
    finally {
        $sha.Dispose()
    }
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
    Get-Sha256Text -Text ($rows -join "`n")
}

function Assert-SafeWorkspaceRoot {
    param([Parameter(Mandatory)][string]$Path)

    $fullPath = [System.IO.Path]::GetFullPath($Path).TrimEnd('\')
    $allowedRoots = @(
        (Join-Path $devRoot 'deepseek.workspace'),
        $runtimeRoot
    )
    $accepted = $false
    foreach ($allowed in $allowedRoots) {
        $allowedFull = [System.IO.Path]::GetFullPath($allowed).TrimEnd('\')
        if ($fullPath.StartsWith("$allowedFull\", [System.StringComparison]::OrdinalIgnoreCase)) {
            $accepted = $true
            break
        }
    }
    if (-not $accepted) {
        throw "WorkspaceRoot must be a descendant of an allowlisted machine-local root: $($allowedRoots -join ', ')"
    }
    $fullPath
}

function Assert-DescendantPath {
    param(
        [Parameter(Mandatory)][string]$Root,
        [Parameter(Mandatory)][string]$Path
    )
    $rootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd('\')
    $pathFull = [System.IO.Path]::GetFullPath($Path).TrimEnd('\')
    if (-not $pathFull.StartsWith("$rootFull\", [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Path escapes the approved workspace: $pathFull"
    }
    $pathFull
}

function Copy-BenchmarkTree {
    param(
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string]$Destination
    )

    if (Test-Path -LiteralPath $Destination) {
        throw "Destination already exists; refusing to merge benchmark state: $Destination"
    }
    [System.IO.Directory]::CreateDirectory($Destination) | Out-Null

    $sourceFull = [System.IO.Path]::GetFullPath($Source).TrimEnd('\')
    foreach ($directory in Get-ChildItem -LiteralPath $sourceFull -Directory -Recurse) {
        if ($directory.FullName -match '\\(?:node_modules|\.svelte-kit|build|\.git)(?:\\|$)') { continue }
        $relative = $directory.FullName.Substring($sourceFull.Length).TrimStart('\')
        [System.IO.Directory]::CreateDirectory((Join-Path $Destination $relative)) | Out-Null
    }
    foreach ($file in Get-ChildItem -LiteralPath $sourceFull -File -Recurse) {
        if ($file.FullName -match '\\(?:node_modules|\.svelte-kit|build|\.git)(?:\\|$)') { continue }
        $relative = $file.FullName.Substring($sourceFull.Length).TrimStart('\')
        $destinationFile = Join-Path $Destination $relative
        [System.IO.Directory]::CreateDirectory((Split-Path -Parent $destinationFile)) | Out-Null
        [System.IO.File]::Copy($file.FullName, $destinationFile, $false)
    }
}

function Invoke-HiddenProcess {
    param(
        [Parameter(Mandatory)][string]$FilePath,
        [Parameter(Mandatory)][string[]]$ArgumentList,
        [Parameter(Mandatory)][string]$WorkingDirectory,
        [AllowEmptyString()][string]$StandardInput = '',
        [ValidateRange(1, 3600)][int]$TimeoutSeconds = 900
    )

    $psi = [System.Diagnostics.ProcessStartInfo]::new()
    $psi.FileName = $FilePath
    $psi.WorkingDirectory = $WorkingDirectory
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.RedirectStandardInput = $true
    foreach ($argument in $ArgumentList) {
        $psi.ArgumentList.Add([string]$argument)
    }

    $process = [System.Diagnostics.Process]::new()
    $process.StartInfo = $psi
    $startedAt = Get-Date
    if (-not $process.Start()) {
        throw "Failed to start hidden process: $FilePath"
    }

    $stdoutTask = $process.StandardOutput.ReadToEndAsync()
    $stderrTask = $process.StandardError.ReadToEndAsync()
    $stdinWriteError = ''
    try {
        if ($StandardInput.Length -gt 0) {
            $process.StandardInput.Write($StandardInput)
        }
    }
    catch {
        # The child may exit before consuming stdin. Preserve that transport
        # failure, but still collect its exit code and stderr for diagnosis.
        $stdinWriteError = $_.Exception.Message
    }
    finally {
        try {
            $process.StandardInput.Close()
        }
        catch {
            if ([string]::IsNullOrWhiteSpace($stdinWriteError)) {
                $stdinWriteError = $_.Exception.Message
            }
        }
    }

    $timedOut = -not $process.WaitForExit($TimeoutSeconds * 1000)
    if ($timedOut) {
        try { $process.Kill($true) } catch { }
        $process.WaitForExit()
    }

    $stdout = $stdoutTask.GetAwaiter().GetResult()
    $stderr = $stderrTask.GetAwaiter().GetResult()
    if (-not [string]::IsNullOrWhiteSpace($stdinWriteError)) {
        $transportDiagnostic = "[hidden-process transport] stdin write failed: $stdinWriteError"
        $stderr = if ([string]::IsNullOrWhiteSpace($stderr)) {
            $transportDiagnostic
        } else {
            $stderr.TrimEnd() + [Environment]::NewLine + $transportDiagnostic
        }
    }
    $exitCode = if ($timedOut) { 124 } else { $process.ExitCode }
    $processId = $process.Id
    $process.Dispose()

    [pscustomobject]@{
        exitCode = $exitCode
        timedOut = $timedOut
        processId = $processId
        durationSeconds = [math]::Round(((Get-Date) - $startedAt).TotalSeconds, 3)
        stdout = $stdout
        stderr = $stderr
        stdinWriteError = $stdinWriteError
    }
}

function Assert-HiddenProcessEarlyExitCapture {
    param([Parameter(Mandatory)][string]$WorkingDirectory)

    $pwsh = (Get-Command pwsh -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
    $marker = 'BMO_HIDDEN_PROCESS_EARLY_EXIT'
    $probe = Invoke-HiddenProcess `
        -FilePath $pwsh `
        -ArgumentList @(
            '-NoProfile',
            '-NonInteractive',
            '-Command',
            "[Console]::Error.Write('$marker'); exit 23"
        ) `
        -WorkingDirectory $WorkingDirectory `
        -StandardInput ('x' * 1048576) `
        -TimeoutSeconds 30
    if ($probe.timedOut -or $probe.exitCode -ne 23 -or -not $probe.stderr.Contains($marker)) {
        throw "Hidden-process early-exit capture preflight failed: $(Get-LogExcerpt -Text $probe.stderr)"
    }
}

function Assert-ClaudeSeekBareTransport {
    param([Parameter(Mandatory)][string]$WorkingDirectory)

    $requiredAssignment = '$env:ANTHROPIC_API_KEY = $env:DEEPSEEK_API_KEY'
    foreach ($launcher in @($claudeSeekFlash, $claudeSeekPro)) {
        $launcherText = [System.IO.File]::ReadAllText($launcher)
        if (-not $launcherText.Contains($requiredAssignment)) {
            throw "ClaudeSeek bare-mode API-key binding is missing: $launcher"
        }
    }

    $pwsh = (Get-Command pwsh -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
    $helpArgumentsJson = ConvertTo-Json -InputObject ([object[]]@('--help')) -Compress
    $probe = Invoke-HiddenProcess `
        -FilePath $pwsh `
        -ArgumentList @(
            '-NoProfile',
            '-ExecutionPolicy', 'Bypass',
            '-File', $claudeSeekFlash,
            '-Project', $WorkingDirectory,
            '-NoSave',
            '-ClaudeArgsJson', $helpArgumentsJson
        ) `
        -WorkingDirectory $WorkingDirectory `
        -TimeoutSeconds 30
    $helpText = $probe.stdout + $probe.stderr
    if ($probe.exitCode -ne 0 -or $probe.timedOut) {
        throw "ClaudeSeek hidden-launch preflight failed: $(Get-LogExcerpt -Text $helpText)"
    }
    foreach ($requiredFlag in @('--bare', '--input-format', '--output-format')) {
        if (-not $helpText.Contains($requiredFlag)) {
            throw "ClaudeSeek hidden-launch preflight is missing $requiredFlag."
        }
    }
}

function Assert-HermesQueryFileTransport {
    param([Parameter(Mandatory)][string]$WorkingDirectory)

    $probe = Invoke-HiddenProcess `
        -FilePath $hermesExecutable `
        -ArgumentList @('chat', '--help') `
        -WorkingDirectory $WorkingDirectory `
        -TimeoutSeconds 30
    $helpText = $probe.stdout + $probe.stderr
    if ($probe.exitCode -ne 0 -or $probe.timedOut) {
        throw "Hermes query-file transport preflight failed: $(Get-LogExcerpt -Text $helpText)"
    }
    foreach ($requiredFlag in @('--query-file', '--query-sha256')) {
        if (-not $helpText.Contains($requiredFlag)) {
            throw "Hermes query-file transport preflight is missing $requiredFlag."
        }
    }
}

function Get-DeepSeekKey {
    $key = [Environment]::GetEnvironmentVariable('DEEPSEEK_API_KEY', 'Process')
    if ([string]::IsNullOrWhiteSpace($key)) {
        $key = [Environment]::GetEnvironmentVariable('DEEPSEEK_API_KEY', 'User')
    }
    if ([string]::IsNullOrWhiteSpace($key)) {
        throw 'DEEPSEEK_API_KEY is unavailable. The benchmark will not prompt for or print a key.'
    }
    $key
}

function Get-DeepSeekBalance {
    param([Parameter(Mandatory)][string]$ApiKey)

    $headers = @{ Authorization = "Bearer $ApiKey" }
    $response = Invoke-RestMethod -Method Get -Uri 'https://api.deepseek.com/user/balance' -Headers $headers -TimeoutSec 30
    $usd = @($response.balance_infos | Where-Object currency -eq 'USD' | Select-Object -First 1)
    if ($usd.Count -ne 1) {
        throw 'DeepSeek balance response did not contain exactly one USD balance.'
    }
    [pscustomobject]@{
        available = [bool]$response.is_available
        total = [decimal]$usd[0].total_balance
        granted = [decimal]$usd[0].granted_balance
        toppedUp = [decimal]$usd[0].topped_up_balance
        checkedAt = (Get-Date).ToString('o')
    }
}

function Get-DeepSeekModels {
    param([Parameter(Mandatory)][string]$ApiKey)
    $headers = @{ Authorization = "Bearer $ApiKey" }
    $response = Invoke-RestMethod -Method Get -Uri 'https://api.deepseek.com/models' -Headers $headers -TimeoutSec 30
    @($response.data | ForEach-Object id | Sort-Object)
}

function Get-PlanContext {
    param(
        [Parameter(Mandatory)][string]$Root,
        [switch]$RequireApproval
    )

    $planPath = Join-Path $Root 'plan.json'
    $receiptPath = Join-Path $Root 'plan-receipt.json'
    foreach ($required in @($planPath, $receiptPath)) {
        if (-not (Test-Path -LiteralPath $required -PathType Leaf)) {
            throw "Plan artifact is missing: $required"
        }
    }

    $planText = [System.IO.File]::ReadAllText($planPath)
    $planSha = Get-Sha256Text -Text $planText
    $plan = $planText | ConvertFrom-Json -Depth 100
    $receipt = Get-Content -LiteralPath $receiptPath -Raw | ConvertFrom-Json -Depth 30

    if ($receipt.planSha256 -ne $planSha) {
        throw 'Plan receipt hash does not match plan.json.'
    }
    if ((Get-Date) -ge ([datetimeoffset]$receipt.expiresAt).LocalDateTime) {
        throw "Plan approval window expired at $($receipt.expiresAt). Generate a fresh plan."
    }
    if ($RequireApproval) {
        if ($ApprovedPlanSha256 -ne $planSha) {
            throw 'ApprovedPlanSha256 does not exactly match the current plan.'
        }
        if ($ConfirmToken -cne $receipt.confirmToken) {
            throw 'ConfirmToken does not exactly match the current plan receipt.'
        }
    }

    [pscustomobject]@{
        plan = $plan
        planText = $planText
        planSha256 = $planSha
        receipt = $receipt
        planPath = $planPath
        receiptPath = $receiptPath
    }
}

function Assert-PlanInputs {
    param([Parameter(Mandatory)]$Plan)

    $currentValidation = & $packetValidator -SkillRoot $skillRoot -NoExit -PassThru
    if (-not $currentValidation.ok) {
        throw 'Packet validation failed after planning.'
    }
    foreach ($property in $Plan.fixture.hashes.PSObject.Properties) {
        $actual = [string]$currentValidation.assetHashes.($property.Name)
        if ($actual -ne [string]$property.Value) {
            throw "Fixture hash drift: $($property.Name)"
        }
    }

    $boundFiles = @(
        @{ path = $fuguAdapter; hash = $Plan.harnesses.fuguAdapterSha256 }
        @{ path = $claudeSeekFlash; hash = $Plan.harnesses.claudeSeekFlashSha256 }
        @{ path = $claudeSeekPro; hash = $Plan.harnesses.claudeSeekProSha256 }
        @{ path = $flashProfile; hash = $Plan.harnesses.flashProfileSha256 }
        @{ path = $proProfile; hash = $Plan.harnesses.proProfileSha256 }
        @{ path = $hermesExecutable; hash = $Plan.harnesses.hermesExecutableSha256 }
        @{ path = $hermesParser; hash = $Plan.harnesses.hermesParserSha256 }
        @{ path = $hermesMain; hash = $Plan.harnesses.hermesMainSha256 }
        @{ path = $hermesQueryInput; hash = $Plan.harnesses.hermesQueryInputSha256 }
        @{ path = $PSCommandPath; hash = $Plan.scripts.runnerSha256 }
        @{ path = $packetValidator; hash = $Plan.scripts.packetValidatorSha256 }
        @{ path = $artifactValidator; hash = $Plan.scripts.artifactValidatorSha256 }
    )
    foreach ($bound in $boundFiles) {
        if ((Get-Sha256File -Path $bound.path) -ne [string]$bound.hash) {
            throw "Bound launcher, profile or script drift: $($bound.path)"
        }
    }
    Assert-HiddenProcessEarlyExitCapture -WorkingDirectory ([string]$Plan.workspaceRoot)
    Assert-ClaudeSeekBareTransport -WorkingDirectory ([string]$Plan.workspaceRoot)
    Assert-HermesQueryFileTransport -WorkingDirectory ([string]$Plan.workspaceRoot)
}

function Render-CellTask {
    param(
        [Parameter(Mandatory)]$Cell,
        [Parameter(Mandatory)][string]$TargetRoot,
        [AllowEmptyString()][string]$Evidence = ''
    )

    $templatePath = if ([int]$Cell.pass -eq 1) { $pass1TemplatePath } else { $pass2TemplatePath }
    $text = [System.IO.File]::ReadAllText($templatePath)
    $text = $text.Replace('{{CELL_ID}}', [string]$Cell.id)
    $text = $text.Replace('{{TARGET_ROOT}}', $TargetRoot)
    $text = $text.Replace('{{HARNESS}}', [string]$Cell.harness)
    $text = $text.Replace('{{MODEL}}', [string]$Cell.model)
    $text = $text.Replace('{{CONDITION}}', [string]$Cell.condition)
    $text = $text.Replace('{{MAX_TURNS}}', '10')
    $text = $text.Replace('{{CHECK_EVIDENCE}}', $(if ($Evidence) { $Evidence } else { 'No prior evidence; this placeholder is valid only for a dry run.' }))
    $text
}

function Assert-PreparedPlanState {
    param(
        [Parameter(Mandatory)]$Plan,
        [Parameter(Mandatory)][string]$Root,
        [switch]$RequireStarterForUnstarted,
        [switch]$AllowTerminalFailures
    )

    $rootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd('\')
    $planRoot = [System.IO.Path]::GetFullPath([string]$Plan.workspaceRoot).TrimEnd('\')
    if ($planRoot -ne $rootFull) {
        throw "Plan workspace root does not match the requested workspace: $planRoot"
    }

    $dependencyRoot = [System.IO.Path]::GetFullPath([string]$Plan.starter.dependencyRoot).TrimEnd('\')
    $cellReceiptRoot = Join-Path $rootFull 'receipts\cells'
    $targetRoots = @(
        $Plan.cells |
            ForEach-Object { [string]$_.targetRoot } |
            Sort-Object -Unique
    )
    $targetSummaries = [System.Collections.Generic.List[object]]::new()

    foreach ($targetRootValue in $targetRoots) {
        $targetRoot = Assert-DescendantPath -Root $rootFull -Path $targetRootValue
        if (-not (Test-Path -LiteralPath $targetRoot -PathType Container)) {
            throw "Prepared target workspace is missing: $targetRoot"
        }

        $dependencyPath = Join-Path $targetRoot 'node_modules'
        if (-not (Test-Path -LiteralPath $dependencyPath -PathType Container)) {
            throw "Prepared target node_modules junction is missing: $dependencyPath"
        }
        $dependencyItem = Get-Item -LiteralPath $dependencyPath -Force
        if ($dependencyItem.LinkType -ne 'Junction') {
            throw "Prepared target node_modules is not a junction: $dependencyPath"
        }
        $linkTargets = @($dependencyItem.Target)
        $linkMatches = $false
        foreach ($linkTarget in $linkTargets) {
            if ([string]::IsNullOrWhiteSpace([string]$linkTarget)) { continue }
            $linkTargetFull = [System.IO.Path]::GetFullPath([string]$linkTarget).TrimEnd('\')
            if ($linkTargetFull -eq $dependencyRoot) {
                $linkMatches = $true
                break
            }
        }
        if (-not $linkMatches) {
            throw "Prepared target node_modules junction points to an unapproved dependency root: $dependencyPath"
        }

        $targetCells = @($Plan.cells | Where-Object { [string]$_.targetRoot -eq $targetRoot })
        $completedCellIds = [System.Collections.Generic.List[string]]::new()
        $terminalCellIds = [System.Collections.Generic.List[string]]::new()
        foreach ($targetCell in $targetCells) {
            $cellReceiptPath = Join-Path $cellReceiptRoot "$($targetCell.id).json"
            if (-not (Test-Path -LiteralPath $cellReceiptPath -PathType Leaf)) { continue }
            $cellReceipt = Get-Content -LiteralPath $cellReceiptPath -Raw | ConvertFrom-Json -Depth 50
            if ($cellReceipt.status -eq 'completed') {
                $completedCellIds.Add([string]$targetCell.id) | Out-Null
                $terminalCellIds.Add([string]$targetCell.id) | Out-Null
                continue
            }
            if ($AllowTerminalFailures -and $cellReceipt.status -eq 'failed') {
                $terminalCellIds.Add([string]$targetCell.id) | Out-Null
                continue
            }
            if ($cellReceipt.status -ne 'completed') {
                throw "A non-completed cell receipt cannot be resumed under this plan: $cellReceiptPath"
            }
        }

        $treeSha256 = Get-TreeSha256 -Root $targetRoot
        if ($RequireStarterForUnstarted -and $terminalCellIds.Count -eq 0 -and
            $treeSha256 -ne [string]$Plan.starter.treeSha256) {
            throw "Unstarted target differs from the approved starter: $targetRoot"
        }

        $targetSummaries.Add([ordered]@{
            targetRoot = $targetRoot
            treeSha256 = $treeSha256
            completedCellIds = @($completedCellIds)
            terminalCellIds = @($terminalCellIds)
            dependencyRoot = $dependencyRoot
        }) | Out-Null
    }

    $promptCount = 0
    foreach ($cell in @($Plan.cells | Where-Object { [int]$_.pass -eq 1 })) {
        $promptPath = Join-Path $rootFull "prompts\$($cell.id)-task.md"
        if (-not (Test-Path -LiteralPath $promptPath -PathType Leaf)) {
            throw "Prepared pass-1 prompt is missing: $promptPath"
        }
        $expectedPrompt = Render-CellTask -Cell $cell -TargetRoot ([string]$cell.targetRoot)
        $actualPrompt = [System.IO.File]::ReadAllText($promptPath)
        if ((Get-Sha256Text -Text $actualPrompt) -ne (Get-Sha256Text -Text $expectedPrompt)) {
            throw "Prepared pass-1 prompt differs from the approved fixture: $promptPath"
        }
        $promptCount++
    }

    [pscustomobject]@{
        targetCount = $targetSummaries.Count
        pass1PromptCount = $promptCount
        targets = @($targetSummaries)
    }
}

function Get-ConditionPath {
    param([Parameter(Mandatory)]$Cell)
    if ($Cell.condition -eq 'action-first') { $actionConditionPath } else { $standardConditionPath }
}

function New-HermesContextManifest {
    param(
        [Parameter(Mandatory)][string]$Root,
        [Parameter(Mandatory)]$Cell
    )

    $conditionPath = Get-ConditionPath -Cell $Cell
    $contextFiles = @(
        $specificationPath,
        $briefPath,
        $reasoningKernelPath,
        $conditionPath
    )
    foreach ($contextPath in $contextFiles) {
        if (-not (Test-Path -LiteralPath $contextPath -PathType Leaf)) {
            throw "Hermes context source is missing: $contextPath"
        }
    }

    $manifestPath = Join-Path $Root "prompts\$($Cell.id)-hermes-context.json"
    $manifest = [ordered]@{
        schemaVersion = '1.0.0'
        cellId = [string]$Cell.id
        contextFiles = @(
            foreach ($contextPath in $contextFiles) {
                [ordered]@{
                    path = $contextPath
                    sha256 = Get-Sha256File -Path $contextPath
                }
            }
        )
    }
    Write-JsonAtomic -Path $manifestPath -Value $manifest
    $manifestPath
}

function Build-ClaudeInput {
    param(
        [Parameter(Mandatory)]$Cell,
        [Parameter(Mandatory)][string]$TaskText
    )
    $conditionPath = Get-ConditionPath -Cell $Cell
    @(
        "SOURCE: implementation-spec.md`n$([System.IO.File]::ReadAllText($specificationPath))"
        "SOURCE: bmo-home-source-brief.json`n$([System.IO.File]::ReadAllText($briefPath))"
        "SOURCE: visible-reasoning-kernel.md`n$([System.IO.File]::ReadAllText($reasoningKernelPath))"
        "SOURCE: $([System.IO.Path]::GetFileName($conditionPath))`n$([System.IO.File]::ReadAllText($conditionPath))"
        "CURRENT TASK PACKET`n$TaskText"
    ) -join "`n`n---`n`n"
}

function Get-Pass2Evidence {
    param(
        [Parameter(Mandatory)][string]$Root,
        [Parameter(Mandatory)]$Cell
    )
    $dependency = [string]$Cell.dependsOn
    $receiptPath = Join-Path $Root "receipts\cells\$dependency.json"
    if (-not (Test-Path -LiteralPath $receiptPath -PathType Leaf)) {
        throw "Pass-2 dependency receipt is missing: $receiptPath"
    }
    $receipt = Get-Content -LiteralPath $receiptPath -Raw | ConvertFrom-Json -Depth 50
    $evidence = [ordered]@{
        producerCell = $dependency
        producerStatus = $receipt.status
        modelExitCode = $receipt.execution.exitCode
        modelTimedOut = $receipt.execution.timedOut
        checkExitCode = $receipt.verification.checkExitCode
        buildExitCode = $receipt.verification.buildExitCode
        artifactVerdict = $receipt.verification.artifactVerdict
        semanticCoveragePercent = $receipt.verification.semanticCoveragePercent
        checkExcerpt = $receipt.verification.checkExcerpt
        buildExcerpt = $receipt.verification.buildExcerpt
    }
    $text = $evidence | ConvertTo-Json -Depth 20
    if ($text.Length -gt 6000) {
        $text = $text.Substring(0, 6000) + "`n[bounded evidence truncated]"
    }
    $text
}

function Get-LogExcerpt {
    param(
        [AllowEmptyString()][string]$Text,
        [int]$MaximumCharacters = 1800
    )
    if ([string]::IsNullOrWhiteSpace($Text)) { return '' }
    $clean = [regex]::Replace($Text, "$([char]27)\[[0-9;?]*[ -/]*[@-~]", '')
    $clean = [regex]::Replace(
        $clean,
        '(?i)\b(authorization|api[_-]?key|access[_-]?token|refresh[_-]?token|password|secret)\s*[:=]\s*[^\s|]+',
        '$1=[REDACTED]'
    )
    if ($clean.Length -gt $MaximumCharacters) {
        return $clean.Substring($clean.Length - $MaximumCharacters)
    }
    $clean
}

function Invoke-DeterministicVerification {
    param(
        [Parameter(Mandatory)][string]$Root,
        [Parameter(Mandatory)]$Cell,
        [Parameter(Mandatory)][string]$HarnessLog
    )

    $logsRoot = Join-Path $Root 'logs'
    $evidenceRoot = Join-Path $Root 'evidence'
    [System.IO.Directory]::CreateDirectory($logsRoot) | Out-Null
    [System.IO.Directory]::CreateDirectory($evidenceRoot) | Out-Null
    $targetRoot = [string]$Cell.targetRoot
    $checkLogPath = Join-Path $logsRoot "$($Cell.id)-check.log"
    $buildLogPath = Join-Path $logsRoot "$($Cell.id)-build.log"
    $contractPath = Join-Path $evidenceRoot "$($Cell.id)-artifact.json"

    $commandProcessor = [Environment]::GetEnvironmentVariable('ComSpec')
    if ([string]::IsNullOrWhiteSpace($commandProcessor)) {
        $commandProcessor = 'C:\Windows\System32\cmd.exe'
    }
    $check = Invoke-HiddenProcess -FilePath $commandProcessor -ArgumentList @('/d', '/s', '/c', 'npm run check') -WorkingDirectory $targetRoot -TimeoutSeconds 300
    Write-Utf8TextAtomic -Path $checkLogPath -Text ($check.stdout + $check.stderr)
    $build = Invoke-HiddenProcess -FilePath $commandProcessor -ArgumentList @('/d', '/s', '/c', 'npm run build') -WorkingDirectory $targetRoot -TimeoutSeconds 300
    Write-Utf8TextAtomic -Path $buildLogPath -Text ($build.stdout + $build.stderr)

    $contract = & $artifactValidator `
        -ArtifactRoot $targetRoot `
        -CheckLog $checkLogPath `
        -HarnessLog $HarnessLog `
        -JsonOutputPath $contractPath `
        -MinimumSemanticCoverage 100 `
        -NoExit

    $coverageCheck = @($contract.checks | Where-Object name -eq 'required_literal_coverage' | Select-Object -First 1)
    $coveragePercent = if ($coverageCheck.Count -eq 1) { [double]$coverageCheck[0].data.percent } else { 0 }
    [pscustomobject]@{
        checkExitCode = $check.exitCode
        checkTimedOut = $check.timedOut
        buildExitCode = $build.exitCode
        buildTimedOut = $build.timedOut
        artifactVerdict = [string]$contract.verdict
        semanticCoveragePercent = $coveragePercent
        checkExcerpt = Get-LogExcerpt -Text ($check.stdout + $check.stderr)
        buildExcerpt = Get-LogExcerpt -Text ($build.stdout + $build.stderr)
        checkLog = $checkLogPath
        buildLog = $buildLogPath
        artifactReport = $contractPath
    }
}

function New-CellSnapshot {
    param(
        [Parameter(Mandatory)][string]$Root,
        [Parameter(Mandatory)]$Cell
    )
    $snapshotRoot = Join-Path $Root "snapshots\$($Cell.id)"
    Copy-BenchmarkTree -Source ([string]$Cell.targetRoot) -Destination $snapshotRoot
    $snapshotRoot
}

function Invoke-HermesCell {
    param(
        [Parameter(Mandatory)][string]$Root,
        [Parameter(Mandatory)]$Cell,
        [Parameter(Mandatory)][string]$TaskPath,
        [Parameter(Mandatory)][string]$PlanSha
    )

    $outputPath = Join-Path $Root "logs\$($Cell.id)-model-output.txt"
    $outerLogPath = Join-Path $Root "logs\$($Cell.id)-harness.log"
    $contextManifestPath = New-HermesContextManifest -Root $Root -Cell $Cell
    $pwsh = (Get-Command pwsh -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
    $arguments = @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-File', $fuguAdapter,
        '-Lane', [string]$Cell.lane,
        '-PromptFile', $TaskPath,
        '-ContextManifestFile', $contextManifestPath,
        '-PacketRoot', (Join-Path $Root 'receipts\fugu'),
        '-PacketId', "$($PlanSha.Substring(0,12))-$($Cell.id)",
        '-SourceSha256', $PlanSha,
        '-OutFile', $outputPath,
        '-Tag', 'bmo-benchmark-v2',
        '-GrantToolsets', 'file',
        '-NoSoul',
        '-NoFable',
        '-MaxTurns', '10',
        '-MaxPromptChars', '64000',
        '-TimeoutSec', '60',
        '-MaxRuntimeSec', '900'
    )
    $run = Invoke-HiddenProcess -FilePath $pwsh -ArgumentList $arguments -WorkingDirectory $Root -TimeoutSeconds 930
    $outerText = $run.stdout + $run.stderr
    Write-Utf8TextAtomic -Path $outerLogPath -Text $outerText
    [pscustomobject]@{
        exitCode = $run.exitCode
        timedOut = $run.timedOut
        durationSeconds = $run.durationSeconds
        harnessLog = $outerLogPath
        outputLog = $outputPath
        error = Get-LogExcerpt -Text $run.stderr
    }
}

function Invoke-ClaudeSeekCell {
    param(
        [Parameter(Mandatory)][string]$Root,
        [Parameter(Mandatory)]$Cell,
        [Parameter(Mandatory)][string]$InputText
    )

    $launcher = if ($Cell.model -eq 'deepseek-v4-pro') { $claudeSeekPro } else { $claudeSeekFlash }
    $pwsh = (Get-Command pwsh -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
    $budget = ([double]$Cell.claudeHarnessBudgetUsd).ToString('0.00', [Globalization.CultureInfo]::InvariantCulture)
    $claudeArguments = @(
        '-p',
        '--input-format', 'text',
        '--output-format', 'stream-json',
        '--verbose',
        '--bare',
        '--safe-mode',
        '--disable-slash-commands',
        '--no-session-persistence',
        '--tools', 'Read,Write,Edit,Glob,Grep',
        '--permission-mode', 'bypassPermissions',
        '--dangerously-skip-permissions',
        '--max-budget-usd', $budget,
        '--name', "BMO v2 $($Cell.id)"
    )
    $claudeArgumentsJson = ConvertTo-Json -InputObject ([object[]]$claudeArguments) -Compress
    $arguments = @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-File', $launcher,
        '-Project', [string]$Cell.targetRoot,
        '-Effort', 'max',
        '-AgentBudget', '0',
        '-NoSave',
        '-ClaudeArgsJson', $claudeArgumentsJson
    )
    $run = Invoke-HiddenProcess -FilePath $pwsh -ArgumentList $arguments -WorkingDirectory ([string]$Cell.targetRoot) -StandardInput $InputText -TimeoutSeconds 900
    $streamPath = Join-Path $Root "logs\$($Cell.id)-stream.jsonl"
    $stderrPath = Join-Path $Root "logs\$($Cell.id)-stderr.log"
    Write-Utf8TextAtomic -Path $streamPath -Text $run.stdout
    Write-Utf8TextAtomic -Path $stderrPath -Text $run.stderr
    [pscustomobject]@{
        exitCode = $run.exitCode
        timedOut = $run.timedOut
        durationSeconds = $run.durationSeconds
        harnessLog = $streamPath
        outputLog = $streamPath
        stderrLog = $stderrPath
        stdinWriteError = $run.stdinWriteError
        error = Get-LogExcerpt -Text $run.stderr
    }
}

$resolvedWorkspace = Assert-SafeWorkspaceRoot -Path $WorkspaceRoot

if ($Action -eq 'Validate') {
    & $packetValidator -SkillRoot $skillRoot -Json:$Json
    exit $(if ($?) { 0 } else { 2 })
}

if ($Action -eq 'Plan') {
    $validation = & $packetValidator -SkillRoot $skillRoot -NoExit -PassThru
    if (-not $validation.ok) {
        throw 'Cannot create a plan because packet validation failed.'
    }

    $requiredFiles = @(
        $fuguAdapter,
        $claudeSeekFlash,
        $claudeSeekPro,
        $flashProfile,
        $proProfile,
        $hermesExecutable,
        $hermesParser,
        $hermesMain,
        $hermesQueryInput,
        $packetValidator,
        $artifactValidator
    )
    foreach ($required in $requiredFiles) {
        if (-not (Test-Path -LiteralPath $required -PathType Leaf)) {
            throw "Required harness file is missing: $required"
        }
    }
    if (-not (Test-Path -LiteralPath $DependencyRoot -PathType Container)) {
        throw "DependencyRoot is missing. Prepare dependencies locally and pass the exact node_modules path: $DependencyRoot"
    }
    Assert-HiddenProcessEarlyExitCapture -WorkingDirectory $fixtureRoot
    Assert-ClaudeSeekBareTransport -WorkingDirectory $fixtureRoot
    Assert-HermesQueryFileTransport -WorkingDirectory $fixtureRoot

    $dependencyFull = [System.IO.Path]::GetFullPath($DependencyRoot).TrimEnd('\')
    $dependencyLock = Join-Path (Split-Path -Parent $dependencyFull) 'package-lock.json'
    if (-not (Test-Path -LiteralPath $dependencyLock -PathType Leaf)) {
        throw "Dependency package-lock.json is missing beside DependencyRoot: $dependencyLock"
    }
    $starterLockHash = Get-Sha256File -Path (Join-Path $starterRoot 'package-lock.json')
    if ((Get-Sha256File -Path $dependencyLock) -ne $starterLockHash) {
        throw 'DependencyRoot package-lock hash does not match the benchmark starter.'
    }

    $matrix = Get-Content -LiteralPath $matrixPath -Raw | ConvertFrom-Json -Depth 100
    $targetRows = [System.Collections.Generic.List[object]]::new()
    foreach ($cell in $matrix.cells) {
        $targetRoot = Assert-DescendantPath -Root $resolvedWorkspace -Path (Join-Path $resolvedWorkspace "workspaces\$($cell.targetKey)")
        $targetRows.Add([ordered]@{
            id = [string]$cell.id
            wave = [int]$cell.wave
            block = [string]$cell.block
            harness = [string]$cell.harness
            condition = [string]$cell.condition
            pass = [int]$cell.pass
            model = [string]$cell.model
            lane = if ($null -ne $cell.PSObject.Properties['lane']) { [string]$cell.lane } else { '' }
            launcher = if ($null -ne $cell.PSObject.Properties['launcher']) { [string]$cell.launcher } else { '' }
            targetKey = [string]$cell.targetKey
            targetRoot = $targetRoot
            dependsOn = if ($null -ne $cell.PSObject.Properties['dependsOn']) { [string]$cell.dependsOn } else { '' }
            maxTurns = [int]$matrix.design.maxTurnsPerCell
            maxRuntimeSeconds = [int]$matrix.design.maxRuntimeSecondsPerCell
            claudeHarnessBudgetUsd = [double]$matrix.design.claudeHarnessBudgetUsdPerCell
        }) | Out-Null
    }

    $plan = [ordered]@{
        schemaVersion = '2.0.0'
        benchmarkId = [string]$matrix.benchmarkId
        objective = [string]$matrix.objective
        workspaceRoot = $resolvedWorkspace
        fixture = [ordered]@{
            root = $fixtureRoot
            hashes = $validation.assetHashes
            sourceUrl = 'https://www.bmo.com/en-ca/main/personal/'
            rawSourceIncluded = $false
        }
        starter = [ordered]@{
            root = $starterRoot
            treeSha256 = [string]$validation.assetHashes.starter_tree
            dependencyRoot = $dependencyFull
            packageLockSha256 = $starterLockHash
        }
        harnesses = [ordered]@{
            fuguAdapter = $fuguAdapter
            fuguAdapterSha256 = Get-Sha256File -Path $fuguAdapter
            claudeSeekFlash = $claudeSeekFlash
            claudeSeekFlashSha256 = Get-Sha256File -Path $claudeSeekFlash
            claudeSeekPro = $claudeSeekPro
            claudeSeekProSha256 = Get-Sha256File -Path $claudeSeekPro
            flashProfile = $flashProfile
            flashProfileSha256 = Get-Sha256File -Path $flashProfile
            proProfile = $proProfile
            proProfileSha256 = Get-Sha256File -Path $proProfile
            hermesExecutable = $hermesExecutable
            hermesExecutableSha256 = Get-Sha256File -Path $hermesExecutable
            hermesParser = $hermesParser
            hermesParserSha256 = Get-Sha256File -Path $hermesParser
            hermesMain = $hermesMain
            hermesMainSha256 = Get-Sha256File -Path $hermesMain
            hermesQueryInput = $hermesQueryInput
            hermesQueryInputSha256 = Get-Sha256File -Path $hermesQueryInput
            queryTransport = 'hashed-utf8-file'
            hermesToolsets = 'file'
            claudeTools = @('Read', 'Write', 'Edit', 'Glob', 'Grep')
            childDelegation = $false
            backgroundAgents = $false
            hermesSoulInjection = $false
            hermesResearchFablePacket = $false
            commonVisibleReasoningKernel = $reasoningKernelPath
            visibleWindows = $false
        }
        scripts = [ordered]@{
            runner = $PSCommandPath
            runnerSha256 = Get-Sha256File -Path $PSCommandPath
            packetValidator = $packetValidator
            packetValidatorSha256 = Get-Sha256File -Path $packetValidator
            artifactValidator = $artifactValidator
            artifactValidatorSha256 = Get-Sha256File -Path $artifactValidator
        }
        execution = $matrix.design
        waves = $matrix.waves
        cells = $targetRows
        ratesUsdPerMillionTokens = $matrix.ratesUsdPerMillionTokens
        egress = $matrix.egress
        writableScope = @(
            (Join-Path $resolvedWorkspace 'workspaces'),
            (Join-Path $resolvedWorkspace 'prompts'),
            (Join-Path $resolvedWorkspace 'logs'),
            (Join-Path $resolvedWorkspace 'evidence'),
            (Join-Path $resolvedWorkspace 'receipts'),
            (Join-Path $resolvedWorkspace 'snapshots'),
            (Join-Path $resolvedWorkspace 'results')
        )
        stopConditions = $matrix.stopConditions
        retryPolicy = 'No automatic retries and no model, provider, harness or tool substitution.'
    }

    $planText = ($plan | ConvertTo-Json -Depth 100) + "`n"
    $planSha = Get-Sha256Text -Text $planText
    $confirmTokenValue = "RUN-BMO16-$($planSha.Substring(0,12))"
    [System.IO.Directory]::CreateDirectory($resolvedWorkspace) | Out-Null
    $planPath = Join-Path $resolvedWorkspace 'plan.json'
    $planReceiptPath = Join-Path $resolvedWorkspace 'plan-receipt.json'
    if (Test-Path -LiteralPath $planReceiptPath -PathType Leaf) {
        throw "A plan receipt already exists in WorkspaceRoot. Choose a fresh WorkspaceRoot: $planReceiptPath"
    }
    if (Test-Path -LiteralPath $planPath -PathType Leaf) {
        $existingHash = Get-Sha256Text -Text ([System.IO.File]::ReadAllText($planPath))
        if ($existingHash -ne $planSha) {
            throw 'A different plan already exists in WorkspaceRoot. Choose a fresh WorkspaceRoot.'
        }
    }
    else {
        Write-Utf8TextAtomic -Path $planPath -Text $planText
    }

    foreach ($directory in @('workspaces', 'prompts', 'logs', 'evidence', 'receipts\cells', 'receipts\fugu', 'snapshots', 'results')) {
        [System.IO.Directory]::CreateDirectory((Join-Path $resolvedWorkspace $directory)) | Out-Null
    }
    $uniqueTargetRoots = @(
        $targetRows |
            ForEach-Object { [string]$_.targetRoot } |
            Sort-Object -Unique
    )
    foreach ($targetRoot in $uniqueTargetRoots) {
        if (-not (Test-Path -LiteralPath $targetRoot -PathType Container)) {
            $stagingRoot = Assert-DescendantPath -Root $resolvedWorkspace -Path (
                "$targetRoot.preparing.$PID.$([Guid]::NewGuid().ToString('N'))"
            )
            try {
                Copy-BenchmarkTree -Source $starterRoot -Destination $stagingRoot
                New-Item -ItemType Junction -Path (Join-Path $stagingRoot 'node_modules') -Target $dependencyFull | Out-Null
                if ((Get-TreeSha256 -Root $stagingRoot) -ne [string]$validation.assetHashes.starter_tree) {
                    throw "Staged target differs from the starter: $targetRoot"
                }
                [System.IO.Directory]::Move($stagingRoot, $targetRoot)
            }
            finally {
                if (Test-Path -LiteralPath $stagingRoot -PathType Container) {
                    Remove-Item -LiteralPath $stagingRoot -Recurse -Force
                }
            }
        }
        if ((Get-TreeSha256 -Root $targetRoot) -ne [string]$validation.assetHashes.starter_tree) {
            throw "Prepared target differs from the starter: $targetRoot"
        }
    }

    foreach ($cell in $targetRows) {
        if ([int]$cell.pass -eq 1) {
            $task = Render-CellTask -Cell ([pscustomobject]$cell) -TargetRoot ([string]$cell.targetRoot)
            Write-Utf8TextAtomic -Path (Join-Path $resolvedWorkspace "prompts\$($cell.id)-task.md") -Text $task
        }
    }

    $preparation = Assert-PreparedPlanState -Plan ([pscustomobject]$plan) -Root $resolvedWorkspace -RequireStarterForUnstarted
    $receipt = [ordered]@{
        schemaVersion = '1.1.0'
        status = 'planned-awaiting-approval'
        createdAt = (Get-Date).ToString('o')
        expiresAt = (Get-Date).AddHours($PlanTtlHours).ToString('o')
        planSha256 = $planSha
        confirmToken = $confirmTokenValue
        paidCallsMade = 0
        preparation = [ordered]@{
            status = 'complete'
            targetCount = $preparation.targetCount
            pass1PromptCount = $preparation.pass1PromptCount
            starterTreeSha256 = [string]$validation.assetHashes.starter_tree
            dependencyRoot = $dependencyFull
        }
        instructions = "Run requires both -ApprovedPlanSha256 '$planSha' and -ConfirmToken '$confirmTokenValue'."
    }
    Write-JsonAtomic -Path $planReceiptPath -Value $receipt

    $summary = [ordered]@{
        status = 'planned-awaiting-approval'
        workspaceRoot = $resolvedWorkspace
        planPath = $planPath
        planSha256 = $planSha
        confirmToken = $confirmTokenValue
        expiresAt = $receipt.expiresAt
        calls = 16
        waves = 4
        flashCalls = 12
        proCalls = 4
        providerSpendExpectedUsd = $matrix.design.providerSpendExpectedUsd
        providerSpendStopUsd = $matrix.design.providerSpendStopUsd
        claudeHarnessBudgetUsdPerCell = $matrix.design.claudeHarnessBudgetUsdPerCell
        paidCallsMade = 0
        preparedTargets = $preparation.targetCount
        preparedPass1Prompts = $preparation.pass1PromptCount
    }
    if ($Json) { $summary | ConvertTo-Json -Depth 20 } else { $summary | Format-List | Out-String | Write-Output }
    exit 0
}

$planContext = Get-PlanContext -Root $resolvedWorkspace -RequireApproval:($Action -eq 'Run')
$plan = $planContext.plan
Assert-PlanInputs -Plan $plan
$preparedState = $null
if ($Action -in @('DryRun', 'Run')) {
    $preparedState = Assert-PreparedPlanState `
        -Plan $plan `
        -Root $resolvedWorkspace `
        -RequireStarterForUnstarted `
        -AllowTerminalFailures:$ContinueAfterFailedCell
}

if ($Action -eq 'DryRun') {
    $entries = [System.Collections.Generic.List[object]]::new()
    foreach ($cell in $plan.cells | Sort-Object wave, id) {
        $task = Render-CellTask -Cell $cell -TargetRoot ([string]$cell.targetRoot) -Evidence 'DRY RUN: pass-2 evidence is deterministically derived from the dependency receipt.'
        $taskPath = Join-Path $resolvedWorkspace "prompts\$($cell.id)-dry-run-task.md"
        Write-Utf8TextAtomic -Path $taskPath -Text $task
        if ($cell.harness -eq 'hermes') {
            $contextManifestPath = New-HermesContextManifest -Root $resolvedWorkspace -Cell $cell
            $pwsh = (Get-Command pwsh -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
            $arguments = @(
                '-NoProfile',
                '-ExecutionPolicy', 'Bypass',
                '-File', $fuguAdapter,
                '-Lane', [string]$cell.lane,
                '-PromptFile', $taskPath,
                '-ContextManifestFile', $contextManifestPath,
                '-SourceSha256', $planContext.planSha256,
                '-Tag', 'bmo-benchmark-v2',
                '-GrantToolsets', 'file',
                '-NoSoul',
                '-NoFable',
                '-MaxTurns', '10',
                '-MaxPromptChars', '64000',
                '-TimeoutSec', '60',
                '-MaxRuntimeSec', '900',
                '-NoPacket',
                '-DryRun'
            )
            $run = Invoke-HiddenProcess -FilePath $pwsh -ArgumentList $arguments -WorkingDirectory $resolvedWorkspace -TimeoutSeconds 90
            if ($run.exitCode -ne 0) {
                throw "Hermes dry-run validation failed for $($cell.id): $(Get-LogExcerpt -Text $run.stderr)"
            }
            $preview = $run.stdout + $run.stderr
            $previewHash = Get-Sha256Text -Text $preview
            $boundedPreview = [regex]::Replace(
                $preview,
                '(?i)(--query-file\s+)(?:"[^"]*"|\S+)',
                '$1"<validated-query-file>"'
            )
            if ($boundedPreview.Length -gt 1500) {
                $boundedPreview = $boundedPreview.Substring(0, 1500) + ' [truncated]'
            }
            $entries.Add([ordered]@{
                id = $cell.id
                harness = $cell.harness
                model = $cell.model
                route = $cell.lane
                hiddenProcess = $true
                previewSha256 = $previewHash
                previewCharacters = $preview.Length
                preview = $boundedPreview.Trim()
            }) | Out-Null
        }
        else {
            $input = Build-ClaudeInput -Cell $cell -TaskText $task
            if ($input.Length -gt 64000) {
                throw "ClaudeSeek dry-run packet exceeds 64000 characters for $($cell.id): $($input.Length)"
            }
            $entries.Add([ordered]@{
                id = $cell.id
                harness = $cell.harness
                model = $cell.model
                route = $cell.launcher
                hiddenProcess = $true
                createNoWindow = $true
                windowStyle = 'Hidden'
                toolAllowlist = @('Read', 'Write', 'Edit', 'Glob', 'Grep')
                backgroundAgents = $false
                packetCharacters = $input.Length
            }) | Out-Null
        }
    }
    $dryRun = [ordered]@{
        schemaVersion = '1.0.0'
        status = 'dry-run-only'
        checkedAt = (Get-Date).ToString('o')
        planSha256 = $planContext.planSha256
        remoteCallsMade = 0
        preparedTargets = $preparedState.targetCount
        preparedPass1Prompts = $preparedState.pass1PromptCount
        entries = $entries
    }
    Write-JsonAtomic -Path (Join-Path $resolvedWorkspace 'dry-run.json') -Value $dryRun
    if ($Json) { $dryRun | ConvertTo-Json -Depth 40 } else { $entries | Format-Table id,harness,model,route,hiddenProcess -AutoSize | Out-String | Write-Output }
    exit 0
}

if ($Action -eq 'Run') {
    $existingCellReceipts = @(
        Get-ChildItem -LiteralPath (Join-Path $resolvedWorkspace 'receipts\cells') -Filter '*.json' -File -ErrorAction SilentlyContinue
    )
    if ($existingCellReceipts.Count -gt 0 -and -not $Resume) {
        throw 'Completed cell receipts already exist. Use a fresh plan, or use -Resume only for a cleanly interrupted run.'
    }
    $terminalReceiptRows = @(
        $existingCellReceipts |
            ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw | ConvertFrom-Json -Depth 50 }
    )
    $completedReceiptRows = @($terminalReceiptRows | Where-Object status -eq 'completed')
    $failedReceiptRows = @($terminalReceiptRows | Where-Object status -eq 'failed')
    $completedBefore = $completedReceiptRows.Count
    $failedBefore = $failedReceiptRows.Count
    $priorAccountDelta = [decimal]0
    foreach ($completedReceipt in $terminalReceiptRows) {
        if (
            $null -ne $completedReceipt.PSObject.Properties['cost'] -and
            $null -ne $completedReceipt.cost.PSObject.Properties['accountDeltaUsd']
        ) {
            $recordedDelta = [decimal]$completedReceipt.cost.accountDeltaUsd
            if ($recordedDelta -gt 0) {
                $priorAccountDelta += $recordedDelta
            }
        }
    }

    $runReceiptPath = Join-Path $resolvedWorkspace 'run-receipt.json'
    $runReceipt = [ordered]@{
        schemaVersion = '1.1.0'
        status = 'preflight'
        startedAt = (Get-Date).ToString('o')
        finishedAt = ''
        planSha256 = $planContext.planSha256
        providerModels = @()
        initialBalanceUsd = $null
        finalBalanceUsd = $null
        accountDeltaUsd = $null
        priorAccountDeltaUsd = $priorAccountDelta
        spendStopUsd = [decimal]$plan.execution.providerSpendStopUsd
        cellsCompleted = $completedBefore
        cellsFailed = $failedBefore
        currentCell = ''
        error = ''
    }
    Write-JsonAtomic -Path $runReceiptPath -Value $runReceipt

    try {
        $apiKey = Get-DeepSeekKey
        $models = Get-DeepSeekModels -ApiKey $apiKey
        foreach ($requiredModel in @('deepseek-v4-flash', 'deepseek-v4-pro')) {
            if ($requiredModel -notin $models) {
                throw "Required provider model is unavailable: $requiredModel"
            }
        }

        $initialBalance = Get-DeepSeekBalance -ApiKey $apiKey
        if (-not $initialBalance.available) {
            throw 'DeepSeek reports that the account balance is unavailable.'
        }
        $remainingApprovedSpend = [decimal]$plan.execution.providerSpendStopUsd - $priorAccountDelta
        if ($remainingApprovedSpend -le 0) {
            throw "Provider spend stop was already reached by preserved cells: $priorAccountDelta USD"
        }
        if ($initialBalance.total -lt $remainingApprovedSpend) {
            throw "Available balance is below the remaining approved campaign spend: $($initialBalance.total)"
        }

        $runReceipt.status = 'running'
        $runReceipt.providerModels = $models
        $runReceipt.initialBalanceUsd = $initialBalance.total
        Write-JsonAtomic -Path $runReceiptPath -Value $runReceipt

        foreach ($wave in $plan.waves | Sort-Object wave) {
            foreach ($cellId in $wave.cells) {
                $cell = @($plan.cells | Where-Object id -eq $cellId)[0]
                $cellReceiptPath = Join-Path $resolvedWorkspace "receipts\cells\$cellId.json"
                if (Test-Path -LiteralPath $cellReceiptPath -PathType Leaf) {
                    $existing = Get-Content -LiteralPath $cellReceiptPath -Raw | ConvertFrom-Json -Depth 50
                    if ($Resume -and $existing.status -eq 'completed') {
                        continue
                    }
                    if ($Resume -and $ContinueAfterFailedCell -and $existing.status -eq 'failed') {
                        continue
                    }
                    throw "Cell receipt already exists. Use -Resume only to skip completed cells: $cellReceiptPath"
                }

                if ($cell.dependsOn) {
                    $dependencyReceiptPath = Join-Path $resolvedWorkspace "receipts\cells\$($cell.dependsOn).json"
                    if (-not (Test-Path -LiteralPath $dependencyReceiptPath -PathType Leaf)) {
                        throw "Dependency is incomplete for ${cellId}: $($cell.dependsOn)"
                    }
                    $dependencyReceipt = Get-Content -LiteralPath $dependencyReceiptPath -Raw | ConvertFrom-Json -Depth 50
                    if ($dependencyReceipt.status -ne 'completed') {
                        throw "Dependency did not complete successfully for ${cellId}: $($cell.dependsOn)"
                    }
                }

                $beforeBalance = Get-DeepSeekBalance -ApiKey $apiKey
                $spentBefore = $priorAccountDelta + ($initialBalance.total - $beforeBalance.total)
                if ($spentBefore -ge [decimal]$plan.execution.providerSpendStopUsd) {
                    throw "Provider spend stop reached before ${cellId}: $spentBefore USD"
                }

                $evidence = if ([int]$cell.pass -eq 2) {
                    Get-Pass2Evidence -Root $resolvedWorkspace -Cell $cell
                } else {
                    ''
                }
                $taskText = Render-CellTask -Cell $cell -TargetRoot ([string]$cell.targetRoot) -Evidence $evidence
                $taskPath = Join-Path $resolvedWorkspace "prompts\$cellId-task.md"
                Write-Utf8TextAtomic -Path $taskPath -Text $taskText

                $runReceipt.currentCell = $cellId
                Write-JsonAtomic -Path $runReceiptPath -Value $runReceipt
                if ($cell.harness -eq 'hermes') {
                    $modelRun = Invoke-HermesCell -Root $resolvedWorkspace -Cell $cell -TaskPath $taskPath -PlanSha $planContext.planSha256
                }
                else {
                    $input = Build-ClaudeInput -Cell $cell -TaskText $taskText
                    if ($input.Length -gt 64000) {
                        throw "ClaudeSeek packet exceeds 64000 characters for ${cellId}: $($input.Length)"
                    }
                    $modelRun = Invoke-ClaudeSeekCell -Root $resolvedWorkspace -Cell $cell -InputText $input
                }

                $afterBalance = Get-DeepSeekBalance -ApiKey $apiKey
                $cellSpend = $beforeBalance.total - $afterBalance.total
                $campaignSpend = $priorAccountDelta + ($initialBalance.total - $afterBalance.total)
                $snapshot = New-CellSnapshot -Root $resolvedWorkspace -Cell $cell
                $verification = Invoke-DeterministicVerification -Root $resolvedWorkspace -Cell $cell -HarnessLog $modelRun.harnessLog
                $cellReceipt = [ordered]@{
                    schemaVersion = '1.0.0'
                    id = $cellId
                    status = if ($modelRun.exitCode -eq 0 -and -not $modelRun.timedOut) { 'completed' } else { 'failed' }
                    finishedAt = (Get-Date).ToString('o')
                    planSha256 = $planContext.planSha256
                    wave = $cell.wave
                    harness = $cell.harness
                    model = $cell.model
                    condition = $cell.condition
                    pass = $cell.pass
                    targetRoot = $cell.targetRoot
                    promptSha256 = Get-Sha256File -Path $taskPath
                    execution = [ordered]@{
                        route = if ($cell.harness -eq 'hermes') { $cell.lane } else { $cell.launcher }
                        exitCode = $modelRun.exitCode
                        timedOut = $modelRun.timedOut
                        durationSeconds = $modelRun.durationSeconds
                        harnessLog = $modelRun.harnessLog
                        outputLog = $modelRun.outputLog
                        error = $modelRun.error
                    }
                    cost = [ordered]@{
                        balanceBeforeUsd = $beforeBalance.total
                        balanceAfterUsd = $afterBalance.total
                        accountDeltaUsd = $cellSpend
                        campaignDeltaUsd = $campaignSpend
                        note = 'Account-balance delta can include concurrent DeepSeek usage outside this benchmark.'
                    }
                    verification = $verification
                    snapshot = $snapshot
                }
                Write-JsonAtomic -Path $cellReceiptPath -Value $cellReceipt

                if ($cellReceipt.status -ne 'completed') {
                    $runReceipt.status = 'stopped-cell-failure'
                    $runReceipt.currentCell = $cellId
                    Write-JsonAtomic -Path $runReceiptPath -Value $runReceipt
                    throw "Cell $cellId failed. No retry or substitution was attempted."
                }
                $runReceipt.cellsCompleted = [int]$runReceipt.cellsCompleted + 1
                $runReceipt.currentCell = ''
                Write-JsonAtomic -Path $runReceiptPath -Value $runReceipt

                if ($campaignSpend -ge [decimal]$plan.execution.providerSpendStopUsd) {
                    $runReceipt.status = 'stopped-spend-threshold'
                    Write-JsonAtomic -Path $runReceiptPath -Value $runReceipt
                    throw "Provider spend stop reached after ${cellId}: $campaignSpend USD"
                }
            }
        }

        $finalBalance = Get-DeepSeekBalance -ApiKey $apiKey
        $runReceipt.status = if ($failedBefore -gt 0) { 'completed-with-cell-failures' } else { 'completed' }
        $runReceipt.finishedAt = (Get-Date).ToString('o')
        $runReceipt.finalBalanceUsd = $finalBalance.total
        $runReceipt.accountDeltaUsd = $priorAccountDelta + ($initialBalance.total - $finalBalance.total)
        Write-JsonAtomic -Path $runReceiptPath -Value $runReceipt
        if ($Json) { $runReceipt | ConvertTo-Json -Depth 20 } else { $runReceipt | Format-List | Out-String | Write-Output }
        exit 0
    }
    catch {
        if ($runReceipt.status -notin @('stopped-cell-failure', 'stopped-spend-threshold')) {
            $runReceipt.status = if ($runReceipt.currentCell) {
                'stopped-infrastructure-failure'
            } else {
                'stopped-preflight-failure'
            }
        }
        $runReceipt.finishedAt = (Get-Date).ToString('o')
        $runReceipt.error = Get-LogExcerpt -Text $_.Exception.Message
        Write-JsonAtomic -Path $runReceiptPath -Value $runReceipt
        throw
    }
}

if ($Action -eq 'Score') {
    $receiptFiles = @(Get-ChildItem -LiteralPath (Join-Path $resolvedWorkspace 'receipts\cells') -Filter '*.json' -File | Sort-Object Name)
    $cells = @($receiptFiles | ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw | ConvertFrom-Json -Depth 50 })
    $expectedCells = @($plan.cells).Count
    $completed = @($cells | Where-Object status -eq 'completed')
    $checkPasses = @($cells | Where-Object { $_.verification.checkExitCode -eq 0 }).Count
    $buildPasses = @($cells | Where-Object { $_.verification.buildExitCode -eq 0 }).Count
    $contractPasses = @($cells | Where-Object { $_.verification.artifactVerdict -eq 'PASS' }).Count
    $spendValues = @($cells | ForEach-Object { [decimal]$_.cost.accountDeltaUsd })
    $spend = [decimal](($spendValues | Measure-Object -Sum).Sum)

    $results = [ordered]@{
        schemaVersion = '1.0.0'
        benchmarkId = $plan.benchmarkId
        scoredAt = (Get-Date).ToString('o')
        planSha256 = $planContext.planSha256
        status = if ($completed.Count -eq $expectedCells) { 'complete' } else { 'partial' }
        expectedCells = $expectedCells
        completedCells = $completed.Count
        checkPasses = $checkPasses
        buildPasses = $buildPasses
        artifactContractPasses = $contractPasses
        accountDeltaSumUsd = $spend
        costCaveat = 'Summed account deltas can include concurrent DeepSeek usage.'
        cells = $cells
    }
    $resultsPath = Join-Path $resolvedWorkspace 'results\matrix-results.json'
    Write-JsonAtomic -Path $resultsPath -Value $results

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('# BMO agent benchmark v2 results') | Out-Null
    $lines.Add('') | Out-Null
    $lines.Add(('- Plan: `{0}`' -f $planContext.planSha256)) | Out-Null
    $lines.Add("- Status: $($results.status)") | Out-Null
    $lines.Add("- Completed: $($completed.Count)/$expectedCells") | Out-Null
    $lines.Add("- Check passes: $checkPasses/$($cells.Count)") | Out-Null
    $lines.Add("- Build passes: $buildPasses/$($cells.Count)") | Out-Null
    $lines.Add("- Artifact-contract passes: $contractPasses/$($cells.Count)") | Out-Null
    $lines.Add(('- Summed account delta: `${0}` USD' -f $spend)) | Out-Null
    $lines.Add('') | Out-Null
    $lines.Add('| Cell | Harness | Model | Condition | Pass | Check | Build | Contract | Coverage | USD |') | Out-Null
    $lines.Add('| --- | --- | --- | --- | ---: | ---: | ---: | --- | ---: | ---: |') | Out-Null
    foreach ($cell in $cells | Sort-Object wave,id) {
        $lines.Add("| $($cell.id) | $($cell.harness) | $($cell.model) | $($cell.condition) | $($cell.pass) | $($cell.verification.checkExitCode) | $($cell.verification.buildExitCode) | $($cell.verification.artifactVerdict) | $($cell.verification.semanticCoveragePercent)% | $($cell.cost.accountDeltaUsd) |") | Out-Null
    }
    Write-Utf8TextAtomic -Path (Join-Path $resolvedWorkspace 'results\MATRIX.md') -Text (($lines -join "`n") + "`n")
    if ($Json) { $results | ConvertTo-Json -Depth 100 } else { $lines -join "`n" }
    exit 0
}

throw "Unsupported action: $Action"
