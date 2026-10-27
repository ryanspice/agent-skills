# AI Wiki command fragments polish layer v0.1.8
# Dot-sourced automatically from Load-AiWikiCommandFragments.ps1 when installed.

if (-not $script:AiWikiFragments) {
  throw "Load-AiWikiCommandFragments.ps1 must be loaded before the polish layer."
}

function Clear-ProgressLine {
  param([int]$Width = 140)
  Write-Host -NoNewline ("`r" + (" " * $Width) + "`r")
}

function Test-EverythingIpc {
  try {
    $es = Join-Path $script:AiWikiFragments.SearchRoot ".runtime\aiwiki-search\tools\es.exe"
    if (-not (Test-Path $es)) {
      return [pscustomobject]@{ ok = $false; error = "es.exe not found: " + $es }
    }

    $output = & $es -version 2>&1
    $text = ($output | Out-String)
    if ($LASTEXITCODE -eq 0) {
      return [pscustomobject]@{ ok = $true; error = $null }
    }

    return [pscustomobject]@{ ok = $false; error = $text.Trim() }
  } catch {
    return [pscustomobject]@{ ok = $false; error = $_.Exception.Message }
  }
}

function Ensure-SearchServicesQuiet {
  param([switch]$VerboseServices)

  $elastic = Test-Elastic -TimeoutSec 2
  $started = $false

  if (-not $elastic.ok) {
    if ($VerboseServices) {
      Write-Host ("Elastic unavailable: " + $elastic.error) -ForegroundColor Yellow
      Start-Elastic | Out-Null
    } else {
      Write-Host "Elastic unavailable; attempting hidden startup..." -ForegroundColor Yellow
      Start-Elastic | Out-Null
    }
    $started = $true
  }

  $everything = Test-EverythingIpc
  if (-not $everything.ok) {
    if ($VerboseServices) {
      Write-Host ("Everything IPC unavailable: " + $everything.error) -ForegroundColor Yellow
    }
    Start-Everything
  }

  if ($VerboseServices -or $started) {
    Status-SearchServices
  }
}

function Use-Run {
  param(
    [switch]$WithSearch,
    [switch]$NoServiceStart,
    [switch]$Quiet
  )

  Write-Host "Run fragments ready." -ForegroundColor Green
  if (-not $Quiet) {
    Write-Host ("DownloadsRoot: " + $script:AiWikiFragments.DownloadsRoot) -ForegroundColor DarkCyan
    Write-Host ("DevRoot:       " + $script:AiWikiFragments.DevRoot) -ForegroundColor DarkCyan
    Write-Host ("AiWikiRoot:    " + $script:AiWikiFragments.AiWikiRoot) -ForegroundColor DarkCyan
    Write-Host ("SearchRoot:    " + $script:AiWikiFragments.SearchRoot) -ForegroundColor DarkCyan
    Write-Host ("ElasticUrl:    " + $script:AiWikiFragments.ElasticUrl) -ForegroundColor DarkCyan
    Write-Host ("RuntimeRoot:   " + $script:AiWikiFragments.RuntimeRoot) -ForegroundColor DarkCyan
    Write-Host ""
  }

  Write-Host "Commands: Use-Search, Status-SearchServices, Start-SearchServices, Search, Reindex, Run" -ForegroundColor Cyan

  if ($WithSearch) {
    Use-Search -NoServiceStart:$NoServiceStart
    if (-not $NoServiceStart) {
      Ensure-SearchServicesQuiet -VerboseServices:(!$Quiet)
    }
  }
}

function Use-AiWikiRun {
  param(
    [switch]$WithSearch,
    [switch]$NoServiceStart,
    [switch]$Quiet
  )
  Use-Run -WithSearch:$WithSearch -NoServiceStart:$NoServiceStart -Quiet:$Quiet
}

function Search {
  param(
    [switch]$NoServiceStart,
    [Parameter(ValueFromRemainingArguments = $true)]
    [object[]]$Args
  )

  if (-not $NoServiceStart) { Ensure-SearchServicesQuiet }
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
  param(
    [switch]$NoServiceStart,
    [Parameter(ValueFromRemainingArguments = $true)]
    [object[]]$Args
  )

  if (-not $NoServiceStart) { Ensure-SearchServicesQuiet }
  $argList = Join-QuotedArgs -Args $Args
  $loader = Join-Path $script:AiWikiFragments.SearchRoot "scripts\Load-SearchEnv.ps1"
  $scriptText = @"
. '$loader'
Reindex $argList
"@
  Invoke-CommandWithSpinner -Kind "reindex" -Label "Reindex" -ScriptText $scriptText
}

function Index {
  param(
    [switch]$NoServiceStart,
    [Parameter(ValueFromRemainingArguments = $true)]
    [object[]]$Args
  )

  if (-not $NoServiceStart) { Ensure-SearchServicesQuiet }
  $argList = Join-QuotedArgs -Args $Args
  $loader = Join-Path $script:AiWikiFragments.SearchRoot "scripts\Load-SearchEnv.ps1"
  $scriptText = @"
. '$loader'
Index $argList
"@
  Invoke-CommandWithSpinner -Kind "index" -Label "Index" -ScriptText $scriptText
}
