param(
  [string]$AiWikiRoot = "<AI_WIKI_ROOT>",
  [string]$RepoRoot = "<DEV_ROOT>\PixelBoats",
  [string]$ProjectSlug = "pixelboats",
  [string]$Goal = "P0 stabilization, adaptive audio, repo modularization, WebGL performance, and image-to-UI workflow",
  [string]$TargetAgent = "GPT-5.5 Web for reasoning, Trae/Codex/Hermes for repo execution",
  [int]$MaxCandidateSkills = 24,
  [switch]$Interactive,
  [switch]$OpenReport
)

$ErrorActionPreference = "Stop"

function Read-Default {
  param(
    [string]$Label,
    [string]$Default
  )

  $Value = Read-Host ("{0} [{1}]" -f $Label, $Default)
  if ([string]::IsNullOrWhiteSpace($Value)) {
    return $Default
  }
  return $Value
}

function Write-Utf8NoBomLf {
  param(
    [string]$Path,
    [string]$Text
  )

  $Parent = Split-Path -Parent $Path
  if ($Parent) {
    New-Item -ItemType Directory -Path $Parent -Force | Out-Null
  }

  $Lf = ($Text -replace "`r`n", "`n") -replace "`r", "`n"
  $Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Lf, $Utf8NoBom)
}

function Read-TextFile {
  param([string]$Path)

  if (-not (Test-Path -LiteralPath $Path)) {
    return ""
  }

  $Text = Get-Content -LiteralPath $Path -Raw -ErrorAction Stop
  if ($null -eq $Text) {
    return ""
  }

  return (($Text.TrimStart([char]0xFEFF) -replace "`r`n", "`n") -replace "`r", "`n")
}

function Read-JsonFile {
  param([string]$Path)

  if (-not (Test-Path -LiteralPath $Path)) {
    return $null
  }

  return Get-Content -LiteralPath $Path -Raw -ErrorAction Stop | ConvertFrom-Json
}

function Test-HasFile {
  param([string]$RelativePath)
  return Test-Path -LiteralPath (Join-Path $RepoRoot $RelativePath)
}

function Add-Line {
  param(
    [System.Collections.Generic.List[string]]$Lines,
    [string]$Text = ""
  )
  [void]$Lines.Add($Text)
}

