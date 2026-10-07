# Instala uv + notebooklm-mcp-cli y registra el MCP en Claude Code y Claude Desktop.
# No maneja credenciales: despues ejecuta 'nlm login' tu mismo en una PowerShell normal (no administrador).
$ErrorActionPreference = "Stop"
$binDir = "$HOME\.local\bin"
$mcpExe = Join-Path $binDir "notebooklm-mcp.exe"
$env:Path = "$binDir;$env:Path"

# 1. uv (instalador oficial de Astral)
if (!(Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host "Instalando uv..." -ForegroundColor Cyan
    powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
    $env:Path = "$binDir;$env:Path"
}

# 2. Paquete notebooklm-mcp-cli
Write-Host "Instalando notebooklm-mcp-cli..." -ForegroundColor Cyan
uv tool install notebooklm-mcp-cli
if (!(Test-Path $mcpExe)) { throw "No se encontro $mcpExe" }

# 3. Registro en Claude Code (alcance usuario)
$claude = Get-Command claude -ErrorAction SilentlyContinue
if ($claude) { $claudePath = $claude.Source }
else {
    $claudePath = Get-ChildItem "$env:APPDATA\Claude\claude-code" -Recurse -Filter "claude.exe" -ErrorAction SilentlyContinue |
        Sort-Object FullName -Descending | Select-Object -First 1 -ExpandProperty FullName
}
if ($claudePath) {
    & $claudePath mcp add --scope user gemini-notebook-mcp $mcpExe
} else {
    Write-Host "No se encontro 'claude'; registra el MCP manualmente en Claude Code." -ForegroundColor Yellow
}

# 4. Registro en Claude Desktop (conserva el resto de la configuracion, con copia .bak)
$cfg = "$env:APPDATA\Claude\claude_desktop_config.json"
if (Test-Path $cfg) {
    Copy-Item $cfg "$cfg.bak" -Force
    $json = Get-Content $cfg -Raw -Encoding UTF8 | ConvertFrom-Json
} else {
    New-Item -ItemType Directory -Force -Path (Split-Path $cfg) | Out-Null
    $json = [pscustomobject]@{}
}
$server = [pscustomobject]@{ command = $mcpExe }
if ($json.PSObject.Properties.Name -contains "mcpServers") {
    $json.mcpServers | Add-Member -NotePropertyName "gemini-notebook-mcp" -NotePropertyValue $server -Force
} else {
    $json | Add-Member -NotePropertyName "mcpServers" -NotePropertyValue ([pscustomobject]@{ "gemini-notebook-mcp" = $server })
}
$json | ConvertTo-Json -Depth 20 | Set-Content $cfg -Encoding UTF8

Write-Host ""
Write-Host "Listo. Pasos manuales pendientes:" -ForegroundColor Green
Write-Host "  1. En una PowerShell NORMAL (no administrador) ejecuta: nlm login  (elige la opcion 1)"
Write-Host "  2. Reinicia Claude Code / Claude Desktop"
Write-Host "  3. Comprueba con: nlm notebook list"
