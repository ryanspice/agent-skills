param(
  [string]$DownloadsRoot = "<DOWNLOADS_ROOT>",
  [string]$DevRoot = "<DEV_ROOT>",
  [string]$AiWikiRoot = "<AI_WIKI_ROOT>",
  [string]$SearchRoot = "<SEARCH_ROOT>",
  [string]$ElasticUrl = "http://127.0.0.1:9200"
)

$ErrorActionPreference = "Stop"

try {
  [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
  $OutputEncoding = [System.Text.UTF8Encoding]::new($false)
} catch {}

$script:AiWikiFragments = [ordered]@{
  DownloadsRoot = $DownloadsRoot
  DevRoot = $DevRoot
  AiWikiRoot = $AiWikiRoot
  SearchRoot = $SearchRoot
  ElasticUrl = $ElasticUrl
  RuntimeRoot = Join-Path $AiWikiRoot "04_skills\generated\aiwiki-command-run-fragments\.runtime"
}

function Ensure-RunRuntime {
  $runtime = $script:AiWikiFragments.RuntimeRoot
  if (-not (Test-Path $runtime)) {
    New-Item -ItemType Directory -Path $runtime -Force | Out-Null
  }
  return $runtime
}

function Ensure-ServiceRuntime {
  $root = Join-Path (Ensure-RunRuntime) "search-services"
  if (-not (Test-Path $root)) {
    New-Item -ItemType Directory -Path $root -Force | Out-Null
  }
  return $root
}

function Get-HistoryPath { return (Join-Path (Ensure-RunRuntime) "command-history.json") }
function Get-ElasticPidPath { return (Join-Path (Ensure-ServiceRuntime) "elastic-process.pid") }
function Get-ElasticPathCache { return (Join-Path (Ensure-ServiceRuntime) "elastic-path.txt") }
function Get-ElasticLogPath { return (Join-Path (Ensure-ServiceRuntime) "elastic-start.log") }
function Get-ElasticErrPath { return (Join-Path (Ensure-ServiceRuntime) "elastic-start.err.log") }

function Read-CommandHistory {
  $path = Get-HistoryPath
  if (-not (Test-Path $path)) { return @{} }
  try {
    $raw = Get-Content -Path $path -Raw -Encoding UTF8
    if ([string]::IsNullOrWhiteSpace($raw)) { return @{} }
    $json = $raw | ConvertFrom-Json
    $table = @{}
    foreach ($prop in $json.PSObject.Properties) { $table[$prop.Name] = $prop.Value }
    return $table
  } catch { return @{} }
}

function Write-CommandHistory {
  param([hashtable]$History)
  $History | ConvertTo-Json -Depth 8 | Set-Content -Path (Get-HistoryPath) -Encoding UTF8
}

function Get-CommandKey {
  param([string]$Kind, [string]$Label)
  return (($Kind + "::" + $Label).ToLowerInvariant() -replace "[^a-z0-9:._-]+", "-")
}

function Get-DefaultEstimateSeconds {
  param([string]$Kind)
  switch ($Kind.ToLowerInvariant()) {
    "search" { return 8.0 }
    "reindex" { return 34.0 }
    "index" { return 34.0 }
    "clean" { return 8.0 }
    "run" { return 1.0 }
    "service" { return 45.0 }
    default { return 10.0 }
  }
}

function Get-Estimate {
  param([string]$Kind, [string]$Label)
  $history = Read-CommandHistory
  $key = Get-CommandKey -Kind $Kind -Label $Label
  if ($history.ContainsKey($key) -and $history[$key].lastSeconds) {
    return [pscustomobject]@{ Seconds = [double]$history[$key].lastSeconds; Source = "last" }
  }
  $kindKey = Get-CommandKey -Kind $Kind -Label $Kind
  if ($history.ContainsKey($kindKey) -and $history[$kindKey].avgSeconds) {
    return [pscustomobject]@{ Seconds = [double]$history[$kindKey].avgSeconds; Source = "avg" }
  }
  return [pscustomobject]@{ Seconds = [double](Get-DefaultEstimateSeconds -Kind $Kind); Source = "est" }
}

function Update-Estimate {
  param([string]$Kind, [string]$Label, [double]$Seconds)
  $history = Read-CommandHistory
  $key = Get-CommandKey -Kind $Kind -Label $Label
  $kindKey = Get-CommandKey -Kind $Kind -Label $Kind
  $history[$key] = [pscustomobject]@{ kind = $Kind; label = $Label; lastSeconds = [math]::Round($Seconds, 2); updatedAt = (Get-Date).ToString("o") }
  $prevAvg = 0.0
  $prevCount = 0
  if ($history.ContainsKey($kindKey)) {
    if ($history[$kindKey].avgSeconds) { $prevAvg = [double]$history[$kindKey].avgSeconds }
    if ($history[$kindKey].count) { $prevCount = [int]$history[$kindKey].count }
  }
  if ($prevAvg -le 0) { $prevAvg = $Seconds }
  $count = $prevCount + 1
  $avg = (($prevAvg * $prevCount) + $Seconds) / $count
  $history[$kindKey] = [pscustomobject]@{ kind = $Kind; label = $Kind; avgSeconds = [math]::Round($avg, 2); count = $count; updatedAt = (Get-Date).ToString("o") }
  Write-CommandHistory -History $history
}

function Format-Progress {
  param([double]$Elapsed, [double]$Estimate, [string]$Source)
  $remaining = [math]::Max(0, $Estimate - $Elapsed)
  if (-not $Source) { $Source = "est" }
  return ("elapsed {0:n1}s / {1} {2:n1}s / left {3:n1}s" -f $Elapsed, $Source, $Estimate, $remaining)
}

function Convert-ToConsoleSafe {
  param([string]$Text)
  if (-not $Text) { return "" }
  $sb = [System.Text.StringBuilder]::new()
  foreach ($ch in $Text.ToCharArray()) {
    $code = [int][char]$ch
    if ($code -eq 9 -or $code -eq 10 -or $code -eq 13) { [void]$sb.Append($ch) }
    elseif ($code -ge 32 -and $code -le 126) { [void]$sb.Append($ch) }
    elseif ($code -eq 160) { [void]$sb.Append(" ") }
  }
  return $sb.ToString()
}

function Write-CleanOutput {
  param([string]$Path, [string]$Color = "Gray")
  if (-not (Test-Path $Path)) { return }
  $text = Convert-ToConsoleSafe -Text (Get-Content -Path $Path -Raw -Encoding UTF8)
  $text = $text.TrimEnd()
  if ($text) { Write-Host $text -ForegroundColor $Color }
}

function Invoke-CommandWithSpinner {
  param([string]$Kind, [string]$Label, [string]$ScriptText)
  $estimate = Get-Estimate -Kind $Kind -Label $Label
  $spinner = @("|", "/", "-", "\")
  $runtime = Join-Path $env:TEMP ("aiwiki-run-" + [guid]::NewGuid().ToString("N"))
  $scriptPath = Join-Path $runtime "run.ps1"
  $outPath = Join-Path $runtime "stdout.txt"
  $errPath = Join-Path $runtime "stderr.txt"
  New-Item -ItemType Directory -Path $runtime -Force | Out-Null
  $wrapped = @"
`$ErrorActionPreference = 'Continue'
try {
$ScriptText
} catch {
  Write-Error `$_.Exception.Message
}
exit 0
"@
  $wrapped | Set-Content -Path $scriptPath -Encoding UTF8
  $sw = [System.Diagnostics.Stopwatch]::StartNew()
  $proc = Start-Process -FilePath "pwsh" -ArgumentList @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $scriptPath) -NoNewWindow -PassThru -RedirectStandardOutput $outPath -RedirectStandardError $errPath
  try {
    $i = 0
    while (-not $proc.HasExited) {
      $glyph = $spinner[$i % $spinner.Count]
      $progress = Format-Progress -Elapsed $sw.Elapsed.TotalSeconds -Estimate $estimate.Seconds -Source $estimate.Source
      Write-Host -NoNewline ("`r" + $glyph + " " + $Label + " ... " + $progress + "     ")
      Start-Sleep -Milliseconds 180
      $i++
      $proc.Refresh()
    }
    $proc.WaitForExit()
    $elapsed = $sw.Elapsed.TotalSeconds
    Update-Estimate -Kind $Kind -Label $Label -Seconds $elapsed
    Write-Host -NoNewline "`r"
    $final = Format-Progress -Elapsed $elapsed -Estimate $estimate.Seconds -Source $estimate.Source
    Write-Host ("OK " + $Label + " finished in " + ("{0:n2}s" -f $elapsed) + " (" + $final + ")") -ForegroundColor Green
    Write-CleanOutput -Path $outPath -Color "Gray"
    Write-CleanOutput -Path $errPath -Color "Yellow"
  } finally {
    $sw.Stop()
    Remove-Item -Path $runtime -Recurse -Force -ErrorAction SilentlyContinue
  }
}