function Get-RepoFiles {
  param([string]$Root)

  $ExcludedSegments = @(
    "\node_modules\",
    "\.git\",
    "\.svelte-kit\",
    "\dist\",
    "\build\",
    "\coverage\",
    "\out\",
    "\.next\",
    "\.nuxt\",
    "\target\",
    "\.tmp\",
    "\tmp\",
    "\audio\derived\"
  )

  $Files = Get-ChildItem -LiteralPath $Root -Recurse -File -ErrorAction SilentlyContinue | Where-Object {
    $Full = $_.FullName
    $Keep = $true
    foreach ($Segment in $ExcludedSegments) {
      if ($Full.IndexOf($Segment, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
        $Keep = $false
        break
      }
    }
    $Keep
  }

  return @($Files)
}

function Select-RepoMatches {
  param(
    [object[]]$Files,
    [string[]]$Extensions,
    [string]$Pattern,
    [int]$MaxFiles = 20
  )

  $Targets = @($Files | Where-Object { $Extensions -contains $_.Extension.ToLowerInvariant() } | Select-Object -First 1200)
  if ($Targets.Count -eq 0) {
    return @()
  }

  $Matches = Select-String -Path ($Targets.FullName) -Pattern $Pattern -ErrorAction SilentlyContinue |
    Select-Object -First $MaxFiles

  return @($Matches)
}

function Get-RelPath {
  param(
    [string]$Base,
    [string]$Full
  )

  $BasePath = (Resolve-Path -LiteralPath $Base).Path.TrimEnd("\", "/")
  $Path = $Full
  if ($Path.StartsWith($BasePath, [System.StringComparison]::OrdinalIgnoreCase)) {
    $Path = $Path.Substring($BasePath.Length).TrimStart("\", "/")
  }
  return ($Path -replace "\\", "/")
}

function Add-CandidateRecommendation {
  param(
    [System.Collections.Generic.List[object]]$List,
    [object[]]$CandidateSkills,
    [string]$Slug,
    [string]$Reason,
    [string]$UseNow = "review"
  )

  $Matches = @($CandidateSkills | Where-Object { $_.slug -eq $Slug })
  if ($Matches.Count -eq 0) {
    return
  }

  # Prefer Matt Pocock for the opinionated engineering workflow skills; otherwise take first.
  $Pick = $Matches | Sort-Object @{ Expression = { if ($_.source_slug -eq "mattpocock-skills") { 0 } else { 1 } } }, source_slug | Select-Object -First 1

  $Exists = @($List | Where-Object { $_.slug -eq $Pick.slug -and $_.source_slug -eq $Pick.source_slug }).Count -gt 0
  if ($Exists) {
    return
  }

  $Record = [pscustomobject]@{
    source_slug = [string]$Pick.source_slug
    slug = [string]$Pick.slug
    path = [string]$Pick.path
    reason = $Reason
    use_now = $UseNow
  }
  [void]$List.Add($Record)
}

function Add-CandidateRecord {
  param(
    [System.Collections.Generic.List[object]]$List,
    [object]$Candidate,
    [string]$Reason,
    [string]$Status
  )

  $Record = [pscustomobject]@{
    source_slug = [string]$Candidate.source_slug
    slug = [string]$Candidate.slug
    path = [string]$Candidate.path
    reason = $Reason
    status = $Status
  }
  [void]$List.Add($Record)
}

function Add-PromotedCandidateRecord {
  param(
    [System.Collections.Generic.List[object]]$List,
    [object]$Candidate,
    [object]$ActiveSkill,
    [object]$Provenance,
    [string]$Reason
  )

  $SourceSlug = [string]$Candidate.source_slug
  $SourceName = ""
  $SourceUrl = ""
  $CandidatePath = [string]$Candidate.path
  $Origin = ""

  if ($null -ne $Provenance) {
    $Origin = [string]$Provenance.origin
    if ($null -ne $Provenance.upstream) {
      if (-not [string]::IsNullOrWhiteSpace([string]$Provenance.upstream.source_slug)) {
        $SourceSlug = [string]$Provenance.upstream.source_slug
      }
      $SourceName = [string]$Provenance.upstream.source_name
      $SourceUrl = [string]$Provenance.upstream.source_url
      if (-not [string]::IsNullOrWhiteSpace([string]$Provenance.upstream.candidate_path)) {
        $CandidatePath = [string]$Provenance.upstream.candidate_path
      }
    }
  }

  $Record = [pscustomobject]@{
    source_slug = $SourceSlug
    source_name = $SourceName
    source_url = $SourceUrl
    slug = [string]$Candidate.slug
    active_path = [string]$ActiveSkill.path
    candidate_path = $CandidatePath
    origin = $Origin
    reason = $Reason
    status = "promoted-support"
  }
  [void]$List.Add($Record)
}

if ($Interactive) {
  $Goal = Read-Default -Label "Immediate goal" -Default $Goal
  $TargetAgent = Read-Default -Label "Target agent/tool" -Default $TargetAgent
}

$Stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$PromptRoot = Join-Path $AiWikiRoot ("00_INBOX\proposed\repo-setup-prompts\{0}" -f $ProjectSlug)
$PromptPath = Join-Path $PromptRoot ("repo-skill-recommendation-audit-dryrun-{0}.md" -f $Stamp)

Write-Host ""
Write-Host "==> Repo skill recommendation audit v0.2.0" -ForegroundColor Cyan
Write-Host ("Mode:       {0}" -f "DRY RUN / REPORT ONLY")
Write-Host ("Location:   {0}" -f (Get-Location))
Write-Host ("Script:     {0}" -f $PSScriptRoot)
Write-Host ("PowerShell: {0} {1}" -f $PSVersionTable.PSEdition, $PSVersionTable.PSVersion)
Write-Host ("AI Wiki:    {0}" -f $AiWikiRoot)
Write-Host ("Repo root:  {0}" -f $RepoRoot)
Write-Host ("Project:    {0}" -f $ProjectSlug)
Write-Host ""

if (-not (Test-Path -LiteralPath $AiWikiRoot)) {
  throw ("AI Wiki root missing: {0}" -f $AiWikiRoot)
}

if (-not (Test-Path -LiteralPath $RepoRoot)) {
  throw ("Repo root missing: {0}" -f $RepoRoot)
}

$RegistryPath = Join-Path $AiWikiRoot "03_Indexes\skills\skills-registry.json"
$ProvenancePath = Join-Path $AiWikiRoot "03_Indexes\skills\skill-provenance.json"
$CandidateIndexPath = Join-Path $AiWikiRoot "03_Indexes\skills\external-sources\external-candidate-skills.json"

$Registry = Read-JsonFile -Path $RegistryPath
if ($null -eq $Registry -or $null -eq $Registry.skills) {
  throw ("Registry missing or invalid: {0}" -f $RegistryPath)
}

$ActiveSkills = @($Registry.skills)
$ActiveSkillsBySlug = @{}
foreach ($Skill in $ActiveSkills) {
  if (-not [string]::IsNullOrWhiteSpace([string]$Skill.slug)) {
    $ActiveSkillsBySlug[[string]$Skill.slug] = $Skill
  }
}

$Provenance = Read-JsonFile -Path $ProvenancePath
$ProvenanceSkills = @()
if ($null -ne $Provenance -and $null -ne $Provenance.skills) {
  $ProvenanceSkills = @($Provenance.skills)
}

$ProvenanceBySlug = @{}
foreach ($Skill in $ProvenanceSkills) {
  if (-not [string]::IsNullOrWhiteSpace([string]$Skill.slug)) {
    $ProvenanceBySlug[[string]$Skill.slug] = $Skill
  }
}

$CandidateIndex = Read-JsonFile -Path $CandidateIndexPath
$CandidateSkills = @()
if ($null -ne $CandidateIndex -and $null -ne $CandidateIndex.skills) {
  $CandidateSkills = @($CandidateIndex.skills)
}

Write-Host "==> Auditing repo signals" -ForegroundColor Cyan

$RepoFiles = Get-RepoFiles -Root $RepoRoot
$SourceFiles = @($RepoFiles | Where-Object { $_.FullName -match "\\src\\" })
$MarkdownFiles = @($RepoFiles | Where-Object { $_.Extension.ToLowerInvariant() -eq ".md" })
$PowerShellFiles = @($RepoFiles | Where-Object { $_.Extension.ToLowerInvariant() -eq ".ps1" })

$PackageJsonPath = Join-Path $RepoRoot "package.json"
$PackageJsonText = Read-TextFile -Path $PackageJsonPath
$Package = $null
if (-not [string]::IsNullOrWhiteSpace($PackageJsonText)) {
  try {
    $Package = $PackageJsonText | ConvertFrom-Json
  } catch {
    Write-Warning ("Could not parse package.json: {0}" -f $_.Exception.Message)
  }
}

$ScriptNames = @()
$DepNames = @()
if ($null -ne $Package) {
  if ($Package.scripts) {
    $ScriptNames = @($Package.scripts.PSObject.Properties.Name)
  }
  if ($Package.dependencies) {
    $DepNames += @($Package.dependencies.PSObject.Properties.Name)
  }
  if ($Package.devDependencies) {
    $DepNames += @($Package.devDependencies.PSObject.Properties.Name)
  }
}

$HasPackageJson = Test-Path -LiteralPath $PackageJsonPath
$HasBunLock = Test-HasFile -RelativePath "bun.lock"
$HasPnpmLock = Test-HasFile -RelativePath "pnpm-lock.yaml"
$HasNpmLock = Test-HasFile -RelativePath "package-lock.json"
$HasSvelteConfig = (Test-HasFile -RelativePath "svelte.config.js") -or (Test-HasFile -RelativePath "svelte.config.ts")
$HasViteConfig = (Test-HasFile -RelativePath "vite.config.ts") -or (Test-HasFile -RelativePath "vite.config.js")
$HasSrcRoutes = Test-Path -LiteralPath (Join-Path $RepoRoot "src\routes")
$HasSrcLib = Test-Path -LiteralPath (Join-Path $RepoRoot "src\lib")
$HasAiFolder = Test-Path -LiteralPath (Join-Path $RepoRoot ".ai")
$HasThoughts = Test-Path -LiteralPath (Join-Path $RepoRoot ".thoughts")
$HasAgents = (Test-HasFile -RelativePath "AGENTS.md") -or (Test-HasFile -RelativePath ".ai\AGENTS.md")
$HasDependabot = Test-Path -LiteralPath (Join-Path $RepoRoot ".github\dependabot.yml")
$HasCodeql = Test-Path -LiteralPath (Join-Path $RepoRoot ".github\workflows\codeql.yml")
$HasGitHubWorkflows = Test-Path -LiteralPath (Join-Path $RepoRoot ".github\workflows")

$PackageManager = "unknown"
if ($HasBunLock) {
  $PackageManager = "bun"
} elseif ($HasPnpmLock) {
  $PackageManager = "pnpm"
} elseif ($HasNpmLock) {
  $PackageManager = "npm"
}

$SvelteSignal = $HasSvelteConfig -or ($DepNames -contains "@sveltejs/kit")
$WebglMatches = Select-RepoMatches -Files $RepoFiles -Extensions @(".ts", ".js", ".svelte", ".glsl", ".wgsl") -Pattern "WebGL|webgl|getContext\(|shader|fragment|vertex|canvas|fps|particle|spatial|quadtree" -MaxFiles 30
$AudioMatches = Select-RepoMatches -Files $RepoFiles -Extensions @(".ts", ".js", ".svelte", ".json", ".md") -Pattern "audio|sfx|music|ambient|AudioContext|web audio|waveform|ffmpeg|assetizer|manifest" -MaxFiles 30
$ImageUiMatches = Select-RepoMatches -Files $RepoFiles -Extensions @(".ts", ".js", ".svelte", ".md", ".json") -Pattern "asset|sprite|screenshot|mockup|image-to-ui|ui asset|design|pivot|metro|windows phone|command bar" -MaxFiles 30
$PowerShellMatches = Select-RepoMatches -Files $RepoFiles -Extensions @(".ps1", ".md", ".json") -Pattern "PowerShell|pwsh|tar -xzf|ExecutionPolicy|Dry Run|DRY RUN|Apply|Archive" -MaxFiles 30
$TodoMatches = Select-RepoMatches -Files $RepoFiles -Extensions @(".ts", ".js", ".svelte", ".md", ".ps1") -Pattern "TODO|FIXME|HACK|REGRESSION|P0|P1|broken|missing" -MaxFiles 30

$RouteFiles = @()
if ($HasSrcRoutes) {
  $RouteFiles = @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot "src\routes") -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 80)
}

$LibDirs = @()
if ($HasSrcLib) {
  $LibDirs = @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot "src\lib") -Directory -ErrorAction SilentlyContinue | Select-Object -First 80)
}

