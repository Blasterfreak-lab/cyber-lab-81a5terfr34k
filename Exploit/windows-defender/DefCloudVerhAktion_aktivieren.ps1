# PowerShell als Administrator ausführen!

# Echtzeitschutz aktivieren
Set-MpPreference -DisableRealtimeMonitoring $false

# Cloud-Schutz aktivieren
Set-MpPreference -MAPSReporting 2
Set-MpPreference -SubmitSamplesConsent 1
Set-MpPreference -DisableBlockAtFirstSeen $false
Set-MpPreference -DisableIOAVProtection $false
Set-MpPreference -DisablePrivacyMode $false

# Verhaltenserkennung und Script-Scanning aktivieren
Set-MpPreference -DisableBehaviorMonitoring $false
Set-MpPreference -DisableScriptScanning $false
Set-MpPreference -DisableIntrusionPreventionSystem $false
Set-MpPreference -DisableRemovableDriveScanning $false
Set-MpPreference -DisableArchiveScanning $false

# Optional: Geplante Überprüfungen wieder aktivieren
Set-MpPreference -ScanScheduleDay 0
Set-MpPreference -ScanScheduleTime 120

Write-Host "[+] Windows Defender wurde vollständig reaktiviert."