function Test-Elastic {
  param([string]$Url = $script:AiWikiFragments.ElasticUrl, [int]$TimeoutSec = 3)
  try {
    $health = Invoke-RestMethod -Uri ($Url.TrimEnd("/") + "/_cluster/health") -TimeoutSec $TimeoutSec
    return [pscustomobject]@{ ok = $true; status = $health.status; url = $Url; error = $null }
  } catch {
    return [pscustomobject]@{ ok = $false; status = $null; url = $Url; error = $_.Exception.Message }
  }
}

function Find-ElasticService {
  Get-Service -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match "elastic|elasticsearch" -or $_.DisplayName -match "Elastic|Elasticsearch" } |
    Select-Object -First 1
}

function Find-ElasticBat {
  $cache = Get-ElasticPathCache
  if (Test-Path $cache) {
    $cached = (Get-Content -Path $cache -Raw -Encoding UTF8).Trim()
    if ($cached -and (Test-Path $cached)) { return $cached }
  }

  $roots = @(
    (Join-Path $script:AiWikiFragments.SearchRoot ".runtime"),
    $script:AiWikiFragments.SearchRoot
  )

  foreach ($root in $roots) {
    if (Test-Path $root) {
      $hit = Get-ChildItem -Path $root -Filter "elasticsearch.bat" -Recurse -ErrorAction SilentlyContinue |
        Select-Object -First 1
      if ($hit) {
        $hit.FullName | Set-Content -Path $cache -Encoding UTF8
        return $hit.FullName
      }
    }
  }

  return $null
}