$QuestionList = New-Object System.Collections.Generic.List[object]

function Add-Question {
  param(
    [System.Collections.Generic.List[object]]$Questions,
    [string]$Priority,
    [string]$Question,
    [string]$Default,
    [string]$Why
  )

  $Record = [pscustomobject]@{
    priority = $Priority
    question = $Question
    default_answer = $Default
    reason = $Why
  }
  [void]$Questions.Add($Record)
}

if ($HasAgents) {
  Add-Question -Questions $QuestionList -Priority "P1" -Question "AGENTS instructions already exist. Should repo setup patch them, create a separate AI Wiki handoff, or leave repo instructions untouched?" -Default "Do not mutate AGENTS.md during recommendation. Generate a proposed patch/handoff first." -Why "Repo has an AGENTS.md signal, so blindly overwriting instructions would be risky."
} else {
  Add-Question -Questions $QuestionList -Priority "P1" -Question "No AGENTS.md signal was found. Should repo setup create one?" -Default "Generate a proposed AGENTS.md in 00_INBOX/proposed first; do not write directly." -Why "Repo agents need a stable entrypoint, but repo instruction files should be reviewed."
}

if ($HasAiFolder) {
  Add-Question -Questions $QuestionList -Priority "P1" -Question "The repo already has a .ai folder. Should repo-local skill files remain pointer mirrors, or should selected project skills be copied in full?" -Default "Use pointer mirrors only; canonical skills stay in the AI Wiki." -Why "AI Wiki is canonical and the repo already has local AI structure."
}

