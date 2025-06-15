# SynFloodProtectionCheckSet.ps1
Write-Host "🔍 Überprüfe aktuelle TCP/IP-Schutzparameter..." -ForegroundColor Cyan

# Registry-Pfad
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"

# Empfohlene Einstellungen
$recommendedValues = @{
    "SynAttackProtect"        = 2
    "TcpMaxHalfOpen"          = 100
    "TcpMaxHalfOpenRetried"   = 80
    "TcpMaxPortsExhausted"    = 5
}

$changesMade = $false

foreach ($key in $recommendedValues.Keys) {
    $currentValue = Get-ItemProperty -Path $regPath -Name $key -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $key -ErrorAction SilentlyContinue
    $recommended = $recommendedValues[$key]

    if ($currentValue -ne $recommended) {
        Write-Host "`n⚠️  $key ist aktuell: $currentValue (soll: $recommended)" -ForegroundColor Yellow
        Write-Host "➕ Setze $key auf $recommended..." -ForegroundColor Green
        New-ItemProperty -Path $regPath -Name $key -Value $recommended -PropertyType DWord -Force | Out-Null
        $changesMade = $true
    } else {
        Write-Host "✅ $key ist korrekt gesetzt ($recommended)" -ForegroundColor Green
    }
}

if ($changesMade) {
    Write-Host "`n🔁 Änderungen vorgenommen. Ein Neustart wird empfohlen, damit alle Werte wirksam werden." -ForegroundColor Magenta
} else {
    Write-Host "`n✅ Alle empfohlenen Schutzmechanismen sind bereits aktiv." -ForegroundColor Cyan
}
