$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$scriptPath = Join-Path $repoRoot "update-skill.ps1"
$script = Get-Content -LiteralPath $scriptPath -Raw

if ($script -notmatch 'cmd /c "openspec init"') {
    throw "Expected update-skill.ps1 to initialize OpenSpec projects with 'openspec init'."
}

if ($script -notmatch 'OpenSpec Project Initialized') {
    throw "Expected update-skill.ps1 to report OpenSpec project initialization."
}

Write-Host "update-skill static tests passed."
