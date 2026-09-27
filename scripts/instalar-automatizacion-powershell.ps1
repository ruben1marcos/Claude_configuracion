# Script para instalar la función 'claude' en el perfil de PowerShell
# Compatible con Windows PowerShell 5.1 y PowerShell Core 7+

$profilePath = $PROFILE
if (!(Test-Path $profilePath)) {
    $parentDir = Split-Path -Parent $profilePath
    if (!(Test-Path $parentDir)) {
        New-Item -ItemType Directory -Force -Path $parentDir | Out-Null
    }
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

$functionCode = @'

# ==========================================
# OmniRoute + Claude Code Zero-Friction
# ==========================================
function claude {
    $port = 20128
    $serverRunning = $false

    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $iar = $client.BeginConnect("127.0.0.1", $port, $null, $null)
        if ($iar.AsyncWaitHandle.WaitOne(500, $false) -and $client.Connected) {
            $client.EndConnect($iar)
            $serverRunning = $true
        }
        $client.Close()
    } catch {
        $serverRunning = $false
    }

    if (-not $serverRunning) {
        Write-Host "Iniciando OmniRoute en segundo plano..." -ForegroundColor Cyan
        Start-Process -FilePath "omniroute.cmd" -ArgumentList "serve" -WindowStyle Hidden -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
    }

    & omniroute.cmd launch -- $args
}
'@

$existingContent = Get-Content -Path $profilePath -Raw -ErrorAction SilentlyContinue
if ($existingContent -notmatch "function claude") {
    Add-Content -Path $profilePath -Value $functionCode
    Write-Host "Configuracion agregada exitosamente a: $profilePath" -ForegroundColor Green
} else {
    Write-Host "La funcion 'claude' ya estaba configurada en tu perfil." -ForegroundColor Yellow
}