function Find-ElasticStartScript {
  $patterns = @("Start-SearchElastic.ps1", "Start-Elastic.ps1", "Start-Elasticsearch.ps1", "Start-SearchServices.ps1")
  foreach ($p in $patterns) {
    $candidate = Join-Path (Join-Path $script:AiWikiFragments.SearchRoot "scripts") $p
    if (Test-Path $candidate) { return $candidate }
  }
  return $null
}

function Find-ElasticStopScript {
  $patterns = @("Stop-SearchElastic.ps1", "Stop-Elastic.ps1", "Stop-Elasticsearch.ps1", "Stop-SearchServices.ps1")
  foreach ($p in $patterns) {
    $candidate = Join-Path (Join-Path $script:AiWikiFragments.SearchRoot "scripts") $p
    if (Test-Path $candidate) { return $candidate }
  }
  return $null
}

function Wait-Elastic {
  param([int]$TimeoutSec = 75)
  $estimate = Get-Estimate -Kind "service" -Label "Wait Elastic"
  if ($estimate.Seconds -lt $TimeoutSec) { $estimate.Seconds = $TimeoutSec }
  $spinner = @("|", "/", "-", "\")
  $sw = [System.Diagnostics.Stopwatch]::StartNew()
  try {
    $i = 0
    while ($sw.Elapsed.TotalSeconds -lt $TimeoutSec) {
      $health = Test-Elastic -TimeoutSec 2
      if ($health.ok) {
        Write-Host -NoNewline "`r"
        Write-Host ("OK Elastic reachable: " + $health.url + " status=" + $health.status) -ForegroundColor Green
        Update-Estimate -Kind "service" -Label "Wait Elastic" -Seconds $sw.Elapsed.TotalSeconds
        return $health
      }
      $glyph = $spinner[$i % $spinner.Count]
      $progress = Format-Progress -Elapsed $sw.Elapsed.TotalSeconds -Estimate $estimate.Seconds -Source $estimate.Source
      Write-Host -NoNewline ("`r" + $glyph + " Waiting for Elastic ... " + $progress + "     ")
      Start-Sleep -Seconds 2
      $i++
    }
    Write-Host -NoNewline "`r"
    Write-Host ("WARN Elastic was not reachable after " + $TimeoutSec + "s. Continuing with fallback lanes.") -ForegroundColor Yellow
    return (Test-Elastic -TimeoutSec 2)
  } finally {
    $sw.Stop()
  }
}

function Start-ElasticDirectBat {
  param([string]$BatPath)
  $log = Get-ElasticLogPath
  $err = Get-ElasticErrPath
  $workDir = Split-Path -Parent $BatPath
  $cmd = "/c title AI Wiki Elasticsearch && `"$BatPath`" >> `"$log`" 2>> `"$err`""
  Write-Host ("Starting Elastic hidden via: " + $BatPath) -ForegroundColor Cyan
  Write-Host ("Log: " + $log) -ForegroundColor DarkCyan
  $proc = Start-Process -FilePath "cmd.exe" -ArgumentList $cmd -WorkingDirectory $workDir -WindowStyle Hidden -PassThru
  $proc.Id | Set-Content -Path (Get-ElasticPidPath) -Encoding UTF8
}

function Start-ElasticScriptHidden {
  param([string]$ScriptPath)
  $log = Get-ElasticLogPath
  $err = Get-ElasticErrPath
  Write-Host ("Starting Elastic hidden via script: " + $ScriptPath) -ForegroundColor Cyan
  Write-Host ("Log: " + $log) -ForegroundColor DarkCyan
  $args = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $ScriptPath)
  $proc = Start-Process -FilePath "pwsh" -ArgumentList $args -WindowStyle Hidden -PassThru -RedirectStandardOutput $log -RedirectStandardError $err
  $proc.Id | Set-Content -Path (Get-ElasticPidPath) -Encoding UTF8
}