if ($AudioMatches.Count -gt 20) {
  Add-Question -Questions $QuestionList -Priority "P0" -Question "Audio/SFX/Music terms dominate the repo scan. Should the next repo setup prioritize adaptive-audio over general architecture cleanup?" -Default "Yes: use pixelboats-adaptive-audio as a primary project skill for the next prompt." -Why ("Audio evidence appeared in {0} matched files/snippets." -f $AudioMatches.Count)
}

if ($ImageUiMatches.Count -gt 20) {
  Add-Question -Questions $QuestionList -Priority "P1" -Question "Image/UI/asset terms are heavy. Should image-to-ui-sveltekit be scoped to lab/editor routes only, or all UI routes?" -Default "Scope it to lab/editor/UI asset routes unless the prompt explicitly asks for app-wide UI changes." -Why ("Image/UI evidence appeared in {0} matched files/snippets." -f $ImageUiMatches.Count)
}

if ($WebglMatches.Count -gt 15) {
  Add-Question -Questions $QuestionList -Priority "P0" -Question "WebGL/canvas signals are strong. Should performance work start at render-loop measurement, water shader correctness, or entity/object culling?" -Default "Start with measurement and object/render-loop correctness before shader polish." -Why ("WebGL evidence appeared in {0} matched files/snippets." -f $WebglMatches.Count)
}

if ($PackageManager -eq "bun") {
  Add-Question -Questions $QuestionList -Priority "P1" -Question "Package manager is Bun. Should generated repo commands avoid npm/pnpm unless a script requires them?" -Default "Yes: use bun commands by default." -Why "bun.lock was detected."
}

if ($ScriptNames.Count -gt 0) {
  $UsefulScripts = ($ScriptNames | Where-Object { $_ -match "check|test|lint|build|dev|preview|format" }) -join ", "
  if ([string]::IsNullOrWhiteSpace($UsefulScripts)) {
    $UsefulScripts = "none detected"
  }
  Add-Question -Questions $QuestionList -Priority "P1" -Question "Which verification scripts should repo setup treat as authoritative?" -Default ("Prefer existing package scripts. Detected relevant scripts: {0}" -f $UsefulScripts) -Why "The recommendation should not invent verification commands if package scripts already define them."
}

if (-not $HasDependabot) {
  Add-Question -Questions $QuestionList -Priority "P2" -Question "No Dependabot config was detected. Should dependency automation be considered now or deferred?" -Default "Defer unless this becomes release/maintenance work." -Why "Useful later, but likely not part of the immediate PixelBoats stabilization lane."
}

if (-not $HasCodeql) {
  Add-Question -Questions $QuestionList -Priority "P2" -Question "No CodeQL workflow was detected. Should code scanning be recommended now or deferred?" -Default "Defer for game prototype work; revisit before public release." -Why "Security workflow candidates exist, but they are not the immediate bottleneck."
}

if ($PowerShellMatches.Count -gt 15) {
  Add-Question -Questions $QuestionList -Priority "P1" -Question "PowerShell/package workflow signals are high. Should repo setup standardize apply scripts and cleanup rules?" -Default "Yes: require powershell-script-authoring for all generated package/apply scripts." -Why ("PowerShell/package workflow evidence appeared in {0} matched files/snippets." -f $PowerShellMatches.Count)
}

if ($TodoMatches.Count -gt 10) {
  Add-Question -Questions $QuestionList -Priority "P0" -Question "TODO/FIXME/regression language is present. Should the next agent perform a no-code regression audit before editing?" -Default "Yes: run an audit prompt first unless the user provides a targeted build error." -Why ("Risk/regression evidence appeared in {0} matched files/snippets." -f $TodoMatches.Count)
}

$ActiveRecommendation = New-Object System.Collections.Generic.List[object]
function Add-ActiveRecommendation {
  param(
    [System.Collections.Generic.List[object]]$List,
    [object[]]$ActiveSkills,
    [string]$Slug,
    [string]$Reason,
    [string]$Mode
  )

  $Entry = @($ActiveSkills | Where-Object { $_.slug -eq $Slug } | Select-Object -First 1)
  if ($Entry.Count -eq 0) {
    return
  }

  $Record = [pscustomobject]@{
    slug = $Slug
    path = [string]$Entry[0].path
    mode = $Mode
    reason = $Reason
  }
  [void]$List.Add($Record)
}

