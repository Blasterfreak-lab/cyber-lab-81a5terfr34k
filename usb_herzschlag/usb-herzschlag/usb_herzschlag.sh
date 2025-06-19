#!/bin/bash
# usb_herzschlag.sh – CLI-Tool zur Diagnose und Reparatur von USB-Sticks
# Version 1.0

LOG_DIR="$HOME/usb-herzschlag/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/usbtriage_$(date +%Y%m%d_%H%M%S).log"

echo "[INFO] Starte USB-Herzschlag CLI" | tee -a "$LOG_FILE"

if [[ $EUID -ne 0 ]]; then
  echo "Bitte mit root-Rechten ausführen!" | tee -a "$LOG_FILE"
  exit 1
fi

echo "[INFO] Verfügbare USB-Geräte:" | tee -a "$LOG_FILE"
lsblk -o NAME,SIZE,MODEL | grep -E '^sd[b-z]' | tee -a "$LOG_FILE"

read -rp "Gerätename (z. B. sdc): " dev
dev="/dev/$dev"

if [ ! -b "$dev" ]; then
  echo "[ERROR] Gerät $dev nicht gefunden." | tee -a "$LOG_FILE"
  exit 1
fi

echo "[INFO] Schreibe 1MB Nullen zur Prüfung..." | tee -a "$LOG_FILE"
dd if=/dev/zero of="$dev" bs=1M count=1 status=progress >> "$LOG_FILE" 2>&1

echo "[INFO] Partitionstabelle wird erstellt..." | tee -a "$LOG_FILE"
parted "$dev" --script mklabel msdos
parted "$dev" --script mkpart primary fat32 0% 100%

echo "[INFO] Formatiere Partition..." | tee -a "$LOG_FILE"
mkfs.vfat -n USBHERZSCHLAG "${dev}1" >> "$LOG_FILE" 2>&1

echo "[SUCCESS] USB-Stick erfolgreich bearbeitet." | tee -a "$LOG_FILE"
