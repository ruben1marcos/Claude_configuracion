# Script para instalar/actualizar la funcion 'claude' en los perfiles de PowerShell
# Compatible con Windows PowerShell 5.1 y PowerShell 7+ (Core)
# Detecta automaticamente las rutas de Claude Code y OmniRoute en cualquier PC
# v2 - Hardened: manejo de errores, timeout de arranque mas largo, avisos de estado claros

$startMarker = "# >>> CLAUDE-OMNIROUTE-AUTOMATION START >>>"
$endMarker   = "# <<< CLAUDE-OMNIROUTE-AUTOMATION END <<<"

$functionCode = @"
$startMarker
function claude {
    `$port = if (`$env:OMNIROUTE_PORT) { [int]`$env:OMNIROUTE_PORT } else { 20128 }
    `$env:ANTHROPIC_BASE_URL = "http://localhost:`$port/v1"

    if (-not `$env:ANTHROPIC_API_KEY) {
        `$env:ANTHROPIC_API_KEY = "sk-omniroute"
    }
    if (-not `$env:ANTHROPIC_MODEL) {
        `$env:ANTHROPIC_MODEL = "auto/claude-sonnet"
    }

    # 1. Ejecutable real de Claude Code (excluye shims/wrappers de omniroute)
    `$claudePath = `$null
    try {
        `$claudePath = Get-Command claude.exe, claude.cmd, claude.ps1 -CommandType Application -ErrorAction SilentlyContinue |
            Where-Object { `$_.Source -notmatch 'omniroute' } |
            Select-Object -ExpandProperty Source -First 1
    } catch {}
    if (-not `$claudePath -or -not (Test-Path `$claudePath)) {
        `$claudeCandidates = @(
            "`$env:USERPROFILE\.local\bin\claude.exe",
            "`$env:APPDATA\npm\claude.cmd",
            "`$env:LOCALAPPDATA\Programs\claude\claude.exe",
            "`$env:ProgramFiles\Claude\claude.exe",
            "`$env:USERPROFILE\scoop\shims\claude.exe",
            "`$env:ALLUSERSPROFILE\chocolatey\bin\claude.exe"
        )
        foreach (`$c in `$claudeCandidates) {
            if (`$c -and (Test-Path `$c)) { `$claudePath = `$c; break }
        }
    }
    if (-not `$claudePath) {
        Write-Host "[Claude Automation] Error: no se encontro el ejecutable de Claude Code." -ForegroundColor Red
        Write-Host "Instalalo con: npm install -g @anthropic-ai/claude-code" -ForegroundColor Yellow
        return
    }

    # 2. Ejecutable de OmniRoute
    `$omniPath = `$null
    try {
        `$omniPath = Get-Command omniroute.cmd, omniroute.exe, omniroute.ps1 -CommandType Application -ErrorAction SilentlyContinue |
            Select-Object -ExpandProperty Source -First 1
    } catch {}
    if (-not `$omniPath -or -not (Test-Path `$omniPath)) {
        `$omniCandidates = @(
            "`$env:APPDATA\npm\omniroute.cmd",
            "`$env:USERPROFILE\.local\bin\omniroute.cmd",
            "`$env:USERPROFILE\scoop\shims\omniroute.cmd"
        )
        foreach (`$o in `$omniCandidates) {
            if (`$o -and (Test-Path `$o)) { `$omniPath = `$o; break }
        }
    }

    # 3. Comprobar si OmniRoute esta escuchando en el puerto (TCP real)
    function Test-OmniRoutePort {
        param([int]`$TimeoutMs = 800)
        `$client = `$null
        try {
            `$client = New-Object System.Net.Sockets.TcpClient
            `$iar = `$client.BeginConnect("127.0.0.1", `$port, `$null, `$null)
            if (`$iar.AsyncWaitHandle.WaitOne(`$TimeoutMs, `$false)) {
                `$client.EndConnect(`$iar)
                return `$true
            }
            return `$false
        } catch {
            return `$false
        } finally {
            if (`$client) { `$client.Close() }
        }
    }

    Write-Host "Verificando OmniRoute..." -ForegroundColor Cyan
    `$serverRunning = Test-OmniRoutePort

    # 4. Iniciar OmniRoute si no esta corriendo, con reintentos reales y avisos claros
    if (`$serverRunning) {
        Write-Host "OmniRoute ya esta activo. Enlazando con Claude Code..." -ForegroundColor Green
    } else {
        if (-not `$omniPath) {
            Write-Host "[Claude Automation] Aviso: OmniRoute no esta corriendo y no se encontro su ejecutable." -ForegroundColor Yellow
            Write-Host "Instalalo con: npm install -g omniroute" -ForegroundColor Yellow
        } else {
            Write-Host "Abriendo OmniRoute en segundo plano y enlazando..." -ForegroundColor Cyan
            try {
                Start-Process -FilePath `$omniPath -ArgumentList "serve" -WindowStyle Hidden -ErrorAction Stop
            } catch {
                Write-Host "[Claude Automation] No se pudo lanzar OmniRoute: `$(`$_.Exception.Message)" -ForegroundColor Red
            }

            `$maxWaitMs = 15000
            `$intervalMs = 400
            `$elapsed = 0
            while (`$elapsed -lt `$maxWaitMs -and -not `$serverRunning) {
                Start-Sleep -Milliseconds `$intervalMs
                `$elapsed += `$intervalMs
                `$serverRunning = Test-OmniRoutePort
            }

            if (-not `$serverRunning) {
                Write-Host "[Claude Automation] OmniRoute no respondio tras `$(`$maxWaitMs/1000)s." -ForegroundColor Red
                Write-Host "Verifica manualmente ejecutando 'omniroute serve' en otra terminal." -ForegroundColor Yellow
                Write-Host "Continuando de todos modos (la conexion puede fallar hasta que OmniRoute este listo)..." -ForegroundColor DarkYellow
            } else {
                Write-Host "OmniRoute listo y enlazado." -ForegroundColor Green
            }
        }
    }

    # 5. Ejecutar Claude Code con todos los argumentos pasados
    Write-Host "Abriendo Claude Code..." -ForegroundColor Cyan
    & `$claudePath @args
}
$endMarker
"@

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

    # Reemplazo idempotente: busca el bloque entre marcadores explicitos (soporta funciones anidadas)
    $blockPattern = [regex]::Escape($startMarker) + "(?ms).*?" + [regex]::Escape($endMarker)
    if ($content -match $blockPattern) {
        $updatedContent = [regex]::Replace($content, $blockPattern, { $functionCode.Trim() })
        Set-Content -Path $p -Value $updatedContent -Encoding utf8
        Write-Host "Configuracion actualizada exitosamente en: $p" -ForegroundColor Green
    } elseif ($content -match "(?ms)function claude \{.*") {
        # Instalacion previa sin marcadores (version antigua): reemplaza desde el header viejo hasta el final del archivo
        $legacyPattern = "(?ms)# =+\s*\n# OmniRoute.*"
        if ($content -match $legacyPattern) {
            $updatedContent = [regex]::Replace($content, $legacyPattern, { $functionCode.Trim() })
        } else {
            $updatedContent = $content + "`n`n" + $functionCode.Trim()
        }
        Set-Content -Path $p -Value $updatedContent -Encoding utf8
        Write-Host "Configuracion (version antigua) reemplazada en: $p" -ForegroundColor Green
    } else {
        Add-Content -Path $p -Value "`n$($functionCode.Trim())" -Encoding utf8
        Write-Host "Configuracion agregada exitosamente a: $p" -ForegroundColor Green
    }

    $errors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($p, [ref]$null, [ref]$errors) | Out-Null
    if ($errors.Count -gt 0) {
        Write-Host "ADVERTENCIA: error de sintaxis detectado en $p tras la instalacion:" -ForegroundColor Red
        $errors | ForEach-Object { Write-Host "  $($_.Message)" -ForegroundColor Red }
    }
}
