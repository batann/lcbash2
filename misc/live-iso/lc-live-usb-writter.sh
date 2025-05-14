#!/bin/bash

set -euo pipefail

declare -A ISO_URLS=(
  [alpine]="https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86_64/alpine-extended-3.21.3-x86_64.iso"
  [debian]="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.10.0-amd64-netinst.iso"
  [antix]="https://sourceforge.net/projects/antix-linux/files/Final/antiX-23.2/runit-antiX-23.2/antiX-23.2-runit_x64-core.iso/download"
)

declare -A SHA256_URLS=(
  [alpine]="https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86_64/alpine-extended-3.21.3-x86_64.iso.sha256"
  [debian]="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS"
  [antix]="https://sourceforge.net/projects/antix-linux/files/Final/antiX-23.2/runit-antiX-23.2/antiX-23.2-runit_x64-core.iso.sha256/download"
)


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




TMPDIR="/home/ISO"
if [[ ! -d $TMPDIR ]]; then
  mkdir -p $TMPDIR
fi

  #cleanup() { rm -rf "$TMPDIR"; }
#trap cleanup EXIT

# -- Menu
echo -e "\033[32m"
tput cup 3 26
echo -e "Select OS to write\033[36m:\033[37m"
select os in "alpine" "debian" "antix" "mx" "parrot" "kali" ; do
  [[ -n "$os" ]] && break
done

iso_url="${ISO_URLS[$os]}"
sha_url="${SHA256_URLS[$os]}"
iso_file="$TMPDIR/${iso_url##*/}"

echo -e "\n>> Downloading ISO..."
curl -L "$iso_url" -o "$iso_file"

echo ">> Downloading SHA256..."
sha_file="$TMPDIR/${sha_url##*/}"
curl -L "$sha_url" -o "$sha_file"

echo ">> Verifying checksum..."
pushd "$TMPDIR" >/dev/null
if [[ "$os" == "debian" ]]; then
  grep "$(basename "$iso_file")" "$sha_file" | sha256sum -c -
else
  sha256sum -c "$sha_file"
fi
popd >/dev/null

# -- USB device selection
echo -e "\nAvailable block devices:"
lsblk -dpno NAME,SIZE,MODEL | grep -v "$(findmnt -n / | cut -d' ' -f1 | sed 's/[0-9]*$//')"

read -rp $'\nEnter space-separated target USB devices (e.g., /dev/sdX /dev/sdY): ' -a targets

echo -e "\nAbout to write ISO to:\n${targets[*]}"
read -rp "Are you sure? This will wipe them. Type 'yes': " confirm
[[ "$confirm" != "yes" ]] && echo "Aborted." && exit 1

# -- Write to each device
for dev in "${targets[@]}"; do
  echo -e "\n>> Writing to $dev"
  sudo dd if="$iso_file" of="$dev" bs=4M status=progress oflag=sync
done

sync
echo -e "\n✅ All done. You may now boot from the USB(s)."

