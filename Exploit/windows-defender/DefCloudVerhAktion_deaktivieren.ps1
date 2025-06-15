# Starte PowerShell als Administrator

# 1. Defender in Echtzeitschutz deaktivieren
Set-MpPreference -DisableRealtimeMonitoring $true

# 2. Cloud-Schutz deaktivieren
Set-MpPreference -MAPSReporting 0
Set-MpPreference -SubmitSamplesConsent 2
Set-MpPreference -DisableBlockAtFirstSeen $true
Set-MpPreference -DisableIOAVProtection $true
Set-MpPreference -DisablePrivacyMode $true

# 3. Verhaltenserkennung und automatische Aktionen deaktivieren
Set-MpPreference -DisableBehaviorMonitoring $true
Set-MpPreference -DisableScriptScanning $true
Set-MpPreference -DisableIntrusionPreventionSystem $true
Set-MpPreference -DisableRemovableDriveScanning $true
Set-MpPreference -DisableArchiveScanning $true

Write-Host "[*] Windows Defender wurde temporär deaktiviert."