function Start-Elastic {
  param([int]$TimeoutSec = 75, [switch]$UseScriptFirst)

  $health = Test-Elastic
  if ($health.ok) {
    Write-Host ("Elastic already reachable: " + $health.url + " status=" + $health.status) -ForegroundColor Green
    return $health
  }

  Write-Host ("Elastic unavailable: " + $health.error) -ForegroundColor Yellow

  $svc = Find-ElasticService
  if ($svc) {
    Write-Host ("Starting Elastic service: " + $svc.Name) -ForegroundColor Cyan
    if ($svc.Status -ne "Running") { Start-Service -Name $svc.Name }
    return (Wait-Elastic -TimeoutSec $TimeoutSec)
  }

  if (Get-Command docker -ErrorAction SilentlyContinue) {
    $containers = docker ps -a --format "{{.Names}}|{{.Image}}|{{.Status}}" 2>$null |
      Where-Object { $_ -match "elastic|elasticsearch" }
    if ($containers) {
      $name = (($containers | Select-Object -First 1) -split "\|")[0]
      Write-Host ("Starting Elastic Docker container: " + $name) -ForegroundColor Cyan
      docker start $name | Out-Host
      return (Wait-Elastic -TimeoutSec $TimeoutSec)
    }
  }

  $scriptPath = Find-ElasticStartScript
  $bat = Find-ElasticBat

  if ($UseScriptFirst -and $scriptPath) {
    Start-ElasticScriptHidden -ScriptPath $scriptPath
    return (Wait-Elastic -TimeoutSec $TimeoutSec)
  }

  if ($bat) {
    Start-ElasticDirectBat -BatPath $bat
    return (Wait-Elastic -TimeoutSec $TimeoutSec)
  }

  if ($scriptPath) {
    Start-ElasticScriptHidden -ScriptPath $scriptPath
    return (Wait-Elastic -TimeoutSec $TimeoutSec)
  }

  Write-Host "No Elastic start method found. Continuing with rg/Everything fallback." -ForegroundColor Yellow
  return (Test-Elastic)
}

