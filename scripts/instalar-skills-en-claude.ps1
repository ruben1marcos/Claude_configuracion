# Copia las skills de esta carpeta a la ubicacion oficial de Claude Code (~/.claude/skills)
$targetDir = "$HOME\.claude\skills"

if (!(Test-Path $targetDir)) {
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
}

$sourceSkills = Join-Path -Path $PSScriptRoot -ChildPath "..\skills\*.md"
Copy-Item -Path $sourceSkills -Destination $targetDir -Force

Write-Host "Skills instaladas correctamente en: $targetDir" -ForegroundColor Green
Get-ChildItem -Path $targetDir -Filter "*.md" | Select-Object Name