Add-ActiveRecommendation -List $ActiveRecommendation -ActiveSkills $ActiveSkills -Slug "repo-skill-recommender" -Mode "always" -Reason "This report is the repo setup entrypoint."
Add-ActiveRecommendation -List $ActiveRecommendation -ActiveSkills $ActiveSkills -Slug "ai-wiki-file-management" -Mode "always" -Reason "Keeps AI Wiki canonical paths, staging, mirrors, and registry rules straight."
Add-ActiveRecommendation -List $ActiveRecommendation -ActiveSkills $ActiveSkills -Slug "powershell-script-authoring" -Mode "always" -Reason "Repo/package workflow has PowerShell/apply-script evidence and recent script failures."
Add-ActiveRecommendation -List $ActiveRecommendation -ActiveSkills $ActiveSkills -Slug "creating-skills" -Mode "support" -Reason "Use only if a candidate or project workflow should become a durable skill."
Add-ActiveRecommendation -List $ActiveRecommendation -ActiveSkills $ActiveSkills -Slug "pixelboats-p0-stabilization" -Mode "primary" -Reason "Immediate goal includes P0 stabilization."
Add-ActiveRecommendation -List $ActiveRecommendation -ActiveSkills $ActiveSkills -Slug "pixelboats-production-architecture" -Mode "primary" -Reason "Immediate goal includes modularization/architecture."
Add-ActiveRecommendation -List $ActiveRecommendation -ActiveSkills $ActiveSkills -Slug "pixelboats-adaptive-audio" -Mode "primary" -Reason ("Audio scan found {0} high-signal matches." -f $AudioMatches.Count)
Add-ActiveRecommendation -List $ActiveRecommendation -ActiveSkills $ActiveSkills -Slug "webgl2-mobile-performance-pass" -Mode "primary" -Reason ("WebGL scan found {0} high-signal matches." -f $WebglMatches.Count)
Add-ActiveRecommendation -List $ActiveRecommendation -ActiveSkills $ActiveSkills -Slug "image-to-ui-sveltekit" -Mode "scoped" -Reason ("Image/UI scan found {0} high-signal matches; use for visual implementation only." -f $ImageUiMatches.Count)
Add-ActiveRecommendation -List $ActiveRecommendation -ActiveSkills $ActiveSkills -Slug "windows-phone-metro-design" -Mode "scoped" -Reason "Use for Metro/WP design critique and UI direction, not general engine work."
Add-ActiveRecommendation -List $ActiveRecommendation -ActiveSkills $ActiveSkills -Slug "universal-prompt-pack-builder" -Mode "support" -Reason "Use for packaging prompts/handoffs, not as a default runtime/repo skill."
Add-ActiveRecommendation -List $ActiveRecommendation -ActiveSkills $ActiveSkills -Slug "pixelboats-release-packaging" -Mode "later" -Reason "Use when changes are made and a package/release artifact is needed."

$CandidateRecommendation = New-Object System.Collections.Generic.List[object]
Add-CandidateRecommendation -List $CandidateRecommendation -CandidateSkills $CandidateSkills -Slug "diagnose" -UseNow "support" -Reason "Useful for structured debugging as an already-promoted support skill."
Add-CandidateRecommendation -List $CandidateRecommendation -CandidateSkills $CandidateSkills -Slug "grill-with-docs" -UseNow "support" -Reason "Useful when challenging assumptions against docs/AI Wiki context."
Add-CandidateRecommendation -List $CandidateRecommendation -CandidateSkills $CandidateSkills -Slug "zoom-out" -UseNow "support" -Reason "Useful after repeated narrow fixes or scope confusion."
Add-CandidateRecommendation -List $CandidateRecommendation -CandidateSkills $CandidateSkills -Slug "improve-codebase-architecture" -UseNow "support" -Reason "Relevant to modularization, but subordinate to PixelBoats production architecture."
Add-CandidateRecommendation -List $CandidateRecommendation -CandidateSkills $CandidateSkills -Slug "code-tour" -UseNow "support" -Reason "Useful for onboarding agents to a large repo before edits."
Add-CandidateRecommendation -List $CandidateRecommendation -CandidateSkills $CandidateSkills -Slug "acquire-codebase-knowledge" -UseNow "support" -Reason "Useful for initial repo mapping if AGENTS/.thoughts are insufficient."
Add-CandidateRecommendation -List $CandidateRecommendation -CandidateSkills $CandidateSkills -Slug "context-map" -UseNow "support" -Reason "Useful if repo/AI Wiki context needs a generated map."
Add-CandidateRecommendation -List $CandidateRecommendation -CandidateSkills $CandidateSkills -Slug "tdd" -UseNow "conditional" -Reason "Use only for stable seams/regression tests; do not force TDD onto visual/WebGL experiments."
Add-CandidateRecommendation -List $CandidateRecommendation -CandidateSkills $CandidateSkills -Slug "breakdown-test" -UseNow "conditional" -Reason "Use if verification gaps are blocking release confidence."
Add-CandidateRecommendation -List $CandidateRecommendation -CandidateSkills $CandidateSkills -Slug "create-implementation-plan" -UseNow "support" -Reason "Useful for implementation handoffs; already promoted as a universal support skill."
Add-CandidateRecommendation -List $CandidateRecommendation -CandidateSkills $CandidateSkills -Slug "write-a-skill" -UseNow "support" -Reason "Useful as an external skill-authoring reference; already promoted as an adapted universal support skill."
Add-CandidateRecommendation -List $CandidateRecommendation -CandidateSkills $CandidateSkills -Slug "conventional-commit" -UseNow "low" -Reason "Helpful for commit hygiene, not needed in prompt setup."
Add-CandidateRecommendation -List $CandidateRecommendation -CandidateSkills $CandidateSkills -Slug "create-agentsmd" -UseNow "conditional" -Reason "Use only if AGENTS.md is missing or Ryan approves an update."

