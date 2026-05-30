# AI Wiki command fragments pretty output layer v0.2.0
# Loaded after main + polish + output polish layers.

if (-not $script:AiWikiFragments) {
  throw "Load-AiWikiCommandFragments.ps1 must be loaded before the pretty output layer."
}

function Write-Part {
  param(
    [string]$Text,
    [string]$Color = "Gray",
    [switch]$NoNewline
  )

  if ($NoNewline) {
    Write-Host -NoNewline $Text -ForegroundColor $Color
  } else {
    Write-Host $Text -ForegroundColor $Color
  }
}

function Write-KvLine {
  param(
    [string]$Key,
    [string]$Value,
    [string]$ValueColor = "Gray"
  )

  Write-Part ("  " + $Key.PadRight(8)) -Color "DarkGray" -NoNewline
  Write-Part $Value -Color $ValueColor
}

function Write-SearchMatchLine {
  param([string]$Line)

  if ($Line -match "^\s*(#\d+)\s+(L\d+:\d+)\s+\[([^\]]+)\]\s?(.*)$") {
    Write-Part ("     " + $Matches[1] + " ") -Color "DarkGray" -NoNewline
    Write-Part ($Matches[2] + " ") -Color "DarkYellow" -NoNewline
    Write-Part ("[" + $Matches[3] + "] ") -Color "DarkGray" -NoNewline

    $body = $Matches[4]
    if ($body -match "^\s*---\s*$") {
      Write-Part $body -Color "DarkGray"
    } elseif ($body -match "^\s*#") {
      Write-Part $body -Color "Cyan"
    } elseif ($body -match "^\s*(title|project|version|status|type|skill|client):") {
      Write-Part $body -Color "DarkCyan"
    } else {
      Write-Part $body -Color "Gray"
    }
    return $true
  }

  return $false
}

function Write-PrettySearchOutput {
  param([string]$Text)

  if (-not $Text) { return }

  $text = Clean-CommandOutputText -Text $Text
  if (-not $text) { return }

  $lines = $text -split "`r?`n"
  $printedBlank = $false

  foreach ($raw in $lines) {
    $line = $raw.TrimEnd()

    if ([string]::IsNullOrWhiteSpace($line)) {
      if (-not $printedBlank) {
        Write-Host ""
        $printedBlank = $true
      }
      continue
    }

    $printedBlank = $false

    if ($line -match "^\s*Search ready in\s+(.+)$") {
      Write-Part ("Search ready in " + $Matches[1]) -Color "Green"
      continue
    }

    if ($line -match "^\s*Index complete in\s+(.+)$") {
      Write-Part ("Index complete in " + $Matches[1]) -Color "Green"
      continue
    }

    if ($line -match "^\s*(manifest)\s+(.+)$") {
      Write-KvLine -Key $Matches[1] -Value $Matches[2] -ValueColor "DarkCyan"
      continue
    }

    if ($line -match "^\s*(elastic)\s+(.+)$") {
      $color = if ($Matches[2] -match "errors.: False|indexed.: True") { "Green" } else { "Yellow" }
      Write-KvLine -Key $Matches[1] -Value $Matches[2] -ValueColor $color
      continue
    }

    if ($line -match "^\s*(query|engine|profile|matched|root|tried|note)\s*(.*)$") {
      $key = $Matches[1]
      $value = $Matches[2].Trim()
      $color = "Gray"
      if ($key -eq "matched") { $color = "Green" }
      elseif ($key -eq "tried") {
        $color = if ($value -match "Error|unavailable|not found") { "Yellow" } else { "DarkCyan" }
      }
      elseif ($key -eq "note") { $color = "DarkYellow" }
      elseif ($key -eq "root") { $color = "DarkCyan" }
      elseif ($key -eq "engine" -or $key -eq "profile") { $color = "Cyan" }
      Write-KvLine -Key $key -Value $value -ValueColor $color
      continue
    }

    if ($line -match "^\s*(\.\.\\AI-Wiki\\.*)\s+\((.+)\)\s*$") {
      Write-Host ""
      Write-Part $Matches[1] -Color "Cyan" -NoNewline
      Write-Part ("  (" + $Matches[2] + ")") -Color "DarkCyan"
      continue
    }

    if ($line -match "^\s*lower-signal\s*/\s*generated-index noise\s+\((.+)\)\s*$") {
      Write-Host ""
      Write-Part ("  lower-signal / generated-index noise (" + $Matches[1] + ")") -Color "DarkYellow"
      continue
    }

    if ($line -match "^\s*([^\s].*?)\s+(\d+\s+hits)\s*$") {
      Write-Part ("   " + $Matches[1] + "  ") -Color "White" -NoNewline
      Write-Part $Matches[2] -Color "DarkCyan"
      continue
    }

    if ($line -match "^\s*\+(\d+)\s+more matches\s*$") {
      Write-Part ("     +" + $Matches[1] + " more matches") -Color "DarkGray"
      continue
    }

    if (Write-SearchMatchLine -Line $line) { continue }

    if ($line -match "Error|WARN|unavailable|not found|IPC") {
      Write-Part $line -Color "Yellow"
      continue
    }

    Write-Part $line -Color "Gray"
  }
}

