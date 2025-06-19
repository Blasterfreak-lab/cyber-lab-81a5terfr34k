#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "Dieses Script muss als root ausgeführt werden!"
  exit 1
fi

echo "🔍 Erkenne USB-Sticks..."
lsblk -o NAME,SIZE,MODEL | grep -E '^sd[b-z]' || {
  echo "❌ Kein USB-Stick gefunden!"
  exit 1
}

read -rp "➡️  Gib den Gerätenamen des USB-Sticks an (z. B. sdc): " dev
usb_dev="/dev/${dev// /}"  # Leerzeichen entfernen, falls reinkopiert

# Verifizieren
if [ ! -b "$usb_dev" ]; then
  echo "❌ Gerät $usb_dev nicht gefunden oder kein Blockgerät."
  exit 1
fi

read -rp "⚠️  ALLE Daten auf $usb_dev werden gelöscht. Fortfahren? (yes/no): " confirm
[[ "$confirm" != "yes" ]] && exit 0

echo "🧹 Überschreibe ersten Bereich..."
dd if=/dev/zero of="$usb_dev" bs=1M count=10 status=progress

echo "🧱 Erstelle neue Partitionstabelle..."
parted "$usb_dev" --script mklabel msdos
parted "$usb_dev" --script mkpart primary fat32 0% 100%

echo "🧷 Erstelle Dateisystem..."
mkfs.vfat -n USBSTICK "${usb_dev}1"

echo "✅ USB-Stick $usb_dev erfolgreich gereinigt und formatiert!"
