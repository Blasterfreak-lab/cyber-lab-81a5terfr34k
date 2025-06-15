# DefenderControlMenu.ps1
function Show-DefenderStatus {
    $realTime = Get-MpPreference | Select-Object -ExpandProperty DisableRealtimeMonitoring
    $status = if ($realTime) { "❌ Deaktiviert" } else { "✅ Aktiviert" }
    Write-Host "`n🔍 Aktueller Defender-Status: $status" -ForegroundColor Cyan
}

function Toggle-Defender {
    param (
        [bool]$Enable
    )

    if ($Enable) {
        Set-MpPreference -DisableRealtimeMonitoring $false
        Write-Host "`n🛡️ Windows Defender wurde aktiviert." -ForegroundColor Green
    } else {
        Set-MpPreference -DisableRealtimeMonitoring $true
        Write-Host "`n⚠️ Windows Defender wurde deaktiviert." -ForegroundColor Yellow
    }
}

function Show-Menu {
    Clear-Host
    Write-Host "🧰 Windows Defender Control Menu`n" -ForegroundColor Yellow
    Write-Host "1. Defender-Status anzeigen"
    Write-Host "2. Defender aktivieren"
    Write-Host "3. Defender deaktivieren"
    Write-Host "0. Beenden`n"
}

# Admin-Rechte prüfen
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "`n❌ Bitte PowerShell als Administrator starten!" -ForegroundColor Red
    Pause
    Exit
}

do {
    Show-Menu
    $choice = Read-Host "Bitte Auswahl treffen (0-3)"

    switch ($choice) {
        '1' {
            Show-DefenderStatus
            Pause
        }
        '2' {
            Toggle-Defender -Enable $true
            Pause
        }
        '3' {
            Toggle-Defender -Enable $false
            Pause
        }
        '0' {
            Write-Host "`n👋 Script beendet. Bleib sicher!" -ForegroundColor Green
        }
        default {
            Write-Host "`n❗ Ungültige Eingabe" -ForegroundColor Red
            Pause
        }
    }
} while ($choice -ne '0')