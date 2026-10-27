param(
  [string] $SkillRoot = (Split-Path -Parent $PSScriptRoot),
  [switch] $IncludeReferences
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $SkillRoot -PathType Container)) {
  throw "SkillRoot not found: $SkillRoot"
}

$SkillPath = Join-Path $SkillRoot 'SKILL.md'
if (-not (Test-Path -LiteralPath $SkillPath -PathType Leaf)) {
  throw "SKILL.md not found: $SkillPath"
}

$parts = New-Object System.Collections.Generic.List[string]
$parts.Add("# Skill Context")
$parts.Add("")
$parts.Add("Source: $SkillRoot")
$parts.Add("")
$parts.Add("## SKILL.md")
$parts.Add('```markdown')
$parts.Add((Get-Content -LiteralPath $SkillPath -Raw))
$parts.Add('```')

if ($IncludeReferences) {
  $ReferenceRoot = Join-Path $SkillRoot 'reference'
  if (Test-Path -LiteralPath $ReferenceRoot -PathType Container) {
    Get-ChildItem -LiteralPath $ReferenceRoot -Filter '*.md' | Sort-Object Name | ForEach-Object {
      $parts.Add("")
      $parts.Add("## reference/$($_.Name)")
      $parts.Add('```markdown')
      $parts.Add((Get-Content -LiteralPath $_.FullName -Raw))
      $parts.Add('```')
    }
  }
}

$text = ($parts -join [Environment]::NewLine)
Set-Clipboard -Value $text
Write-Host "Copied skill context to clipboard. Characters: $($text.Length)"