function Write-PrettyGenericOutput {
  param([string]$Text)

  if (-not $Text) { return }
  $text = Clean-CommandOutputText -Text $Text
  if (-not $text) { return }

  foreach ($line in ($text -split "`r?`n")) {
    if ($line -match "OK |complete|indexed.: True|errors.: False") {
      Write-Part $line -Color "Green"
    } elseif ($line -match "Error|WARN|unavailable|failed|not found") {
      Write-Part $line -Color "Yellow"
    } elseif ($line -match "^\s*(manifest|elastic|matched|tried|note)\s+") {
      Write-Part $line -Color "DarkCyan"
    } else {
      Write-Part $line -Color "Gray"
    }
  }
}

function Write-CleanOutput {
  param(
    [string]$Path,
    [string]$Color = "Gray",
    [switch]$Raw
  )

  if (-not (Test-Path $Path)) { return }

  $text = Get-Content -Path $Path -Raw -Encoding UTF8
  $text = Convert-ToConsoleSafe -Text $text
  if (-not $text) { return }

  if ($Raw) {
    $clean = Clean-CommandOutputText -Text $text -Raw
    if ($clean) { Write-Host $clean.TrimEnd() -ForegroundColor $Color }
    return
  }

  if ($text -match "Search ready|matched\s+\d+\s+hits|lower-signal / generated-index noise") {
    Write-PrettySearchOutput -Text $text
    return
  }

  Write-PrettyGenericOutput -Text $text
}

function Use-Search {
  param(
    [string]$SearchRoot = $script:AiWikiFragments.SearchRoot,
    [switch]$NoServiceStart,
    [switch]$VerboseServices
  )

  $loader = Join-Path $SearchRoot "scripts\Load-SearchEnv.ps1"
  if (-not (Test-Path $loader)) {
    throw ("Search loader not found: " + $loader)
  }

  . $loader *> $null

  if (-not $NoServiceStart) {
    Ensure-SearchServicesQuiet -VerboseServices:$VerboseServices
  }

  if ($VerboseServices) {
    Write-Host "Search environment loaded. Wrapper commands remain active in this session." -ForegroundColor Green
  }
}

function Use-AiWikiSearch {
  param(
    [string]$SearchRoot = $script:AiWikiFragments.SearchRoot,
    [switch]$NoServiceStart,
    [switch]$VerboseServices
  )

  Use-Search -SearchRoot $SearchRoot -NoServiceStart:$NoServiceStart -VerboseServices:$VerboseServices
}

function Use-Run {
  param(
    [switch]$WithSearch,
    [switch]$NoServiceStart,
    [switch]$Quiet,
    [switch]$VerboseServices
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
    Use-Search -NoServiceStart:$NoServiceStart -VerboseServices:$VerboseServices
  }
}

function Use-AiWikiRun {
  param(
    [switch]$WithSearch,
    [switch]$NoServiceStart,
    [switch]$Quiet,
    [switch]$VerboseServices
  )

  Use-Run -WithSearch:$WithSearch -NoServiceStart:$NoServiceStart -Quiet:$Quiet -VerboseServices:$VerboseServices
}
