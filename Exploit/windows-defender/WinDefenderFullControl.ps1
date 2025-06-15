# DefenderFullControlWithTamperCheck.ps1

function Show-Status {
    Write-Host "`n🛡️ Aktueller Defender-Status:" -ForegroundColor Cyan
    $prefs = Get-MpPreference
    $map = @("Nicht beigetreten", "Basis", "Erweitert")[$prefs.MAPSReporting]
    $submit = @("Fragen", "Automatisch", "Nie", "Immer")[$prefs.SubmitSamplesConsent]

    $flags = @{
        "Echtzeitschutz" = !$prefs.DisableRealtimeMonitoring
        "Cloud-Schutz (MAPS)" = $map
        "Sample Consent" = $submit
        "BlockAtFirstSeen" = !$prefs.DisableBlockAtFirstSeen
        "IOAV-Schutz" = !$prefs.DisableIOAVProtection
        "Privatsphärenmodus" = !$prefs.DisablePrivacyMode
        "Verhaltensüberwachung" = !$prefs.DisableBehaviorMonitoring
        "Script-Scan" = !$prefs.DisableScriptScanning
        "IPS" = !$prefs.DisableIntrusionPreventionSystem
        "USB-Scan" = !$prefs.DisableRemovableDriveScanning
        "Archiv-Scan" = !$prefs.DisableArchiveScanning
    }

    foreach ($item in $flags.GetEnumerator()) {
        $status = if ($item.Value -eq $false -or $item.Value -eq "Nie" -or $item.Value -eq "Nicht beigetreten") {
            Write-Host ("❌ {0}: {1}" -f $item.Key, $item.Value) -ForegroundColor Red
        } else {
            Write-Host ("✅ {0}: {1}" -f $item.Key, $item.Value) -ForegroundColor Green
        }
    }
}

function Is-TamperProtectionEnabled {
    try {
        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features"
        $value = Get-ItemProperty -Path $regPath -Name TamperProtection -ErrorAction Stop
        return ($value.TamperProtection -eq 1)
    } catch {
        return $false
    }
}

function Apply-DefenderProfile {
    param (
        [string]$Mode
    )

    if (Is-TamperProtectionEnabled) {
        Write-Host "`n⚠️  Tamper Protection ist AKTIV – Änderungen per Skript werden BLOCKIERT!" -ForegroundColor Red
        Write-Host "🛑 Bitte in der Windows-Sicherheit manuell deaktivieren: Viren- & Bedrohungsschutz > Einstellungen verwalten > Manipulationsschutz" -ForegroundColor Yellow
        return
    }

    if ($Mode -eq "Standard") {
        Set-MpPreference -DisableRealtimeMonitoring $false
        Set-MpPreference -MAPSReporting 2
        Set-MpPreference -SubmitSamplesConsent 1
        Set-MpPreference -DisableBlockAtFirstSeen $false
        Set-MpPreference -DisableIOAVProtection $false
        Set-MpPreference -DisablePrivacyMode $false
        Set-MpPreference -DisableBehaviorMonitoring $false
        Set-MpPreference -DisableScriptScanning $false
        Set-MpPreference -DisableIntrusionPreventionSystem $false
        Set-MpPreference -DisableRemovableDriveScanning $false
        Set-MpPreference -DisableArchiveScanning $false
        Write-Host "`n✅ Defender auf STANDARD-Modus gesetzt." -ForegroundColor Green
    }
    elseif ($Mode -eq "Test") {
        Set-MpPreference -DisableRealtimeMonitoring $true
        Set-MpPreference -MAPSReporting 0
        Set-MpPreference -SubmitSamplesConsent 2
        Set-MpPreference -DisableBlockAtFirstSeen $true
        Set-MpPreference -DisableIOAVProtection $true
        Set-MpPreference -DisablePrivacyMode $true
        Set-MpPreference -DisableBehaviorMonitoring $true
        Set-MpPreference -DisableScriptScanning $true
        Set-MpPreference -DisableIntrusionPreventionSystem $true
        Set-MpPreference -DisableRemovableDriveScanning $true
        Set-MpPreference -DisableArchiveScanning $true
        Write-Host "`n⚠️ Defender auf TESTMODUS gesetzt – Schutz reduziert!" -ForegroundColor Yellow
    }
}

function Show-Menu {
    Clear-Host
    Write-Host "🧰 Windows Defender Control Panel (mit Tamper-Check)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Defender-Status anzeigen"
    Write-Host "2. Standard-Modus aktivieren (voller Schutz)"
    Write-Host "3. Testmodus aktivieren (alles deaktivieren)"
    Write-Host "0. Beenden"
}

# Admin-Prüfung
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "`n❌ Dieses Skript muss als Administrator ausgeführt werden." -ForegroundColor Red
    Pause
    Exit
}

do {
    Show-Menu
    $choice = Read-Host "`nBitte Auswahl treffen (0-3)"

    switch ($choice) {
        '1' {
            Show-Status
            Pause
        }
        '2' {
            Apply-DefenderProfile -Mode "Standard"
            Pause
        }
        '3' {
            Apply-DefenderProfile -Mode "Test"
            Pause
        }
        '0' {
            Write-Host "`n👋 Tschüss! Bleib sicher." -ForegroundColor Green
        }
        default {
            Write-Host "`n❗ Ungültige Eingabe." -ForegroundColor Red
            Pause
        }
    }
} while ($choice -ne '0')
