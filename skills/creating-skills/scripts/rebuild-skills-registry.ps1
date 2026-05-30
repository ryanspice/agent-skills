param(
  [Parameter(Mandatory = $false)]
  [string]$AiWikiRoot = "<AI_WIKI_ROOT>"
)

$ErrorActionPreference = "Stop"

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptRoot "rebuild_skills_registry.py"

if (-not (Test-Path -LiteralPath $AiWikiRoot)) {
  throw "AI Wiki root missing: $AiWikiRoot"
}

if (-not (Test-Path -LiteralPath $PythonScript)) {
  throw "Registry Python script missing: $PythonScript"
}

python $PythonScript --ai-wiki-root $AiWikiRoot
