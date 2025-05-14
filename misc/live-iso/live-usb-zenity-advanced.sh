#!/bin/bash
set -euo pipefail

declare -A ISO_URLS=(
  [alpine]="https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86_64/alpine-extended-3.21.3-x86_64.iso"
  [debian]="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.10.0-amd64-netinst.iso"
  [antix]="https://sourceforge.net/projects/antix-linux/files/Final/antiX-23.2/runit-antiX-23.2/antiX-23.2-runit_x64-core.iso/download"
  [mx]="https://ixpeering.dl.sourceforge.net/project/mx-linux/Final/Xfce/MX-23.6_x64.iso"
  [parrot]="https://bunny.deb.parrot.sh//parrot/iso/6.3.2/Parrot-home-6.3.2_amd64.iso"
  [kali]="https://gsl-syd.mm.fcix.net/kali-images/kali-2025.1a/kali-linux-2025.1a-installer-amd64.iso"
)

declare -A SHA_URLS=(
  [alpine]="https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86_64/alpine-extended-3.21.3-x86_64.iso.sha256"
  [debian]="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS"
  [antix]="https://sourceforge.net/projects/antix-linux/files/Final/antiX-23.2/runit-antiX-23.2/antiX-23.2-runit_x64-core.iso.sha256/download"
  [mx]="https://ixpeering.dl.sourceforge.net/project/mx-linux/Final/Xfce/MX-23.6_x64.iso.sha256"
  [parrot]="https://bunny.deb.parrot.sh//parrot/iso/6.3.2/Parrot-home-6.3.2_amd64.iso.sha256"
  [kali]="https://gsl-syd.mm.fcix.net/kali-images/kali-2025.1a/kali-linux-2025.1a-installer-amd64.iso.sha256"
)

BASEDIR="/media/batan/100/ISO/new"
#cleanup() { rm -rf "$BASEDIR"; }
#trap cleanup EXIT

# --- Select ISO Source ---
choice=$(zenity --list --title="ISO Source" --column="Option" --column="Description" \
  list "Choose from known minimal OS list" \
  local "Use a local ISO file" \
  custom "Enter a custom ISO URL" \
  --width=400 --height=250) || exit 1

case "$choice" in
  list)
    os=$(zenity --list --title="Select ISO" --column="ID" --column="Distribution" \
      alpine "Alpine Linux (Extended)" \
      debian "Debian NetInstall" \
      antix "antiX Core (runit)" \
      mx "MX Linux xfce4 23.6" \
      parrot "Parrot Home 6.3.2" \
      --height=250 --width=400) || exit 1
    iso_url="${ISO_URLS[$os]}"
    sha_url="${SHA_URLS[$os]}"
    iso_file="$BASEDIR/${iso_url##*/}"
    sha_file="$BASEDIR/${sha_url##*/}"

    (
      curl -L "$iso_url" -o "$iso_file" --progress-bar
    ) | zenity --progress --pulsate --auto-close --title="Downloading ISO" --text="Fetching $os..."

    if curl -fL "$sha_url" -o "$sha_file"; then
      cd "$BASEDIR"
      if [[ "$os" == "debian" ]]; then
        grep "$(basename "$iso_file")" "$sha_file" | sha256sum -c - || \
          zenity --error --text="SHA256 verification failed." && exit 1
      else
        sha256sum -c "$sha_file" || zenity --error --text="SHA256 verification failed." && exit 1
      fi
      zenity --info --text="ISO verified successfully"
    else
      zenity --warning --text="Checksum not found, proceeding without verification."
    fi
    ;;
  local)
    iso_file=$(zenity --file-selection --title="Select ISO") || exit 1
    ;;
  custom)
    iso_url=$(zenity --entry --title="Custom ISO URL" --text="Enter direct ISO URL:")
    iso_file="$BASEDIR/${iso_url##*/}"
    (
      curl -L "$iso_url" -o "$iso_file" --progress-bar
    ) | zenity --progress --pulsate --auto-close --title="Downloading Custom ISO" --text="Fetching ISO..."
    zenity --warning --text="No checksum provided for custom ISO. Proceeding without verification."
    ;;
esac

# --- USB Selection ---
usb_menu=()
while IFS= read -r line; do
  dev=$(awk '{print $1}' <<< "$line")
  label=$(cut -d' ' -f2- <<< "$line")
  usb_menu+=("$dev" "$label" FALSE)
done < <(lsblk -dpno NAME,SIZE,MODEL | cut -d' ' -f1 | sed 's/[0-9]*$//')

selected=$(zenity --list --checklist --title="Select USB Devices" \
  --column="Select" --column="Device" --column="Label" \
  "${usb_menu[@]}" --multiple --separator=" ") || exit 1

zenity --question --text="You selected:\n$selected\n\nWrite ISO now? All data will be erased." || exit 1

# --- Write ISO to USBs ---
for dev in $selected; do
  (
    echo "# Writing to $dev"
    sudo dd if="$iso_file" of="$dev" bs=4M status=progress oflag=sync
    sync
  ) | zenity --progress --auto-close --title="Writing ISO" --text="Writing to $dev"
done

zenity --info --text="✅ ISO written successfully to all selected devices."