$DeferredCandidateSlugs = @("tdd", "conventional-commit", "create-agentsmd")
$PromotedCandidateSupport = New-Object System.Collections.Generic.List[object]
$UnpromotedCandidateReview = New-Object System.Collections.Generic.List[object]
$DeferredCandidateRecommendation = New-Object System.Collections.Generic.List[object]

foreach ($Item in $CandidateRecommendation) {
  $ActiveSkill = $null
  if ($ActiveSkillsBySlug.ContainsKey([string]$Item.slug)) {
    $ActiveSkill = $ActiveSkillsBySlug[[string]$Item.slug]
  }

  $ProvenanceRecord = $null
  if ($ProvenanceBySlug.ContainsKey([string]$Item.slug)) {
    $ProvenanceRecord = $ProvenanceBySlug[[string]$Item.slug]
  }

  if ($null -ne $ActiveSkill -and $null -ne $ProvenanceRecord -and $null -ne $ProvenanceRecord.upstream) {
    Add-PromotedCandidateRecord -List $PromotedCandidateSupport -Candidate $Item -ActiveSkill $ActiveSkill -Provenance $ProvenanceRecord -Reason $Item.reason
  } elseif ($DeferredCandidateSlugs -contains [string]$Item.slug) {
    Add-CandidateRecord -List $DeferredCandidateRecommendation -Candidate $Item -Reason $Item.reason -Status "deferred"
  } else {
    Add-CandidateRecord -List $UnpromotedCandidateReview -Candidate $Item -Reason $Item.reason -Status $Item.use_now
  }
}

$PromotedCandidateSupportFinal = @($PromotedCandidateSupport | Select-Object -First $MaxCandidateSkills)
$UnpromotedCandidateReviewFinal = @($UnpromotedCandidateReview | Select-Object -First $MaxCandidateSkills)
$DeferredCandidateRecommendationFinal = @($DeferredCandidateRecommendation | Select-Object -First $MaxCandidateSkills)

$Lines = New-Object System.Collections.Generic.List[string]

Add-Line -Lines $Lines -Text "# PixelBoats Repo Skill Recommendation Audit"
Add-Line -Lines $Lines
Add-Line -Lines $Lines -Text ("Generated: {0}" -f (Get-Date).ToString("o"))
Add-Line -Lines $Lines -Text ("Mode: DRY RUN / REPORT ONLY")
Add-Line -Lines $Lines -Text ("Repo: {0}" -f $RepoRoot)
Add-Line -Lines $Lines -Text ("AI Wiki: {0}" -f $AiWikiRoot)
Add-Line -Lines $Lines
Add-Line -Lines $Lines -Text "## Goal"
Add-Line -Lines $Lines
Add-Line -Lines $Lines -Text $Goal
Add-Line -Lines $Lines
Add-Line -Lines $Lines -Text "## Target agent/tool"
Add-Line -Lines $Lines
Add-Line -Lines $Lines -Text $TargetAgent
Add-Line -Lines $Lines
Add-Line -Lines $Lines -Text "## Repo audit signals"
Add-Line -Lines $Lines
Add-Line -Lines $Lines -Text ("- Repo files scanned excluding heavy folders: {0}" -f $RepoFiles.Count)
Add-Line -Lines $Lines -Text ("- Source files under src: {0}" -f $SourceFiles.Count)
Add-Line -Lines $Lines -Text ("- Markdown files: {0}" -f $MarkdownFiles.Count)
Add-Line -Lines $Lines -Text ("- PowerShell files: {0}" -f $PowerShellFiles.Count)
Add-Line -Lines $Lines -Text ("- package.json: {0}" -f $HasPackageJson)
Add-Line -Lines $Lines -Text ("- package manager: {0}" -f $PackageManager)
Add-Line -Lines $Lines -Text ("- scripts: {0}" -f (($ScriptNames | Sort-Object) -join ", "))
Add-Line -Lines $Lines -Text ("- dependencies/devDependencies counted: {0}" -f $DepNames.Count)
Add-Line -Lines $Lines -Text ("- SvelteKit signal: {0}" -f $SvelteSignal)
Add-Line -Lines $Lines -Text ("- Vite config: {0}" -f $HasViteConfig)
Add-Line -Lines $Lines -Text ("- src/routes: {0}" -f $HasSrcRoutes)
Add-Line -Lines $Lines -Text ("- src/lib: {0}" -f $HasSrcLib)
Add-Line -Lines $Lines -Text ("- .ai folder: {0}" -f $HasAiFolder)
Add-Line -Lines $Lines -Text ("- .thoughts: {0}" -f $HasThoughts)
Add-Line -Lines $Lines -Text ("- AGENTS.md signal: {0}" -f $HasAgents)
Add-Line -Lines $Lines -Text ("- Dependabot config: {0}" -f $HasDependabot)
Add-Line -Lines $Lines -Text ("- CodeQL workflow: {0}" -f $HasCodeql)
Add-Line -Lines $Lines -Text ("- GitHub workflows folder: {0}" -f $HasGitHubWorkflows)
Add-Line -Lines $Lines -Text ("- WebGL/canvas high-signal matches sampled: {0}" -f $WebglMatches.Count)
Add-Line -Lines $Lines -Text ("- audio/SFX/music high-signal matches sampled: {0}" -f $AudioMatches.Count)
Add-Line -Lines $Lines -Text ("- image/UI/asset high-signal matches sampled: {0}" -f $ImageUiMatches.Count)
Add-Line -Lines $Lines -Text ("- PowerShell/package workflow matches sampled: {0}" -f $PowerShellMatches.Count)
Add-Line -Lines $Lines -Text ("- TODO/FIXME/regression matches sampled: {0}" -f $TodoMatches.Count)
Add-Line -Lines $Lines -Text ("- active registry skills: {0}" -f $ActiveSkills.Count)
Add-Line -Lines $Lines -Text ("- provenance records: {0}" -f $ProvenanceSkills.Count)
Add-Line -Lines $Lines -Text ("- external candidate source snapshots indexed: {0}" -f $CandidateSkills.Count)

