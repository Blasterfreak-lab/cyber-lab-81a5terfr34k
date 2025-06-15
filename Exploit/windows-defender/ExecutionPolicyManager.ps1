# ExecutionPolicyManager.ps1
function Show-CurrentPolicy {
    Write-Host "`n🔍 Aktuelle Execution Policies:" -ForegroundColor Cyan
    Get-ExecutionPolicy -List | Format-Table -AutoSize
}

function Set-Policy {
    param (
        [string]$Scope,
        [string]$Policy
    )
    try {
        Set-ExecutionPolicy -Scope $Scope -ExecutionPolicy $Policy -Force
        Write-Host "`n✅ $Scope auf '$Policy' gesetzt." -ForegroundColor Green
    } catch {
        Write-Host "`n❌ Fehler beim Setzen: $_" -ForegroundColor Red
    }
}

function Show-Menu {
    Clear-Host
    Write-Host "🔧 Execution Policy Manager`n" -ForegroundColor Yellow
    Write-Host "1. Aktuelle Execution Policies anzeigen"
    Write-Host "2. Execution Policy setzen (z. B. Bypass, RemoteSigned, Restricted)"
    Write-Host "3. Zurücksetzen auf Standard (Restricted)"
    Write-Host "0. Beenden`n"
}

do {
    Show-Menu
    $choice = Read-Host "Bitte Auswahl treffen (0-3)"

    switch ($choice) {
        '1' {
            Show-CurrentPolicy
            Pause
        }
        '2' {
            Write-Host "`n🛠 Verfügbare Scopes: Process, CurrentUser, LocalMachine"
            $scope = Read-Host "Gewünschter Scope"
            Write-Host "🔐 Verfügbare Policies: Restricted, AllSigned, RemoteSigned, Unrestricted, Bypass"
            $policy = Read-Host "Gewünschte Execution Policy"
            Set-Policy -Scope $scope -Policy $policy
            Pause
        }
        '3' {
            Set-Policy -Scope LocalMachine -Policy Restricted
            Set-Policy -Scope CurrentUser -Policy Restricted
            Set-Policy -Scope Process -Policy Restricted
            Write-Host "`n🔁 Zurückgesetzt auf 'Restricted' für alle bekannten Scopes." -ForegroundColor Cyan
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