function Stop-Elastic {
  $scriptPath = Find-ElasticStopScript
  if ($scriptPath) {
    Write-Host ("Stopping Elastic via script: " + $scriptPath) -ForegroundColor Cyan
    & pwsh -NoProfile -ExecutionPolicy Bypass -File $scriptPath
    return
  }

  $pidPath = Get-ElasticPidPath
  if (Test-Path $pidPath) {
    $pidText = (Get-Content -Path $pidPath -Raw -Encoding UTF8).Trim()
    if ($pidText -match "^\d+$") {
      $pid = [int]$pidText
      $p = Get-Process -Id $pid -ErrorAction SilentlyContinue
      if ($p) {
        Write-Host ("Stopping recorded Elastic starter process: " + $pid) -ForegroundColor Cyan
        Stop-Process -Id $pid -Force
      }
    }
    Remove-Item $pidPath -Force -ErrorAction SilentlyContinue
    return
  }

  $svc = Find-ElasticService
  if ($svc -and $svc.Status -eq "Running") {
    Write-Host ("Stopping Elastic service: " + $svc.Name) -ForegroundColor Cyan
    Stop-Service -Name $svc.Name
    return
  }

  Write-Host "No Elastic stop method found by this helper." -ForegroundColor Yellow
}

function Restart-Elastic {
  Stop-Elastic
  Start-Sleep -Seconds 2
  Start-Elastic
}

function Start-Everything {
  $svc = Get-Service -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq "Everything" -or $_.DisplayName -match "Everything" } |
    Select-Object -First 1

  if ($svc) {
    if ($svc.Status -ne "Running") {
      Write-Host ("Starting Everything service: " + $svc.Name) -ForegroundColor Cyan
      Start-Service -Name $svc.Name
    } else {
      Write-Host "Everything service already running." -ForegroundColor Green
    }
    return
  }

  $candidates = @("$env:ProgramFiles\Everything\Everything.exe", "$env:LOCALAPPDATA\Programs\Everything\Everything.exe", "C:\Program Files\Everything\Everything.exe")
  foreach ($exe in $candidates) {
    if (Test-Path $exe) {
      Write-Host ("Starting Everything minimized: " + $exe) -ForegroundColor Cyan
      Start-Process $exe -WindowStyle Minimized
      return
    }
  }

  Write-Host "Everything service/app not found. Search will continue with available lanes." -ForegroundColor Yellow
}

function Status-SearchServices {
  $elastic = Test-Elastic
  if ($elastic.ok) { Write-Host ("Elastic: OK " + $elastic.url + " status=" + $elastic.status) -ForegroundColor Green }
  else { Write-Host ("Elastic: DOWN " + $elastic.error) -ForegroundColor Yellow }

  $pidPath = Get-ElasticPidPath
  if (Test-Path $pidPath) {
    $pidText = (Get-Content -Path $pidPath -Raw -Encoding UTF8).Trim()
    Write-Host ("Elastic recorded starter PID: " + $pidText) -ForegroundColor DarkCyan
  }

  $svc = Get-Service -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq "Everything" -or $_.DisplayName -match "Everything" } |
    Select-Object -First 1
  if ($svc) { Write-Host ("Everything: service " + $svc.Name + " status=" + $svc.Status) -ForegroundColor Cyan }
  else { Write-Host "Everything: service not found by helper" -ForegroundColor Yellow }

  Write-Host ("Service logs: " + (Ensure-ServiceRuntime)) -ForegroundColor DarkCyan
}

