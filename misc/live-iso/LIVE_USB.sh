#!/bin/bash

set -euo pipefail

echo -e "\n=== Available USB Devices ==="
lsblk -dpno NAME,SIZE,MODEL | cut -d' ' -f1 | sed 's/[0-9]*$//'

read -rp $'\nEnter the path to your USB device (e.g., /dev/sdX): ' USB_DEV
if [[ ! -b "$USB_DEV" ]]; then
    echo "Invalid block device: $USB_DEV" >&2
    exit 1
fi

read -rp "Enter the path to the ISO file: " ISO_FILE
if [[ ! -f "$ISO_FILE" ]]; then
    echo "ISO file not found: $ISO_FILE" >&2
    exit 1
fi

echo -e "\nYou are about to write:"
echo "  ISO : $ISO_FILE"
echo "  USB : $USB_DEV"
read -rp $'\nAre you absolutely sure? This will destroy all data on the USB! (yes/no): ' CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
    echo "Aborted."
    exit 1
fi

echo -e "\nWriting ISO to USB...\n"
sudo dd if="$ISO_FILE" of="$USB_DEV" bs=4M status=progress oflag=sync

sync
echo -e "\nDone. USB is ready."

