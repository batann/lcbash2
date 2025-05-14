#!/bin/bash

set -e

# ---------------------- Configuration -----------------------

declare -A ISO_URLS=(
  ["Alpine Linux"]="https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86_64/alpine-extended-3.21.3-x86_64.iso"
  ["Debian Live"]="https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-12.5.0-amd64-standard.iso"
  ["antiX Core (runit)"]="https://sourceforge.net/projects/antix-linux/files/Final/antiX-23.2/runit-antiX-23.2/antiX-23.2-runit_x64-core.iso"
  ["Parrot Home 6.3.2"]="https://bunny.deb.parrot.sh//parrot/iso/6.3.2/Parrot-home-6.3.2_amd64.iso"
  ["Kali 2025.1a"]="https://gsl-syd.mm.fcix.net/kali-images/kali-2025.1a/kali-linux-2025.1a-installer-amd64.iso"
  ["MX 23.6 Xfce"]="https://ixpeering.dl.sourceforge.net/project/mx-linux/Final/Xfce/MX-23.6_x64.iso"
)

declare -A CHECKSUMS=(
  ["Debian Live"]="https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/SHA256SUMS"
  ["antiX Core (runit)"]="https://sourceforge.net/projects/antix-linux/files/Final/antiX-23.2/runit-antiX-23.2/antiX-23.2-runit_x64-core.iso.sha256"
  ["Parrot Home 6.3.2"]="https://bunny.deb.parrot.sh//parrot/iso/6.3.2/Parrot-home-6.3.2_amd64.iso.sha256"
  ["Kali 2025.1a"]="https://gsl-syd.mm.fcix.net/kali-images/kali-2025.1a/kali-linux-2025.1a-installer-amd64.iso.sha256"
  ["MX 23.6 Xfce"]="https://ixpeering.dl.sourceforge.net/project/mx-linux/Final/Xfce/MX-23.6_x64.iso.sha256"
)

WORKDIR="/tmp/usb-writer"
mkdir -p "$WORKDIR"

# ---------------------- GUI Functions -----------------------

choose_iso() {
  zenity --list --radiolist \
    --title="Choose a Minimal Linux OS" \
    --column "Pick" --column "Distro" \
    TRUE "Debian Live" \
    FALSE "antiX Core (runit)" \
    FALSE "Alpine Linux" \
    FALSE "Parrot Home" \
    FALSE "Kali 2025.1a" \
    FALSE "MX Xfce 23.6"

}

choose_device() {
  lsblk -ndo NAME,SIZE,MODEL | grep -vE '^loop|^sr' | while read -r dev size model; do
    echo "/dev/$dev ($size) $model"
  done | zenity --list --radiolist \
    --title="Select USB Device" \
    --column "Pick" --column "Device" \
    --width=500 --height=700
}

confirm_persistence() {
  zenity --question \
    --title="Enable Persistence?" \
    --text="Enable persistence (only available for Debian Live and antiX)?"
}

show_info() {
  zenity --info --text="$1"
}

# ---------------------- Download + Verify -----------------------

download_iso() {
  local distro="$1"
  local url="${ISO_URLS[$distro]}"
  local filename="$WORKDIR/${url##*/}"

  if [ ! -f "$filename" ]; then
    wget -O "$filename" "$url"
  fi

  echo "$filename"
}

verify_checksum() {
  local distro="$1"
  local iso="$2"
  local sum_url="${CHECKSUMS[$distro]}"

  [ -z "$sum_url" ] && return 0 # Skip if no checksum

  wget -qO "$WORKDIR/CHECKSUMS" "$sum_url"
  grep "$(basename "$iso")" "$WORKDIR/CHECKSUMS" > "$WORKDIR/MATCH"

  sha256sum -c "$WORKDIR/MATCH" || {
    zenity --error --text="Checksum verification failed for $iso"
    exit 1
  }
}

# ---------------------- USB Partitioning -----------------------

partition_usb() {
  local usb="$1"
  local iso="$2"

  sudo parted -s "$usb" mklabel msdos
  sudo parted -s "$usb" mkpart primary fat32 1MiB 2GiB
  sudo parted -s "$usb" mkpart primary ext4 2GiB 100%
  sudo mkfs.vfat -n LIVE "${usb}1"
  sudo mkfs.ext4 -L persistence "${usb}2"

  sudo dd if="$iso" of="$usb" bs=4M status=progress conv=fsync
}

setup_persistence_partition() {
  local usb="$1"

  mountpoint=$(mktemp -d)
  sudo mount "${usb}2" "$mountpoint"
  echo "/ union" | sudo tee "$mountpoint/persistence.conf"
  sudo umount "$mountpoint"
  rmdir "$mountpoint"
}

# ---------------------- Main Flow -----------------------

main() {
  DISTRO=$(choose_iso) || exit 1
  DEVICE=$(choose_device) || exit 1
  confirm_persistence && ENABLE_PERSISTENCE=true || ENABLE_PERSISTENCE=false

  ISO=$(download_iso "$DISTRO")
  verify_checksum "$DISTRO" "$ISO"

  show_info "Writing ISO to $DEVICE… This will erase all data on the USB."
  partition_usb "$DEVICE" "$ISO"

  if [[ "$ENABLE_PERSISTENCE" == true ]]; then
    case "$DISTRO" in
      "Debian Live") setup_persistence_partition "$DEVICE" ;;
      "antiX Core (runit)") show_info "antiX persistence requires manual setup post-boot via persist-config." ;;
      *) show_info "Persistence not supported for $DISTRO." ;;
    esac
  fi

  show_info "✅ USB for $DISTRO is ready."
}

main