if ($RouteFiles.Count -gt 0) {
  Add-Line -Lines $Lines
  Add-Line -Lines $Lines -Text "### Route sample"
  foreach ($File in ($RouteFiles | Select-Object -First 25)) {
    Add-Line -Lines $Lines -Text ("- {0}" -f (Get-RelPath -Base $RepoRoot -Full $File.FullName))
  }
}

if ($LibDirs.Count -gt 0) {
  Add-Line -Lines $Lines
  Add-Line -Lines $Lines -Text "### src/lib directory sample"
  foreach ($Dir in ($LibDirs | Select-Object -First 30)) {
    Add-Line -Lines $Lines -Text ("- {0}" -f (Get-RelPath -Base $RepoRoot -Full $Dir.FullName))
  }
}

Add-Line -Lines $Lines
Add-Line -Lines $Lines -Text "## Evidence samples"
Add-Line -Lines $Lines

function Add-MatchSection {
  param(
    [System.Collections.Generic.List[string]]$Lines,
    [string]$Title,
    [object[]]$Matches
  )

  Add-Line -Lines $Lines -Text ("### {0}" -f $Title)
  if ($Matches.Count -eq 0) {
    Add-Line -Lines $Lines -Text "- none sampled"
    Add-Line -Lines $Lines
    return
  }

  foreach ($Match in ($Matches | Select-Object -First 12)) {
    $Rel = Get-RelPath -Base $RepoRoot -Full $Match.Path
    $LineText = ($Match.Line -replace "\s+", " ").Trim()
    if ($LineText.Length -gt 180) {
      $LineText = $LineText.Substring(0, 180) + "..."
    }
    Add-Line -Lines $Lines -Text ("- {0}:{1} — {2}" -f $Rel, $Match.LineNumber, $LineText)
  }
  Add-Line -Lines $Lines
}

Add-MatchSection -Lines $Lines -Title "WebGL/canvas" -Matches $WebglMatches
Add-MatchSection -Lines $Lines -Title "Audio/SFX/music" -Matches $AudioMatches
Add-MatchSection -Lines $Lines -Title "Image/UI/assets" -Matches $ImageUiMatches
Add-MatchSection -Lines $Lines -Title "PowerShell/package workflow" -Matches $PowerShellMatches
Add-MatchSection -Lines $Lines -Title "TODO/FIXME/regression" -Matches $TodoMatches

Add-Line -Lines $Lines -Text "## Recommended active AI Wiki skills"
Add-Line -Lines $Lines
foreach ($Item in $ActiveRecommendation) {
  Add-Line -Lines $Lines -Text ("- {0} ({1}) — {2}" -f $Item.slug, $Item.mode, $Item.reason)
  Add-Line -Lines $Lines -Text ("  - path: {0}" -f $Item.path)
}
Add-Line -Lines $Lines

Add-Line -Lines $Lines -Text "## Already-promoted candidate-derived support skills"
Add-Line -Lines $Lines
if ($PromotedCandidateSupportFinal.Count -eq 0) {
  Add-Line -Lines $Lines -Text "- none"
} else {
  foreach ($Item in $PromotedCandidateSupportFinal) {
    Add-Line -Lines $Lines -Text ("- {0} / {1} ({2}) — {3}" -f $Item.source_slug, $Item.slug, $Item.status, $Item.reason)
    Add-Line -Lines $Lines -Text ("  - active path: {0}" -f $Item.active_path)
    Add-Line -Lines $Lines -Text ("  - candidate snapshot: {0}" -f $Item.candidate_path)
    if (-not [string]::IsNullOrWhiteSpace([string]$Item.origin)) {
      Add-Line -Lines $Lines -Text ("  - provenance origin: {0}" -f $Item.origin)
    }
    if (-not [string]::IsNullOrWhiteSpace([string]$Item.source_url)) {
      Add-Line -Lines $Lines -Text ("  - upstream: {0}" -f $Item.source_url)
    }
  }
}
Add-Line -Lines $Lines

