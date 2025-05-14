#!/bin/bash

set -euo pipefail

# -- ISO definitions
declare -A ISO_URLS=(
  [alpine]="https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86_64/alpine-extended-3.21.3-x86_64.iso"
  [debian]="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.10.0-amd64-netinst.iso"
  [antix]="https://sourceforge.net/projects/antix-linux/files/Final/antiX-23.2/runit-antiX-23.2/antiX-23.2-runit_x64-core.iso/download"
)

declare -A SHA_URLS=(
  [alpine]="https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86_64/alpine-extended-3.21.3-x86_64.iso.sha256"
  [debian]="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS"
  [antix]="https://sourceforge.net/projects/antix-linux/files/Final/antiX-23.2/runit-antiX-23.2/antiX-23.2-runit_x64-core.iso.sha256/download"
)

TMPDIR=$(mktemp -d)
cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

# -- Select OS
os=$(zenity --list --title="Select ISO" --column="ID" --column="Distribution" \
  alpine "Alpine Linux (Extended)" \
  debian "Debian NetInstall" \
  antix "antiX Core (runit)" \
  --height=250 --width=400
) || exit 1

iso_url="${ISO_URLS[$os]}"
sha_url="${SHA_URLS[$os]}"
iso_file="$TMPDIR/${iso_url##*/}"
sha_file="$TMPDIR/${sha_url##*/}"

# -- Download ISO
(
  curl -L "$iso_url" -o "$iso_file" --progress-bar
) | zenity --progress --pulsate --auto-close --title="Downloading ISO" --text="Fetching $os..."

# -- Download SHA256
curl -L "$sha_url" -o "$sha_file"

# -- Verify SHA256
(
  cd "$TMPDIR"
  if [[ "$os" == "debian" ]]; then
    grep "$(basename "$iso_file")" "$sha_file" | sha256sum -c -
  else
    sha256sum -c "$sha_file"
  fi
) || zenity --error --text="SHA256 verification failed" && exit 1

zenity --info --text="ISO Verified Successfully"

# -- List USB Devices
usb_menu=()
while IFS= read -r line; do
  dev=$(awk '{print $1}' <<< "$line")
  label=$(cut -d' ' -f2- <<< "$line")
  usb_menu+=("$dev" "$label" FALSE)
done < <(lsblk -dpno NAME,SIZE,MODEL | grep -v "$(findmnt -n / | cut -d' ' -f1 | sed 's/[0-9]*$//')")

selected=$(zenity --list --checklist --title="Select USB Devices" \
  --column="Select" --column="Device" --column="Label" \
  "${usb_menu[@]}" --multiple --separator=" ")

[[ -z "$selected" ]] && zenity --error --text="No USB device selected" && exit 1

zenity --question --text="You selected:\n$selected\n\nWrite ISO now? All data will be erased." || exit 1

# -- Write ISO
for dev in $selected; do
  (
    echo "# Writing to $dev"
    sudo dd if="$iso_file" of="$dev" bs=4M status=progress oflag=sync
    sync
  ) | zenity --progress --auto-close --title="Writing ISO" --text="Writing to $dev"
done

zenity --info --text="✅ ISO written successfully to all selected devices."

