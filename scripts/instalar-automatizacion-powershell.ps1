# Script para instalar/actualizar la funcion 'claude' en los perfiles de PowerShell
# Compatible con Windows PowerShell 5.1 y PowerShell 7+ (Core)
# Detecta automaticamente las rutas de Claude Code y OmniRoute en cualquier PC

$functionCode = @'

# ==========================================
# OmniRoute + Claude Code Zero-Friction (Auto-Detect)
# ==========================================
function claude {
    $port = if ($env:OMNIROUTE_PORT) { [int]$env:OMNIROUTE_PORT } else { 20128 }
    $env:ANTHROPIC_BASE_URL = "http://localhost:$port/v1"

    # Si no hay API Key configurada, establecer valor por defecto para el proxy local
    if (-not $env:ANTHROPIC_API_KEY) {
        $env:ANTHROPIC_API_KEY = "sk-omniroute"
    }

    # Modelo por defecto con prefijo de enrutamiento para OmniRoute (evita Error 400 Ambiguous Model)
    if (-not $env:ANTHROPIC_MODEL) {
        $env:ANTHROPIC_MODEL = "auto/claude-sonnet"
    }

    # 1. Buscar ejecutable real de Claude Code dinámicamente
    $claudePath = (Get-Command claude.exe, claude.cmd, claude.ps1 -CommandType Application -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1)
    if (-not $claudePath -or -not (Test-Path $claudePath)) {
        $claudeCandidates = @(
            "$env:USERPROFILE\.local\bin\claude.exe",
            "$env:APPDATA\npm\claude.cmd",
            "$env:LOCALAPPDATA\Programs\claude\claude.exe",
            "$env:ProgramFiles\Claude\claude.exe",
            "$env:USERPROFILE\scoop\shims\claude.exe",
            "$env:ALLUSERSPROFILE\chocolatey\bin\claude.exe"
        )
        foreach ($c in $claudeCandidates) {
            if ($c -and (Test-Path $c)) {
                $claudePath = $c
                break
            }
        }
    }

    if (-not $claudePath) {
        Write-Host "[Claude Automation] Error: No se encontró el ejecutable de Claude Code en el sistema." -ForegroundColor Red
        Write-Host "Instálalo ejecutando: npm install -g @anthropic-ai/claude-code" -ForegroundColor Yellow
        return
    }

    # 2. Buscar ejecutable de OmniRoute
    $omniPath = (Get-Command omniroute.cmd, omniroute.exe, omniroute.ps1 -CommandType Application -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1)
    if (-not $omniPath -or -not (Test-Path $omniPath)) {
        $omniCandidates = @(
            "$env:APPDATA\npm\omniroute.cmd",
            "$env:USERPROFILE\.local\bin\omniroute.cmd",
            "$env:USERPROFILE\scoop\shims\omniroute.cmd"
        )
        foreach ($o in $omniCandidates) {
            if ($o -and (Test-Path $o)) {
                $omniPath = $o
                break
            }
        }
    }

    # 3. Comprobar si OmniRoute está escuchando en el puerto
    $serverRunning = $false
    $testPort = {
        try {
            $client = New-Object System.Net.Sockets.TcpClient
            $iar = $client.BeginConnect("127.0.0.1", $port, $null, $null)
            if ($iar.AsyncWaitHandle.WaitOne(300, $false) -and $client.Connected) {
                $client.EndConnect($iar)
                $client.Close()
                return $true
            }
            $client.Close()
        } catch {}
        return $false
    }

    $serverRunning = & $testPort

    # 4. Iniciar OmniRoute si no está corriendo
    if (-not $serverRunning -and $omniPath) {
        Write-Host "Iniciando OmniRoute en segundo plano..." -ForegroundColor Cyan
        Start-Process -FilePath $omniPath -ArgumentList "serve" -WindowStyle Hidden -ErrorAction SilentlyContinue

        $elapsed = 0
        while ($elapsed -lt 4000 -and -not $serverRunning) {
            Start-Sleep -Milliseconds 300
            $elapsed += 300
            $serverRunning = & $testPort
        }
    }

    # 5. Ejecutar Claude Code con todos los argumentos pasados
    & $claudePath @args
}
'@

$targetProfiles = @(
    $PROFILE,
    "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1",
    "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
) | Select-Object -Unique

# Configurar automaticamente ~/.omniroute/.env para evitar Error 401 (x-api-key vs Bearer)
$omniDir = "$env:USERPROFILE\.omniroute"
$omniEnvFile = "$omniDir\.env"
if (-not (Test-Path $omniDir)) {
    New-Item -ItemType Directory -Force -Path $omniDir | Out-Null
}
if (Test-Path $omniEnvFile) {
    $envContent = Get-Content -Path $omniEnvFile -Raw -ErrorAction SilentlyContinue
    if (-not $envContent) { $envContent = "" }
    if ($envContent -notmatch "REQUIRE_API_KEY\s*=") {
        Add-Content -Path $omniEnvFile -Value "`nREQUIRE_API_KEY=false" -Encoding utf8
        Write-Host "Configurado REQUIRE_API_KEY=false en: $omniEnvFile" -ForegroundColor Green
    } elseif ($envContent -match "REQUIRE_API_KEY\s*=\s*true") {
        $envContent = $envContent -replace "REQUIRE_API_KEY\s*=\s*true", "REQUIRE_API_KEY=false"
        Set-Content -Path $omniEnvFile -Value $envContent -Encoding utf8
        Write-Host "Actualizado REQUIRE_API_KEY=false en: $omniEnvFile" -ForegroundColor Green
    }
} else {
    Set-Content -Path $omniEnvFile -Value "REQUIRE_API_KEY=false" -Encoding utf8
    Write-Host "Creado archivo .env con REQUIRE_API_KEY=false en: $omniEnvFile" -ForegroundColor Green
}

foreach ($p in $targetProfiles) {
    if (-not (Test-Path $p)) {
        $parentDir = Split-Path -Parent $p
        if (-not (Test-Path $parentDir)) {
            New-Item -ItemType Directory -Force -Path $parentDir | Out-Null
        }
        New-Item -ItemType File -Path $p -Force | Out-Null
    }

    $content = Get-Content -Path $p -Raw -ErrorAction SilentlyContinue
    if (-not $content) { $content = "" }

    # Si ya existe una versión previa de la función claude, reemplazarla limpiamente
    if ($content -match "(?ms)# ==========================================.*?function claude \{.*?\n\}") {
        $updatedContent = $content -replace "(?ms)# ==========================================.*?function claude \{.*?\n\}", $functionCode.Trim()
        Set-Content -Path $p -Value $updatedContent -Encoding utf8
        Write-Host "Configuracion actualizada exitosamente en: $p" -ForegroundColor Green
    } elseif ($content -match "(?ms)function claude \{.*?\n\}") {
        $updatedContent = $content -replace "(?ms)function claude \{.*?\n\}", $functionCode.Trim()
        Set-Content -Path $p -Value $updatedContent -Encoding utf8
        Write-Host "Configuracion actualizada exitosamente en: $p" -ForegroundColor Green
    } else {
        Add-Content -Path $p -Value "`n$functionCode" -Encoding utf8
        Write-Host "Configuracion agregada exitosamente a: $p" -ForegroundColor Green
    }
}