function Start-SearchServices {
  Write-Host "Checking Search services..." -ForegroundColor Cyan
  Start-Elastic | Out-Null
  Start-Everything
  Status-SearchServices
}

function Ensure-SearchServices { Start-SearchServices }

function Join-QuotedArgs {
  param([object[]]$Args)
  if (-not $Args) { return "" }
  return (($Args | ForEach-Object {
    $s = [string]$_
    "'" + ($s -replace "'", "''") + "'"
  }) -join " ")
}

function Get-LatestTarArchive {
  param([string]$Root = $script:AiWikiFragments.DownloadsRoot)
  $latest = Get-ChildItem -LiteralPath $Root -File -Filter "*.tar.gz" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
  if (-not $latest) { throw ("No .tar.gz archive found in " + $Root) }
  return $latest.FullName
}

function Get-TarBaseName {
  param([string]$Archive)
  $name = [System.IO.Path]::GetFileName($Archive)
  if ($name.EndsWith(".tar.gz", [System.StringComparison]::OrdinalIgnoreCase)) { return $name.Substring(0, $name.Length - 7) }
  return [System.IO.Path]::GetFileNameWithoutExtension($Archive)
}

function Use-Search {
  param([string]$SearchRoot = $script:AiWikiFragments.SearchRoot, [switch]$NoServiceStart)
  $loader = Join-Path $SearchRoot "scripts\Load-SearchEnv.ps1"
  if (-not (Test-Path $loader)) { throw ("Search loader not found: " + $loader) }
  . $loader
  if (-not $NoServiceStart) { Start-SearchServices }
  Write-Host "Search environment loaded. Wrapper commands remain active in this session." -ForegroundColor Green
}

function Use-AiWikiSearch {
  param([string]$SearchRoot = $script:AiWikiFragments.SearchRoot, [switch]$NoServiceStart)
  Use-Search -SearchRoot $SearchRoot -NoServiceStart:$NoServiceStart
}

function Use-Run {
  param([switch]$WithSearch, [switch]$NoServiceStart)
  Write-Host "Run fragments ready." -ForegroundColor Green
  Write-Host ("DownloadsRoot: " + $script:AiWikiFragments.DownloadsRoot) -ForegroundColor DarkCyan
  Write-Host ("DevRoot:       " + $script:AiWikiFragments.DevRoot) -ForegroundColor DarkCyan
  Write-Host ("AiWikiRoot:    " + $script:AiWikiFragments.AiWikiRoot) -ForegroundColor DarkCyan
  Write-Host ("SearchRoot:    " + $script:AiWikiFragments.SearchRoot) -ForegroundColor DarkCyan
  Write-Host ("ElasticUrl:    " + $script:AiWikiFragments.ElasticUrl) -ForegroundColor DarkCyan
  Write-Host ("RuntimeRoot:   " + $script:AiWikiFragments.RuntimeRoot) -ForegroundColor DarkCyan
  Write-Host ""
  Write-Host "Commands:" -ForegroundColor Cyan
  Write-Host "  Use-Search                     # load <SEARCH_ROOT> and start services" -ForegroundColor DarkCyan
  Write-Host "  Status-SearchServices          # show Elastic/Everything status" -ForegroundColor DarkCyan
  Write-Host "  Start-SearchServices           # start Elastic/Everything hidden/minimized" -ForegroundColor DarkCyan
  Write-Host "  Start-Elastic / Stop-Elastic / Restart-Elastic" -ForegroundColor DarkCyan
  Write-Host "  Search ...                     # ensure services, spinner + ETA" -ForegroundColor DarkCyan
  Write-Host "  Reindex                        # ensure services, spinner + ETA" -ForegroundColor DarkCyan
  Write-Host "  Run                            # spinner dry-run latest TAR" -ForegroundColor DarkCyan
  Write-Host ""
  if ($WithSearch) { Use-Search -NoServiceStart:$NoServiceStart }
}

function Use-AiWikiRun {
  param([switch]$WithSearch, [switch]$NoServiceStart)
  Use-Run -WithSearch:$WithSearch -NoServiceStart:$NoServiceStart
}