Add-Line -Lines $Lines -Text "## Unpromoted candidate snapshots worth future review"
Add-Line -Lines $Lines
if ($UnpromotedCandidateReviewFinal.Count -eq 0) {
  Add-Line -Lines $Lines -Text "- none"
} else {
  foreach ($Item in $UnpromotedCandidateReviewFinal) {
    Add-Line -Lines $Lines -Text ("- {0} / {1} ({2}) — {3}" -f $Item.source_slug, $Item.slug, $Item.status, $Item.reason)
    Add-Line -Lines $Lines -Text ("  - candidate snapshot: {0}" -f $Item.path)
  }
}
Add-Line -Lines $Lines

Add-Line -Lines $Lines -Text "## Deferred candidate snapshots"
Add-Line -Lines $Lines
if ($DeferredCandidateRecommendationFinal.Count -eq 0) {
  Add-Line -Lines $Lines -Text "- none"
} else {
  foreach ($Item in $DeferredCandidateRecommendationFinal) {
    Add-Line -Lines $Lines -Text ("- {0} / {1} ({2}) — {3}" -f $Item.source_slug, $Item.slug, $Item.status, $Item.reason)
    Add-Line -Lines $Lines -Text ("  - candidate snapshot: {0}" -f $Item.path)
  }
}
Add-Line -Lines $Lines

Add-Line -Lines $Lines -Text "## Repo-derived questions"
Add-Line -Lines $Lines
foreach ($Question in $QuestionList) {
  Add-Line -Lines $Lines -Text ("### {0}: {1}" -f $Question.priority, $Question.question)
  Add-Line -Lines $Lines -Text ("Default: {0}" -f $Question.default_answer)
  Add-Line -Lines $Lines -Text ("Why: {0}" -f $Question.reason)
  Add-Line -Lines $Lines
}

Add-Line -Lines $Lines -Text "## Proposed setup model"
Add-Line -Lines $Lines
Add-Line -Lines $Lines -Text "- Keep AI Wiki canonical skills as source of truth."
Add-Line -Lines $Lines -Text '- Treat `04_skills/candidates` as external source snapshots and review library.'
Add-Line -Lines $Lines -Text '- Treat `04_skills/generated` as Ryan-directed generated/history/package records.'
Add-Line -Lines $Lines -Text "- Do not copy all external candidates or generated source records into the repo."
Add-Line -Lines $Lines -Text '- Use repo-local `.ai/skills` only as pointer mirrors unless Ryan explicitly asks for full copies.'
Add-Line -Lines $Lines -Text "- Treat active PixelBoats project skills as the default repo setup set."
Add-Line -Lines $Lines -Text "- Treat already-promoted candidate-derived skills as support skills, not candidate review items."
Add-Line -Lines $Lines -Text '- Keep `tdd`, `conventional-commit`, and `create-agentsmd` deferred until a real task needs them.'
Add-Line -Lines $Lines -Text "- Generate a proposed AGENTS.md or .ai handoff only after Ryan answers the repo-derived questions."

Add-Line -Lines $Lines
Add-Line -Lines $Lines -Text "## Paste-ready next prompt"
Add-Line -Lines $Lines
Add-Line -Lines $Lines -Text "Use the AI Wiki skill shelf and candidate library to prepare PixelBoats repo setup."
Add-Line -Lines $Lines -Text ""
Add-Line -Lines $Lines -Text "Read this report first, then propose a minimal repo setup plan. Do not edit files."
Add-Line -Lines $Lines -Text ""
Add-Line -Lines $Lines -Text "Canonical skill roots:"
Add-Line -Lines $Lines -Text "- <AI_WIKI_ROOT>/04_skills/universal"
Add-Line -Lines $Lines -Text "- <AI_WIKI_ROOT>/04_skills/projects/pixelboats"
Add-Line -Lines $Lines -Text ""
Add-Line -Lines $Lines -Text "Source/history shelves:"
Add-Line -Lines $Lines -Text "- <AI_WIKI_ROOT>/04_skills/candidates"
Add-Line -Lines $Lines -Text "- <AI_WIKI_ROOT>/04_skills/generated"
Add-Line -Lines $Lines -Text ""
Add-Line -Lines $Lines -Text "Do not copy all source snapshots into the repo."
Add-Line -Lines $Lines -Text "Recommend a minimal active set, already-promoted support skills, deferred candidate snapshots, pointer strategy, AGENTS.md strategy, and exact verification commands."
Add-Line -Lines $Lines -Text "Base recommendations on repo evidence, not generic defaults."

Write-Utf8NoBomLf -Path $PromptPath -Text ($Lines -join [Environment]::NewLine)

Write-Host ""
Write-Host "==> Repo audit recommendation written" -ForegroundColor Green
Write-Host $PromptPath
Write-Host ""

if ($OpenReport) {
  notepad $PromptPath
}
