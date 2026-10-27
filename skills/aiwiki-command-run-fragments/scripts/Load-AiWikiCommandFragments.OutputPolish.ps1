# AI Wiki command fragments output polish layer v0.1.9
# Loaded after the main and polish layers.

if (-not $script:AiWikiFragments) {
  throw "Load-AiWikiCommandFragments.ps1 must be loaded before the output polish layer."
}

function Remove-SearchLoaderBanner {
  param([string]$Text)

  if (-not $Text) { return "" }

  $lines = $Text -split "`r?`n"
  $out = New-Object System.Collections.Generic.List[string]
  $skipping = $false

  foreach ($line in $lines) {
    if ($line -match "^\s*Loaded Search environment\s*$") {
      $skipping = $true
      continue
    }

    if ($skipping) {
      if ($line -match "^\s*Engines:\s+") {
        $skipping = $false
        continue
      }
      continue
    }

    if ($line -match "^\s*Commands:\s*Search,\s*Index,\s*Reindex,\s*Status,\s*Clean\s*$") { continue }
    if ($line -match "^\s*Engines:\s*broker,\s*rg,\s*everything,\s*elastic\s*$") { continue }

    $out.Add($line) | Out-Null
  }

  return (($out | ForEach-Object { $_ }) -join [Environment]::NewLine)
}

function Compress-BlankLines {
  param([string]$Text)

  if (-not $Text) { return "" }

  $lines = $Text -split "`r?`n"
  $out = New-Object System.Collections.Generic.List[string]
  $blankSeen = $false

  foreach ($line in $lines) {
    if ([string]::IsNullOrWhiteSpace($line)) {
      if (-not $blankSeen) {
        $out.Add("") | Out-Null
        $blankSeen = $true
      }
    } else {
      $out.Add($line) | Out-Null
      $blankSeen = $false
    }
  }

  return (($out | ForEach-Object { $_ }) -join [Environment]::NewLine).Trim()
}

function Clean-CommandOutputText {
  param(
    [string]$Text,
    [switch]$Raw
  )

  if (-not $Text) { return "" }

  $text = Convert-ToConsoleSafe -Text $Text

  if (-not $Raw) {
    $text = Remove-SearchLoaderBanner -Text $text
    $text = Compress-BlankLines -Text $text
  }

  return $text.TrimEnd()
}

function Write-CleanOutput {
  param(
    [string]$Path,
    [string]$Color = "Gray",
    [switch]$Raw
  )

  if (-not (Test-Path $Path)) { return }

  $text = Get-Content -Path $Path -Raw -Encoding UTF8
  $text = Clean-CommandOutputText -Text $text -Raw:$Raw

  if ($text) {
    Write-Host $text -ForegroundColor $Color
  }
}

function Invoke-CommandWithSpinnerPolished {
  param(
    [string]$Kind,
    [string]$Label,
    [string]$ScriptText,
    [switch]$Raw
  )

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

    Write-Host -NoNewline ("`r" + (" " * 150) + "`r")
    $final = Format-Progress -Elapsed $elapsed -Estimate $estimate.Seconds -Source $estimate.Source
    Write-Host ("OK " + $Label + " finished in " + ("{0:n2}s" -f $elapsed) + " (" + $final + ")") -ForegroundColor Green

    Write-CleanOutput -Path $outPath -Color "Gray" -Raw:$Raw
    Write-CleanOutput -Path $errPath -Color "Yellow" -Raw:$Raw
  } finally {
    $sw.Stop()
    Remove-Item -Path $runtime -Recurse -Force -ErrorAction SilentlyContinue
  }
}

function Search {
  param(
    [switch]$NoServiceStart,
    [switch]$Raw,
    [Parameter(ValueFromRemainingArguments = $true)]
    [object[]]$Args
  )

  if (-not $NoServiceStart) { Ensure-SearchServicesQuiet }
  $argList = Join-QuotedArgs -Args $Args
  $loader = Join-Path $script:AiWikiFragments.SearchRoot "scripts\Load-SearchEnv.ps1"
  $scriptText = @"
. '$loader' *> `$null
Search $argList
"@
  $label = "Search"
  if ($Args -and $Args.Count -gt 0) { $label = "Search " + (($Args | ForEach-Object { [string]$_ }) -join " ") }
  Invoke-CommandWithSpinnerPolished -Kind "search" -Label $label -ScriptText $scriptText -Raw:$Raw
}

function Reindex {
  param(
    [switch]$NoServiceStart,
    [switch]$Raw,
    [Parameter(ValueFromRemainingArguments = $true)]
    [object[]]$Args
  )

  if (-not $NoServiceStart) { Ensure-SearchServicesQuiet }
  $argList = Join-QuotedArgs -Args $Args
  $loader = Join-Path $script:AiWikiFragments.SearchRoot "scripts\Load-SearchEnv.ps1"
  $scriptText = @"
. '$loader' *> `$null
Reindex $argList
"@
  Invoke-CommandWithSpinnerPolished -Kind "reindex" -Label "Reindex" -ScriptText $scriptText -Raw:$Raw
}

function Index {
  param(
    [switch]$NoServiceStart,
    [switch]$Raw,
    [Parameter(ValueFromRemainingArguments = $true)]
    [object[]]$Args
  )

  if (-not $NoServiceStart) { Ensure-SearchServicesQuiet }
  $argList = Join-QuotedArgs -Args $Args
  $loader = Join-Path $script:AiWikiFragments.SearchRoot "scripts\Load-SearchEnv.ps1"
  $scriptText = @"
. '$loader' *> `$null
Index $argList
"@
  Invoke-CommandWithSpinnerPolished -Kind "index" -Label "Index" -ScriptText $scriptText -Raw:$Raw
}

function Clean {
  param(
    [switch]$Raw,
    [Parameter(ValueFromRemainingArguments = $true)]
    [object[]]$Args
  )

  $argList = Join-QuotedArgs -Args $Args
  $loader = Join-Path $script:AiWikiFragments.SearchRoot "scripts\Load-SearchEnv.ps1"
  $scriptText = @"
. '$loader' *> `$null
Clean $argList
"@
  Invoke-CommandWithSpinnerPolished -Kind "clean" -Label "Clean" -ScriptText $scriptText -Raw:$Raw
}