function Search {
  param([Parameter(ValueFromRemainingArguments = $true)][object[]]$Args)
  Ensure-SearchServices
  $argList = Join-QuotedArgs -Args $Args
  $loader = Join-Path $script:AiWikiFragments.SearchRoot "scripts\Load-SearchEnv.ps1"
  $scriptText = @"
. '$loader'
Search $argList
"@
  $label = "Search"
  if ($Args -and $Args.Count -gt 0) { $label = "Search " + (($Args | ForEach-Object { [string]$_ }) -join " ") }
  Invoke-CommandWithSpinner -Kind "search" -Label $label -ScriptText $scriptText
}

function Reindex {
  param([Parameter(ValueFromRemainingArguments = $true)][object[]]$Args)
  Ensure-SearchServices
  $argList = Join-QuotedArgs -Args $Args
  $loader = Join-Path $script:AiWikiFragments.SearchRoot "scripts\Load-SearchEnv.ps1"
  $scriptText = @"
. '$loader'
Reindex $argList
"@
  Invoke-CommandWithSpinner -Kind "reindex" -Label "Reindex" -ScriptText $scriptText
}

function Index {
  param([Parameter(ValueFromRemainingArguments = $true)][object[]]$Args)
  Ensure-SearchServices
  $argList = Join-QuotedArgs -Args $Args
  $loader = Join-Path $script:AiWikiFragments.SearchRoot "scripts\Load-SearchEnv.ps1"
  $scriptText = @"
. '$loader'
Index $argList
"@
  Invoke-CommandWithSpinner -Kind "index" -Label "Index" -ScriptText $scriptText
}

function Clean {
  param([Parameter(ValueFromRemainingArguments = $true)][object[]]$Args)
  $argList = Join-QuotedArgs -Args $Args
  $loader = Join-Path $script:AiWikiFragments.SearchRoot "scripts\Load-SearchEnv.ps1"
  $scriptText = @"
. '$loader'
Clean $argList
"@
  Invoke-CommandWithSpinner -Kind "clean" -Label "Clean" -ScriptText $scriptText
}

