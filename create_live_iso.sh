#!/bin/bash

# Dependencies required for the script
deps=(live-build debootstrap qemu grub-pc-bin grub-efi xorriso)

# Check and install missing dependencies
for dep in "${deps[@]}"; do
  dpkg -s "$dep" >/dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    echo "$dep is not installed. Installing..."
    sudo apt install -y "$dep"
  else
    echo "$dep is already installed."
  fi
done

# Clear the screen
clear

# Create a working directory for live-build
WORKDIR="live-build-system"
mkdir -p "$WORKDIR"
cd "$WORKDIR" || exit

# Initialize live-build configuration
sudo lb config \
  --binary-images iso-hybrid \
  --distribution "$(lsb_release -cs)" \
  --archive-areas "main contrib non-free" \
  --debian-installer live

# Export installed packages
dpkg --get-selections | grep -v deinstall > config/package-lists/my-packages.list.chroot

# Copy user and home directory
USER=$(whoami)
sudo mkdir -p config/includes.chroot/home/"$USER"
sudo cp -a /home/"$USER"/. config/includes.chroot/home/"$USER"/

# Include system configurations
sudo mkdir -p config/includes.chroot/etc
sudo cp -a /etc/. config/includes.chroot/etc/

# Include live system installer
sudo mkdir -p config/hooks/live-installer.chroot
cat << 'EOF' | sudo tee config/hooks/live-installer.chroot/99-installer.hook.chroot >/dev/null
#!/bin/bash
apt update
apt install -y calamares
EOF
sudo chmod +x config/hooks/live-installer.chroot/99-installer.hook.chroot

# Add persistence support (optional)
echo "persistence" | sudo tee config/includes.binary/boot.conf >/dev/null

# Build the live ISO
echo "Building the live system ISO. This may take some time..."
sudo lb build

# Clear the screen after build
clear

# Check if ISO was successfully created
ISO=$(ls -1 live-image-*.hybrid.iso 2>/dev/null | head -n 1)
if [[ -f "$ISO" ]]; then
  echo "Live system ISO created: $ISO"
else
  echo "ISO creation failed. Check the logs for errors."
  exit 1
fi

# Test the ISO using QEMU
echo "Testing the ISO with QEMU..."
qemu-system-x86_64 -m 2048 -cdrom "$ISO"