function Run {
  param(
    [string]$Archive,
    [string]$Work,
    [string]$ProjectName = "",
    [string]$Category = "",
    [string]$OutputRoot = "",
    [switch]$InstallToDev,
    [switch]$RunInternalInstaller,
    [switch]$RunBunInstall,
    [switch]$UseBunIsolated,
    [switch]$FrozenLockfile,
    [switch]$Apply,
    [switch]$Open,
    [switch]$Delete,
    [switch]$DeleteArchive
  )
  $downloads = $script:AiWikiFragments.DownloadsRoot
  $devRoot = $script:AiWikiFragments.DevRoot
  $aiWiki = $script:AiWikiFragments.AiWikiRoot
  if (-not $Archive) { $Archive = Get-LatestTarArchive -Root $downloads }
  if (-not $Work) { $Work = Join-Path $downloads (Get-TarBaseName -Archive $Archive) }

  if ($Delete) {
    $mode = if ($Apply) { "APPLY" } else { "DRY RUN" }
    $deleteBody = if ($Apply) { "if (Test-Path `$Work) { Remove-Item -LiteralPath `$Work -Recurse -Force; Write-Host ('Deleted: ' + `$Work) } else { Write-Host ('No work folder found: ' + `$Work) }" } else { "if (Test-Path `$Work) { Write-Host ('Would delete: ' + `$Work) } else { Write-Host ('No work folder found: ' + `$Work) }; Write-Host 'Dry run only. Add -Apply to delete.'" }
    $deleteArchiveBody = ""
    if ($DeleteArchive) { $deleteArchiveBody = if ($Apply) { "if (Test-Path `$Archive) { Remove-Item -LiteralPath `$Archive -Force; Write-Host ('Deleted archive: ' + `$Archive) }" } else { "if (Test-Path `$Archive) { Write-Host ('Would delete archive: ' + `$Archive) }" } }
    $openBody = if ($Open) { "Start-Process `$DownloadsRoot" } else { "" }
    $scriptText = @"
`$Work = '$($Work -replace "'", "''")'
`$Archive = '$($Archive -replace "'", "''")'
`$DownloadsRoot = '$($downloads -replace "'", "''")'
Write-Host 'Run cleanup'
Write-Host ('Mode:    ' + '$mode')
Write-Host ('Work:    ' + `$Work)
Write-Host ('Archive: ' + `$Archive)
$deleteBody
$deleteArchiveBody
$openBody
"@
    $label = if ($Apply) { "Run delete" } else { "Run delete dry-run" }
    Invoke-CommandWithSpinner -Kind "run" -Label $label -ScriptText $scriptText
    return
  }

  $installer = Join-Path $aiWiki "04_skills\generated\windows-tar-package-installer-workflow\scripts\Install-TarPackage.ps1"
  if (-not (Test-Path $installer)) { throw ("Installer helper not found: " + $installer) }
  $args = New-Object System.Collections.Generic.List[string]
  $args.Add("-Archive '$($Archive -replace "'", "''")'") | Out-Null
  $args.Add("-Work '$($Work -replace "'", "''")'") | Out-Null
  $args.Add("-DownloadsRoot '$($downloads -replace "'", "''")'") | Out-Null
  $args.Add("-DevRoot '$($devRoot -replace "'", "''")'") | Out-Null
  if ($ProjectName) { $args.Add("-ProjectName '$($ProjectName -replace "'", "''")'") | Out-Null }
  if ($Category) { $args.Add("-Category '$($Category -replace "'", "''")'") | Out-Null }
  if ($OutputRoot) { $args.Add("-OutputRoot '$($OutputRoot -replace "'", "''")'") | Out-Null }
  if ($InstallToDev) { $args.Add("-InstallToDev") | Out-Null }
  if ($RunInternalInstaller) { $args.Add("-RunInternalInstaller") | Out-Null }
  if ($RunBunInstall) { $args.Add("-RunBunInstall") | Out-Null }
  if ($UseBunIsolated) { $args.Add("-UseBunIsolated") | Out-Null }
  if ($FrozenLockfile) { $args.Add("-FrozenLockfile") | Out-Null }
  if ($Apply) { $args.Add("-Apply") | Out-Null }
  if ($Open) { $args.Add("-Open") | Out-Null }
  $scriptText = @"
& '$installer' $($args -join ' ')
"@
  $label = if ($Apply) { "Run apply" } else { "Run dry-run" }
  Invoke-CommandWithSpinner -Kind "run" -Label $label -ScriptText $scriptText
}

Write-Host "Loaded command fragments." -ForegroundColor Green
Write-Host "Commands: Use-Run, Use-Search, Search, Reindex, Index, Clean, Run, Start-Elastic, Stop-Elastic, Status-SearchServices" -ForegroundColor DarkCyan
Write-Host "Default: Search/Reindex/Index try hidden Elastic/Everything startup, then run with spinner + ETA. Run is dry-run unless -Apply is passed." -ForegroundColor DarkCyan

# Load optional polish layer.
$__aiwikiPolish = Join-Path (Split-Path -Parent $PSCommandPath) "Load-AiWikiCommandFragments.Polish.ps1"
if (Test-Path $__aiwikiPolish) {
  . $__aiwikiPolish
}


# Load optional output polish layer.
$__aiwikiOutputPolish = Join-Path (Split-Path -Parent $PSCommandPath) "Load-AiWikiCommandFragments.OutputPolish.ps1"
if (Test-Path $__aiwikiOutputPolish) {
  . $__aiwikiOutputPolish
}


# Load optional pretty output layer.
$__aiwikiPrettyOutput = Join-Path (Split-Path -Parent $PSCommandPath) "Load-AiWikiCommandFragments.PrettyOutput.ps1"
if (Test-Path $__aiwikiPrettyOutput) {
  . $__aiwikiPrettyOutput
}
