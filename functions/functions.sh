#/bin/bash
# vim:fileencoding=utf-8:foldmethod=marker
#{{{ >>>   set_resume_variable >#3

set_resume_variable() {
	abc=$(blkid | awk -F'\"' '/swap/ {print $2}'|wc -l)
	if [[ $abc > 1 ]]; then
		printf "RESUME=UUID=$(blkid | awk -F'\"' '/swap/ {print $2}'|tail -n1)\n" | sudo tee /etc/initramfs-tools/conf.d/resume
		sudo update-initramfs -u -k all
		echo -e "\033[34mScript run successfully. \033[32mYou should reboot.\033[0m"
		else
			printf "RESUME=UUID=$(blkid | awk -F\" '/swap/ {print $2}')\n" | sudo tee /etc/initramfs-tools/conf.d/resume
			sudo update-initramfs -u -k all
			echo -e "\033[34mScript run successfully. \033[32mYou should reboot.\033[0m"
	fi
			}



#}}} <#20
#{{{ >>>   install_essential >#21

install_essential() {
    DEPS_inst_essential="vim git ranger curl ddgr xclip bash sudo trash-cli tmux fzf megatools gcc make"
    for pack in ${DEPS_inst_essential[@]}; do
        dpkg -s $pack >/dev/null 2>&1
        if [[ $? == 1 ]]; then
            echo -e "\033[33mInstalling \033[31m${pack}\033[33m...\033[0m"
            sudo apt-get install -y $pack >/dev/null 2>&1
        fi
    done
}

#}}} <#34
#{{{ >>>   clone_my-dot >#35
		clone_my-dot() {
		git clone https://github.com/batann/my-dot
		sudo chmod a+x /home/batan/my-dot/install.sh
		sudo -u batan bash my-dot/install.sh
		source .bashrc
	}
	#}}} <#42
#{{{ >>>   add_sudo_visudo >#43
add_sudo__visudo() {
		echo "batan ALL=(ALL:ALL) NOPASSWD:ALL"|sudo EDITOR='tee -a' visudo
	}
#}}} <#47
#{{{ >>>   add_user_groups >#48
	add_user_groups() {
		USER="batan"
		# List of groups to check and add
		GROUPS=('sudo' 'lp' 'dialout' 'cdrom' 'floppy' 'sudo' 'audio' 'dip' 'video' 'plugdev' 'users' 'netdev' 'lpadmin' 'vboxsf' 'scanner' 'sambashare')
		## Check if the script is run as root
		#if [[ $EUID -ne 0 ]]; then
		#	echo "This script must be run as root."
		#	exit 1
		#fi
		# Check if the user was provided
		if [[ -z "$USER" ]]; then
			echo "Usage: $0 <username>"
			exit 1
		fi
		# Iterate through each group and check if the user is a member
		for group in "${GROUPS[@]}"; do
			if groups "$USER" | grep -qw "$group"; then
				echo "User $USER is already in group $group."
			else
				echo "Adding user $USER to group $group."
				sudo usermod -aG "$group" "$USER"
			fi
		done
		echo -e "${B}Group membership check and update complete for$R $USER."
	}
	#}}} <#74
#{{{ >>>   set_no_screen_blanking >#75
set_no_screen_blanking() {
  if [[ "$XDG_SESSION_DESKTOP" == "xfce" ]]; then
    # Apply Xfce-specific commands
    xfconf-query -c xfce4-screensaver -p /enabled -s false
    xfconf-query -c xfce4-power-manager -p /screensaver/blanking -s false
elif [[ "$XDG_SESSION_DESKTOP" == "gnome" ]]; then
    # Apply GNOME-specific commands
    gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
    gsettings set org.gnome.desktop.session idle-delay 0
elif [[ "$XDG_SESSION_DESKTOP" == "i3" ]]; then
    # Apply i3-specific commands
    xset s off
    xset -dpms
    xset s noblank
fi

}
#}}} <#93
#{{{ >>>   usr_fstab Custom FSTAB >#94

usr_fstab() {
	cat /etc/fstab|grep $(blkid /dev/$(lsblk -l -o NAME,SIZE |grep G|sort -h|grep "[a-z][a-z][a-z][0-9]"|tail -n1|cut -c1-4)|awk '{print $2}') >> /dev/null 2>&1
	if [[ $? == 1 ]];
	then
		sudo cat /etc/fstab >> /home/batan/fstab
		abc=$(blkid /dev/$(lsblk -l -o NAME,SIZE |grep G|sort -h|grep "[a-z][a-z][a-z][0-9]"|tail -n1|cut -c1-4)|awk '{print $2}')
		echo -e "$abc ext4 /media/batan/100 defaults,noatime,rw 0 0" >> /home/batan/fstab
		sudo mv /etc/fstab /etc/fstab.org
		sudo chown root:root /home/batan/fstab
		sudo mv /home/batan/fstab /etc/fstab
		sudo mount -a
	fi
}
#}}} <#109
#{{{ >>>   set_gpg >#110
set_gpg() {
	command -v gpg >/dev/null 2>&1 || { echo >&2 "GPG is not installed. Please install GPG and try again."; exit 1; }
	###   Set key details   ##########################################
	full_name="fairdinkum batan"
	email_address="tel.petar@gmail.com"
	passphrase="Ba7an?12982"
	app_password_fairdinkum="ixeh bhbn dbrq pbyc"
	###   Generate GPG key   #########################################
	gpg --batch --full-generate-key <<EOF
	Key-Type: RSA
	Key-Length: 4096
	Subkey-Type: RSA
	Subkey-Length: 4096
	Name-Real: $full_name
	Name-Email: $email_address
	Expire-Date: 1y
	Passphrase: $passphrase
	%commit
EOF

echo -e "${B}GPG key generation completed.$R Please make sure to remember your passphrase.$N"
pass init tel.petar@gmail.com

}

#}}} <#136
#{{{ >>>   set_ssh >#137

set_ssh() {
	key_name="id_rsa"
	key_location="$HOME/.ssh/$key_name"
	ssh-keygen -t rsa -b 4096 -f "$key_location" -N ""

###   Function to detect the init system   ###########
get_init_system() {
	if [ -f /run/systemd/system ]; then
		echo "systemd"
	elif command -v service >/dev/null; then
		echo "SysVinit"
	elif command -v rc-service >/dev/null; then
		echo "OpenRC"
	elif command -v initctl >/dev/null; then
		echo "Upstart"
	else
		echo "unknown"
	fi
}

###   Function to configure SSH on a remote machine   ###########
configure_ssh() {
	# SSH configuration file path
	local ssh_config="/etc/ssh/sshd_config"
	local init_system=$(get_init_system)  # Detect the init system
	sudo cp $ssh_config "$ssh_config.bak"
	# Combine all SSH configuration changes into one command
	ssh -o "StrictHostKeyChecking=no" -o "PasswordAuthentication=no" "$1" "\
		sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' $ssh_config && \
		sudo sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile/' $ssh_config && \
		# Restart SSH service based on the detected init system
			$(case "$init_system" in
			systemd) echo "sudo systemctl restart ssh";;
			SysVinit) echo "sudo service ssh restart";;
			OpenRC) echo "sudo rc-service sshd restart";;
			Upstart) echo "sudo stop ssh && sudo start ssh";;
			*) echo "echo 'Unknown init system: $init_system. Cannot restart SSH.'";;
		esac)"
		}

		active_ips=()
		local_ip=$(hostname -I | awk '{print $1}')

		for i in $(seq 35 40); do
			current_ip="192.168.1.$i"
			if [ "$current_ip" != "$local_ip" ] && ping -c 1 -W 1 "$current_ip" &> /dev/null; then
				active_ips+=("$current_ip")
			fi
		done

		for ip in "${active_ips[@]}"; do
			ssh-copy-id -i "$key_location.pub" batan@"$ip"
			configure_ssh "$ip"  # Call the function to configure SSH on the remote machine
		done
		clear
	}
	#}}} <#195
#{{{ >>>   set_ufw >#196

	set_ufw() {
		sudo dpkg -s ufw >/dev/null
		if [[ $? -eq 0 ]]; then
			echo "ufw is already installed."
		else
			sudo apt install -y ufw
		fi
		for i in $(seq 35 40);
		do
			sudo ufw allow from 192.168.1.$i && sudo ufw allow to 192.168.1.$i
		done
		sudo ufw enable
	}
	#}}} <#211
#{{{ >>>   clone_hosts >#212
clone_hosts() {
	git clone https://github.com/batan/hos
	sudo chmod +x hos/install.sh
	sudo bash hos/install.sh
}
	#}}} <#218
#{{{ >>>   install_i3 >#219
install_i3() {
		DEPS_i3="i3 i3status i3lock dunst picom cava xfce4-terminal stterm suckless-tools rofi surf thunar xterm pavucontrol sox libsox-fmt-all alsa-utils i3status wmctrl xdotool xorg xinit x11-xserver-utils pulseaudio pulseaudio-utils network-manager network-manager-gnome fonts-font-awesome arandr feh lxappearance xarchiver lightdm lightdm-gtk-greeter policykit-1-gnome software-properties-gtk apt-transport-https curl wget git firefox-esr thunar-archive-plugin thunar-volman thunar-media-tags-plugin gvfs gvfs-backends xbacklight acpi acpid notification-daemon libnotify-bin volumeicon-alsa vim htop neofetch python3-pip nmcli arj lbzip2 lhasa liblz4-tool lrzip lzip lzop ncompress pbzip2 pigz plzip rar unar libgtk-4-dev libgcr-3-dev libgcr-3-dev libwebkit2gtk-4.0-dev x11-apps mesa-utils"
		DESKT="i3"
		if [[ "$DESKT" == "i3" ]]; then
			# Silently check if any dependencies are installed and install them if not
			for dep in $DEPS_i3; do
				if ! dpkg -s $dep >/dev/null 2>&1; then
					echo "Installing \033[34m$dep...\033[0m"
					sudo apt-get install -y $dep
				fi
			done
		fi
	}
	#}}} <#233
#{{{ >>>   install_spf >#234
install_spf() {
bash -c "$(curl -sLo- https://superfile.netlify.app/install.sh)"
}
#}}} <#238
#{{{ >>>   install_minidlna >#239
install_minidlna() {
	# Define variables
	USER="batan"
	GROUP="batan"
	UUID="c96173e2-aae6-43b1-bad3-2d8fb4e87e25"
	MOUNT_POINT="/media/batan/100"
	FSTAB_ENTRY="UUID=${UUID} ${MOUNT_POINT} ext4 defaults 0 2"
	MINIDLNA_CONF="/etc/minidlna.conf"

# Set ownership and permissions
sudo chown -R $USER:$GROUP "$MOUNT_POINT"
sudo chmod -R 755 "$MOUNT_POINT"

# Backup MiniDLNA configuration
sudo cp $MINIDLNA_CONF ${MINIDLNA_CONF}.bak

# Configure MiniDLNA
sudo cat <<EOF > $MINIDLNA_CONF
# MiniDLNA configuration file
media_dir=V,$MOUNT_POINT/Videos
media_dir=A,$MOUNT_POINT/Music
media_dir=P,$MOUNT_POINT/Backgrounds
friendly_name=My MiniDLNA Server
db_dir=/var/cache/minidlna
log_dir=/var/log
inotify=yes
EOF

# Ensure permissions for MiniDLNA
sudo chown -R minidlna:minidlna /var/cache/minidlna
sudo chmod -R 755 /var/cache/minidlna
sudo chown -R minidlna:minidlna /var/log
sudo chmod -R 755 /var/log
sudo chown -R minidlna:minidlna /media/batan/100
sudo chmod -R 755 /media/batan/100

# Restart and enable MiniDLNA
sudo service minidlna restart
sudo service minidlna enable
sudo service minidlna stop
sudo rm -rf /var/cache/minidlna/files.db
sudo service minidlna start
sudo service minidlna restart
sudo service minidlna status


# Display status
echo "MiniDLNA installation and configuration completed."
}
#}}} <#289
#{{{ >>>   install_samba >#290
install_samba() {
	# Variables
	USER="batan"
	PASSWORD="Ba7an?12982"
	SHARE_DIRS=("/home/batan/Videos" "/home/batan/Music" "/home/batan/Documents" "/home/batan/Pictures")

# Ensure samba service is installed
if ! command -v smbpasswd &> /dev/null; then
	echo "Samba is not installed. Installing now..."
	sudo apt-get install samba -y || sudo pacman -S samba || sudo dnf install samba -y
fi

# Create samba user and set password
echo "Creating Samba user: $USER"
sudo smbpasswd -x $USER &> /dev/null  # Remove the user if they exist already
sudo useradd -M -s /sbin/nologin $USER  # Create system user without home
echo -e "$PASSWORD\n$PASSWORD" | sudo smbpasswd -a $USER  # Set Samba password
sudo smbpasswd -e $USER  # Enable the user

# Backup smb.conf
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

# Modify smb.conf
echo "Modifying /etc/samba/smb.conf"

for dir in "${SHARE_DIRS[@]}"; do
	sudo mkdir -p "/srv/samba/$dir"
	sudo chown $USER:users "/srv/samba/$dir"
	sudo chmod 755 "/srv/samba/$dir"

	# Add the share configuration
	sudo bash -c cat >> /etc/samba/smb.conf <<EOF

	[$dir]
	path = /srv/samba/$dir
	browseable = yes
	read only = no
	guest ok = no
	valid users = $USER
	write list = $USER
	create mask = 0775
	directory mask = 0775
	public = yes
EOF

done

# Set up read-only access for everyone else
sudo bash -c cat >> /etc/samba/smb.conf <<EOF

[Public]
path = /srv/samba
public = yes
only guest = yes
browseable = yes
writable = no
guest ok = yes
create mask = 0775
directory mask = 0775
EOF
# Restart Samba services
if [[ "$init_system" == "systemd" ]]; then
	sudo systemctl restart smbd
	sudo systemctl enable smbd
else
	sudo service smbd restart
	sudo service smbd enable
fi
echo "Samba setup complete."
}

#}}} <#362
#{{{ >>>   install_lamp8 >#363

install_lamp() {
	DEPS_LAMP="apache2 apache2-utils curl mariadb-server mariadb-client php libapache2-mod-php php-mysql php-common php-cli php-common php-opcache php-xml php-yaml php-readline php-fpm php-gd php-mbstring php-curl php-zip"

# Variables
DB_NAME="nextcloud"
DB_USER="batan"
DB_PASSWORD="Ba7an?12982"
NEXTCLOUD_URL="https://download.nextcloud.com/server/releases/latest.zip"
NEXTCLOUD_DIR="/var/www/nextcloud"
ADMIN_USER="batan"
ADMIN_PASSWORD="Ba7an?12982"
DOMAIN="localhost"

# Update and Install Dependencies
sudo apt update && sudo apt upgrade -y
sudo apt install apache2 mariadb-server libapache2-mod-php8.2 -y
sudo apt install php8.2 php8.2-gd php8.2-mysql php8.2-curl php8.2-xml php8.2-mbstring php8.2-zip php8.2-intl php8.2-bcmath php8.2-gmp php-imagick unzip wget -y

# Enable Apache Modules
sudo a2enmod rewrite headers env dir mime
sudo service apache2 restart
#sudo systemctl restart apache2

# Configure MariaDB
#sudo systemctl start mariadb
sudo service mariadb start
sudo mysql_secure_installation <<EOF

Y
$DB_PASSWORD
$DB_PASSWORD
Y
Y
Y
Y
EOF

# Create Nextcloud Database and User
sudo mysql -uroot -p$DB_PASSWORD <<EOF
CREATE DATABASE $DB_NAME;
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EXIT;
EOF

Download and Install Nextcloud
cd /tmp
wget $NEXTCLOUD_URL -O nextcloud.zip
unzip nextcloud.zip
sudo mv nextcloud $NEXTCLOUD_DIR
sudo chown -R www-data:www-data $NEXTCLOUD_DIR
sudo chmod -R 755 $NEXTCLOUD_DIR

# Apache Configuration for Nextcloud
sudo bash -c "cat >/etc/apache2/sites-available/nextcloud.conf" <<EOF
<VirtualHost *:80>
	ServerAdmin admin@$DOMAIN
	DocumentRoot $NEXTCLOUD_DIR
	ServerName $DOMAIN

	<Directory $NEXTCLOUD_DIR>
		Options +FollowSymlinks
		AllowOverride All

		<IfModule mod_dav.c>
			Dav off
		</IfModule>

		SetEnv HOME $NEXTCLOUD_DIR
		SetEnv HTTP_HOME $NEXTCLOUD_DIR
	</Directory>

	ErrorLog \${APACHE_LOG_DIR}/error.log
	CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

sudo a2ensite nextcloud.conf
#sudo systemctl reload apache2
sudo service apache2 reload
# Set Permissions
sudo chown -R www-data:www-data $NEXTCLOUD_DIR

# Install Nextcloud via Command Line
sudo -u www-data php $NEXTCLOUD_DIR/occ maintenance:install \
	--database "mysql" --database-name "$DB_NAME" \
	--database-user "$DB_USER" --database-pass "$DB_PASSWORD" \
	--admin-user "$ADMIN_USER" --admin-pass "$ADMIN_PASSWORD" \
	--data-dir "$NEXTCLOUD_DIR/data"

# Set local IP to trusted domain
LOCAL_IP=$(hostname -I | awk '{print $1}')
sudo -u www-data php $NEXTCLOUD_DIR/occ config:system:set trusted_domains 1 --value=$LOCAL_IP

# Restart Apache
#sudo systemctl restart apache2

echo "Nextcloud installation complete. Access it via http://$LOCAL_IP"

sudo service apache2 restart
}
#}}} <#467
#{{{ >>>   change_udisk2.policy >#468
change_udisk2.policy() {
	clear
	tput cup 3 0
	echo -e "\033[33m Do you want to change \033[31mudisk2.policy \033[33m???\\033[0m"
	tput cup 3 40
	read -n1 -p " yn" abc
	if [[ $abc == 'y' ]];
	then
		find usrsharepolkit-1actions -type f -name "org.freedesktop.UDisks2.policy" -exec sudo sed -i 'sg<allow_active>auth_admin_keep<allow_active>!<allow_active>yes<allow_active>!g' {} \;
	fi
}
#}}} <#480
#{{{ >>>   install_flatpak >#481

install_flatpak () {
	sudo apt install flatpak -y
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	for package in ${FLATPAK_PACKAGES[@]};
	do
		flatpak install flathub $package -y
	done
}
#}}} <#491
#{{{ >>>   install_taskwarrior >#492
install_taskwarrior() {
	dpkg -s taskwarrior > /dev/null 2>&1
	if [ $? -eq 1 ]; then
		echo -e "\033[33mInstalling \033[31mtaskwarrior\033[33m...\033[0m"
		sudo apt install taskwarrior -y > /dev/null 2>&1
	fi

	if [[ ! -d /home/batan/.task ]]; then
		git clone https://github.com/batann/task.git /home/batan/.task
		sudo trash /home/batan/.task/{.git,README.md,images,assets/commands.txt,assets/README.md}
	fi

	for file in lc-tasknote lc-task lc-lock; do
		if [[ ! -f /usr/bin/$file ]]; then
			sudo cp /home/batan/.task/assets/$file /usr/bin/$file
			chmod +x /usr/bin/$file
		fi
	done

	}
	#}}} <#513
#{{{ >>>   git_lchost #EXPERIMENTAL >#514
	git_lchost() {
		HOS1="/etc/hosts"
		HOS2="/etc/hosts.2"
		HOS3="/etc/hosts.3"
		SIGN_FILE="/home/batan/.lc-sign"

		clear

# Ensure .lc-sign exists before reading
if [[ ! -f "$SIGN_FILE" ]]; then
	touch "$SIGN_FILE"
fi
BLOCKING=$(grep "lc-sign-1" "$SIGN_FILE")

check_hosts() {
	# Check if hosts.2 exists
	if [[ ! -f "$HOS2" ]]; then
		echo -e "\033[32mGetting the hosts file...\033[0m"
		git clone https://github.com/batann/host.git /tmp/host_repo > /dev/null 2>&1
		if [[ $? -ne 0 ]]; then
			echo -e "\033[31mFailed to fetch hosts file from repository.\033[0m"
			exit 1
		fi
		cat "$HOS1" >> /tmp/host_repo/hosts
		sudo mv /tmp/host_repo/hosts "$HOS2"
		rm -rf /tmp/host_repo
		echo -e "\033[32mHosts file setup complete.\033[0m"
	fi
}

block_hosts() {
	if [[ "$BLOCKING" == "lc-sign-1" ]]; then
		echo -e "\033[31mYou are already blocking with the hosts file...\033[0m"
	else
		sudo cp "$HOS1" "$HOS3"
		sudo cp "$HOS2" "$HOS1"
		sudo mv "$HOS3" "$HOS2"
		echo "lc-sign-1" >> "$SIGN_FILE"
		echo -e "\033[32mBlocking enabled.\033[0m"
	fi
}

unblock_hosts() {
	if [[ "$BLOCKING" != "lc-sign-1" ]]; then
		echo -e "\033[31mYou are not blocking with the hosts file...\033[0m"
	else
		sudo cp "$HOS1" "$HOS3"
		sudo cp "$HOS2" "$HOS1"
		sudo mv "$HOS3" "$HOS2"
		sed -i '/lc-sign-1/d' "$SIGN_FILE"
		echo -e "\033[32mBlocking disabled.\033[0m"
	fi
}

# Main Script
clear
check_hosts
echo -e "\033[32mDo you want to block with the hosts file? (y/n)\033[0m"
read -p ">> " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	block_hosts
else
	unblock_hosts
fi

clear
echo -e "\033[32mScript executed successfully.\033[0m"
if [[ "$BLOCKING" == "lc-sign-1" ]]; then
	echo -e "\033[31mYou are blocking with the hosts file.\033[0m"
else
	echo -e "\033[31mYou are not blocking with the hosts file.\033[0m"
fi
}
#}}} <#589
#{{{ >>>   build_yad >#590
build_yad() {
	# Exit immediately if a command exits with a non-zero status
	set -e

# Define variables
REPO_URL="https://github.com/v1cont/yad.git"
INSTALL_DIR="$HOME/yad-build"

# Update system and install dependencies
echo "Updating system and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y git build-essential intltool \
	libgtk-3-dev libwebkit2gtk-4.0-dev \
	libgdk-pixbuf2.0-dev libnotify-dev \
	libjson-glib-dev libxml2-utils

# Clone the YAD repository
echo "Cloning the YAD repository..."
if [ -d "$INSTALL_DIR" ]; then
	echo "Directory $INSTALL_DIR already exists, removing it."
	rm -rf "$INSTALL_DIR"
fi

git clone "$REPO_URL" "$INSTALL_DIR"

# Navigate to the repository
cd "$INSTALL_DIR"

# Configure and enable HTML browser support
echo "Configuring YAD with HTML browser support..."
autoreconf -ivf && intltoolize
./configure --enable-html

# Compile and install YAD
echo "Compiling and installing YAD..."
make
sudo make install

# Verify installation
echo "Verifying YAD installation..."
if yad --version; then
	echo "YAD installed successfully!"
else
	echo "There was an issue with the YAD installation."
	exit 1
fi
}
#}}} <#638
#{{{ >>>   install_windsurf >#639
install_windsurf() {
	curl -fsSL "https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/windsurf.gpg" | sudo gpg --dearmor -o /usr/share/keyrings/windsurf-stable-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/windsurf-stable-archive-keyring.gpg arch=amd64] https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/apt stable main" | sudo tee /etc/apt/sources.list.d/windsurf.list > /dev/null
	sudo apt-get update
	sudo apt-get upgrade windsurf
}
#}}} <#646
#{{{ >>>   modify_lightdm >#647

modify_lightdm() {
	abc=$(find /usr/share/lightdm/lightdm-gtk-greeter.conf.d/ -type f -name "01_debian.conf")
	bcd=$(sudo cat $abc|grep background)
	sudo sed -i "s|$bcd|background=\/usr\/share\/backgrounds\/lightdm.png|g" $abc

	megaget /Root/lightdm-gtk-greeter.conf
	sudo cp lightdm-gtk-greeter.conf  /etc/lightdm/lightdm-gtk-greeter.conf
}
#}}} <#657
#{{{ >>>   install_dmscripts >#658
install_dmscripts() {
	git clone https://gitlab.com/dwt1/dmscripts.git
	cd dmscripts
	sudo make clean build
	sudo make install

}
#}}} <#666
#{{{ >>>   fin >#667
fin() {
	dialog --backtitle "Your friendly Postinstall Script" --title "Hi there!" --msgbox "Hold on to your heameroids and relax, dont panic, I am here to help!" 10 60
	if [[ $EUID -ne 0 ]]; then
		echo "This script must be run as root"
		exit 1
	else
		#Update and Upgrade
		echo "Updating and Upgrading"
		#	apt-get update && sudo apt-get upgrade
		sudo apt-get install dialog
		cmd=(dialog --separate-output --checklist "Please Select Software you want to install:" 40 76 000)
		options=(1 "My Github" off
			2 "Ranger" off
			3 "Cmus" off
			4 "Flatpak" off
			5 "Git" off
			6 "Phython3-pip" off
			7 "Taskwarrior" off
			8 "Timewarrior" off
			9 "Sweeper" off
			10 "Ungoogled Chromium" off
			11 "Ip2 (aug-2000)" off
			12 "" off
			13 "Chromium" off
			14 "Vit" off
			15 "Bitwarden" off
			16 "Neovim" off
			17 "Mega Sync Cloud" off
			18 "Tutanota" off
			19 "Bleachbit" off
			20 "Oolite" off
			21 "Musikcube" off
			22 "Browser-history" off
			23 "Castero" off
			24 "Rtv" off
			25 "Rainbowstream" off
			26 "Eg" off
			27 "Bpytop" off
			28 "Openssh-server" off
			29 "Openssh-client" off
			30 "Renameutils" off
			31 "Mat2" off
			32 "0ad" off
			33 "Yt-dlp" off
			34 "Ffmpeg" off
			35 "Buku" off
			36 "Megatools" off
			37 "Bitwarden-cli" off
			38 "YAD -html deps" off
			39 "Visual Code" off
			40 "Protonvpn" off
			41 "N Stacer" off
			42 "Links2" off
			43 "W3m" off
			44 "Trash-cli" off
			45 "Kdeconnect" off
			46 "Zsh" off
			47 "Ufw" off
			48 "Guake" off
			49 "Tmux" off
			50 "Yad" off
			51 "Nodau" off
			52 "Pwman3" off
			53 "Bwmw-ng" off
			54 "Calcurse" off
			55 "Vnstat" off
			56 "Vimwiki" off
			57 "Vim-taskwarrior" off
			58 "Taskwiki" off
			59 "Tabular" off
			60 "Calendar" off
			61 "Tagbar" off
			62 "Vim-plugin-AnsiEsc" off
			63 "Table-mode" off
			64 "Vimoucompleteme" off
			65 "Deoplete" off
			66 "Emmet-vim" off
			67 "Synchronous L engine" off
			68 "Html5.vim" off
			69 "Surround-vim" off
			70 "Vim-lsp" off
			71 "Vim-lsp-ale" off
			72 "Prettier" off
			73 "Unite.vim" off
			74 "Turtle Note" off
			75 "Megasync Home" off
			76 "Speedread" off
			77 "Shalarm" off
			78 "Speedtest-cli" off
			79 "Festival" off
			80 "Espeak" off
			81 "Terminator" off
			82 "Festvox-us-slt-hts" off
			83 "Fzf" off
			84 "Rofi" off
			85 "Ddgr" off
			86 "Tldr" off
			87 "Proton VPN" off
			88 "Ctags from Repo" off
			89 "Stockfish and Chs" off
			90 "Liferea" off
			91 "Newsboat" off
			92 "Install graphne Theme" off
			93 "Obsidian-2-gtk-theme" off
			94 "Obsidian-icon-Theme" off
			95 "Falkon Browser" off
			96 "Kodi" off
			97 "Awsom Vim Colorschemes" off
			98 "ALL VIM plugins" off
			99 "ALL NVIM PLUGINS" off)

			choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
			clear
			for choice in $choices
			do
				case $choice in
					1)
						#Github Script
						clear
						read -e -p "Run github Script   >>>   " -i 'Yes' fff
						if [[ $fff == 'Yes' ]]; then
							sudo -u batan bash github.sh
						else
							clear
							echo "Script run Successfully... exited on user request.."
							exit 0
						fi
						;;
					2)
						#Install Ranger
						echo "Installing Ranger"
						apt-get install ranger
						;;
					3)
						#Install Cmus
						echo "Installing Cmus"
						apt-get install  cmus
						;;
					4)
						#flatpak
						echo "Installing flatpak & gnome-blah-blah-blah"
						apt-get install flatpak gnome-software-plugin-flatpak
						flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
						;;
					5)
						#Install git
						echo "Installing Git, please congiure git later..."
						apt-get install git
						;;
					6)
						#Python3-pip
						echo "Installing python3-pip"
						apt-get install python3-pip
						;;
					7)
						#taskwarrior
						echo "Installing taskwarrior"
						apt-get install taskwarrior
						;;
					8)
						#Timewarrior
						echo "Installing Timewarrior"
						apt-get install timewarrior
						;;
					9)
						#sweeper
						echo "Installing sweeper"
						apt-get install sweeper
						;;
					10)
						#Ungoogled Chromium cloned uBlock
						echo "Installing Ungoogled-Chromium"
						sudo apt-get install mesa-vulkan-drivers mesa-vulkan-drivers:i386 libvulkan1 libvulkan1:i386 -y
						flatpak install io.github.ungoogled_software.ungoogled_chromium -y
						;;
					11)
						#Installing i2p on Debian Buster or Later
						clear
						echo "Proceed with i2p installation on Deian Buster or later or its derivatives?"
						read -n1 -p 'Enter [ANY] to continue...   >>>   ' lol
						sudo apt-get update
						sudo apt-get install apt-transport-https lsb-release curl -y
						clear
						sudo apt install openjdk-17-jre -y
						udo tee /etc/apt/sources.list.d/i2p.list
						curl -o i2p-archive-keyring.gpg https://geti2p.net/_static/i2p-archive-keyring.gpg
						gpg --keyid-format long --import --import-options show-only --with-fingerprint i2p-archive-keyring.gpg
						sudo cp i2p-archive-keyring.gpg /usr/share/keyrings
						sudo apt-get update
						sudo apt-get install i2p i2p-keyring
						;;
					12)
						#building firefox extantion
						;;
					13)
						#Chromiun
						echo "Installing Chromium"
						apt-get install chromium
						;;
					14)
						#Vit
						echo "Installing Vit"
						apt-get install vit
						;;
					15)
						#Bitwarden
						echo "Installing Bitwarden"
						flatpak install flathub com.bitwarden.desktop
						;;
					16)
						#Install Neovim
						echo "Installing Neovim"
						apt-get install neovim
						;;
					17)
						#MEGAsync
						echo "Installing MEGAsync"
						flatpak install flathub nz.mega.MEGAsync
						;;
					18)
						#Tutanota
						echo "Installing Numic Icons"
						flatpak install flathub com.tutanota.Tutanota
						;;
					19)
						#Bleachbit
						echo "Installing BleachBit"
						apt-get install bleachbit
						;;
					20)
						#Oolite
						echo "Installing Oolite"
						wget https://github.com/OoliteProject/oolite/releases/download/1.90/oolite-1.90.linux-x86_64.tgz
						tar -xvzf oolite-1.90.linux-x86_64.tgz
						./oolite-1.90.linux-x86_64.run
						;;
					21)
						#Musikcube
						wget https://github.com/clangen/musikcube/releases/download/0.98.0/musikcube_standalone_0.98.0_amd64.deb
						dpkg -i musikcube_standalone_0.98.0_amd64.deb
						apt-get install -f
						;;
					22)
						#Browser-history
						echo "Installing Browser-History"
						pip3 install browser-history
						;;
					23)
						#Castero
						echo "Installing Castero"
						pip3 install castero
						;;
					24)
						#RTV
						echo "Installing RTV"
						pip3 install rtv
						rtv --copy-config
						rtv --copy-mailcap
						"oauth_client_id = E2oEtRQfdfAfNQ
						oauth_client_secret = praw_gapfill
						oauth_redirect_uri = http://127.0.0.1:65000/"
						;;
					25)
						#Rainbow Stream
						echo "Installing Rainbow Stream"
						pip3 install rainbowstream
						;;
					26)
						#eg
						echo "Installing eg!"
						pip3 install eg
						;;
					27)
						#bpytop
						echo "Installing btop"
						pip3 install bpytop
						;;
					28)
						#Openssh-server
						echo "Installing opensssh-server"
						apt-get install openssh-server
						;;
					29)
						#openssh-client
						echo "Installing openssh-client"
						apt-get install openssh-client
						;;
					30)
						#renameutils
						echo "Installing renameutils"
						apt-get install renameutils
						;;
					31)
						#mat2
						echo "Installing mat2"
						apt-get install  mat2
						;;
					32)
						#0AD
						echo "Installing Oad"
						apt-get install 0ad
						;;
					33)
						#yt-dlp
						echo -e "\033[47mInstalling yt-dlp...\033[m0"
						apt-get install yt-dlp
						;;
					34)
						#ffmpeg
						echo "Instaling ffmpeg"
						apt-get install  ffmpeg -y
						;;
					35)
						#Install buku
						echo "Installing buku, bookmark manager"
						pip install buku
						;;
					36)
						#Install Megatools
						echo "Installing Megatools"
						apt-get install megatools -y
						;;
					37)
						#Install Bitwarden-cli
						echo "Installing bitwarden-cli"
						wget https://github.com/bitwarden/cli/releases/download/v1.0.1/bw-linux-1.0.1.zip
						unzip bw-linux-1.0.1.zip
						sudo install bw /usr/local/bin/
						;;
					38)
						#intltool,gtk-4.9.4,autoconf,webkit2.40.5
						echo "Downloading intltool,gtk-4.9.4,auto-confi,webkit-gtk2.40.5"
						wget https://launchpadlibrarian.net/199705878/intltool-0.51.0.tar.gz &&
							wget https://gnome.mirror.digitalpacific.com.au/sources/gtk/4.9/gtk-4.9.4.tar.xz &&
							wget http://ftp.gnu.org/gnu/autoconf/autoconf-latest.tar.xz &&
							wget https://webkitgtk.org/releases/webkitgtk-2.40.5.tar.xz
													;;
												39)
													#VS Code
													o "Installing Visul Code Studio"
													t https://az764295.vo.msecnd.net/stable/6c3e3dba23e8fadc360aed75ce363ba185c49794/code_1.81.1-1691620686_amd64.deb &&
														sudo apt-get install ./code_1.81.1-1691620686_amd64.deb
																											;;
																										40)
																											#protonvpn stable
																											echo "Installing Repo Proton Stable"
																											t https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.3_all.deb &&
																												sudo apt-get install https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.3_all.deb &&
																												sudo apt-get update &&
																												sudo apt-get install protonvpn-cli
																																																							;;
																																																						41)
																																																							#stacer
																																																							echo "Installing stacer and getting tired off repetitive tasks"
																																																							apt-get install  stacer -y
																																																							;;
																																																						42)
																																																							#links2
																																																							echo "Installing links2, have mercy"
																																																							apt-get install  links2
																																																							;;
																																																						43)
																																																							#Install w3m
																																																							echo "Installing w3m"
																																																							apt-get install  w3m
																																																							;;

																																																						44)
																																																							#trash-cli
																																																							echo "Installing trash-cli"
																																																							apt-get install  trash-cli
																																																							;;
																																																						45)
																																																							#kdeconnect
																																																							echo "Installing kde-connect with your mom"
																																																							apt-get install  kdeconnect
																																																							;;
																																																						46)
																																																							#zsh
																																																							echo "Installing more software you still dont know how to use, ZSH!"
																																																							apt-get install  zsh
																																																							;;
																																																						47)
																																																							#ufw
																																																							echo "WIth your browsing habits it will not make a difference, Installing ufw!"
																																																							apt-get install  ufw
																																																							;;
																																																						48)
																																																							#guake
																																																							echo "Installing guake"
																																																							apt-get install  guake
																																																							;;
																																																						49)
																																																							#tmux
																																																							echo "Installing yet another app you dont know how to use, tmux"
																																																							apt-get install  tmux
																																																							;;
																																																						50)
																																																							#yad
																																																							echo "It feels like, Installing the entire software repository, I mean yad"
																																																							apt-get install  yad
																																																							;;
																																																						51)
																																																							#Nodau
																																																							echo "Installing nodau"
																																																							apt-get install nodau
																																																							;;
																																																						52)
																																																							#pwman3
																																																							echo "Installing pwman3"
																																																							apt-get install pwman3
																																																							;;
																																																						53)
																																																							#bwm-ng
																																																							echo "Installing network monitor BWN-NG"
																																																							apt-get install bwn-ng
																																																							;;
																																																						54)
																																																							#calcurse
																																																							echo "Yet another fking calendar"
																																																							apt-get install calcurse
																																																							;;
																																																						55)
																																																							#vnstat monitor
																																																							echo :"Installing vnstat"
																																																							apt-get install vnstat
																																																							;;

																																																						56)
																																																							#Install Vimwiki
																																																							echo "Installing Vimwiki"
																																																							mkdir /home/batan/.config/nvim/pack
																																																							mkdir /home/batan/.config/nvim/pack/plugins/
																																																							mkdir /home/batan/.config/nvim/pack/plugins/start
																																																							git clone https://github.com/vimwiki/vimwiki.git /home/batan/.config/nvim/pack/plugins/start/vimwiki
																																																							nvim -c 'helptags home/batan/.config/nvim/pack/plugins/start/vimwiki/doc' -c quit
																																																							;;
																																																						57)
																																																							#Install Vim-taskwarrior
																																																							echo "Installing Vim-taskwarrior"
																																																							git clone https://github.com/farseer90718/vim-taskwarrior ~/.config/nvim/pack/plugins/start/vim-taskwarrior
																																																							;;
																																																						58)
																																																							#Install Taskwiki
																																																							echo "Installing Taskwiki"
																																																							git clone https://github.com/tools-life/taskwiki.git /home/batan/.config/nvim/pack/plugins/start/taskwiki --branch dev
																																																							nvim -c 'helptags /home/batan/.config/nvim/pack/plugins/start/taskwiki/doc' -c quit
																																																							;;
																																																						59)
																																																							#Install Tabular
																																																							echo "Installing tagbar"
																																																							git clone https://github.com/godlygeek/tabular.git /home/batan/.config/nvim/pack/plugins/start/tabular
																																																							nvim -c 'helptags ~/.config/nvim/pack/plugins/start/vim-tabular/doc' -c quit
																																																							;;
																																																						60)
																																																							#Install Calendar
																																																							echo "Installing Calendar-vim"
																																																							git clone https://github.com/mattn/calendar-vim.git /home/batan/.config/nvim/pack/plugins/start/calendar-vim
																																																							nvim -c 'helptags ~/.config/nvim/pack/plugins/start/calendar/doc' -c quit
																																																							;;
																																																						61)
																																																							#Install Tagbar
																																																							echo "Installing Tagbar"
																																																							git clone https://github.com/majutsushi/tagbar /home/batan/.config/nvim/pack/plugins/start/tagbar
																																																							nvim -c 'helptags ~/.config/nvim/pack/plugins/start/tagbar/doc' -c quit
																																																							;;
																																																						62)
																																																							#Install Vim-plugin-AnsiEsc
																																																							echo "Not sure why but am installing Vim-plugin-AmsiEsc"
																																																							git clone https://github.com/powerman/vim-plugin-AnsiEsc /home/batan/.config/nvim/pack/plugins/start/vim-plugin-AnsiEsc
																																																							nvim -c 'helptags /home/batan/.config/nvim/pack/plugins/start/vim-plugin-AnsiEsc/doc' -c quit
																																																							;;
																																																						63)
																																																							#Install table-mode
																																																							echo "Installing Table-Mode"
																																																							git clone https://github.com/dhruvasagar/vim-table-mode.git /home/batan/.config/nvim/pack/plugins/start/table-mode
																																																							nvim -c 'helptags /home/batan/.config/nvim/pack/plugins/start/vim-table-mode/doc' -c quit
																																																							;;
																																																						64)
																																																							#vimoucompletme
																																																							apt-get install vimoucompleteme -y
																																																							;;
																																																						65)
																																																							#deoplete
																																																							echo "cloning a sheep deoplete"
																																																							git clone https://github.com/Shougo/deoplete.nvim.git /home/batan/.config/nvim/pack/plugins/start/deoplete
																																																							;;
																																																						66)
																																																							#emmet-vim
																																																							echo "Installing emmet-vim"
																																																							git clone https://github.com/mattn/emmet-vim.git /home/batan/.config/nvim/pack/plugins/start/emmet-vim
																																																							;;
																																																						67)
																																																							#ale
																																																							echo "Installing ALE"
																																																							git clone https://github.com/dense-analysis/ale.git /home/batan/.config/nvim/pack/plugins/start/ale
																																																							;;
																																																						68)
																																																							#html5.vim
																																																							echo "Installing html5.vim"
																																																							git clone https://github.com/othree/html5.vim.git /home/batan/.config/nvim/pack/plugins/start/html5.vim
																																																							;;
																																																						69)
																																																							#surround-vim
																																																							echo "installing surround-vim"
																																																							git clone https://github.com/tpope/vim-surround.git /home/batan/.config/nvim/pack/plugins/start/surround-vim
																																																							;;
																																																						70)
																																																							#vim-lsp
																																																							echo "Installing Vim-Lsp"
																																																							git clone https://github.com/prabirshrestha/vim-lsp /home/batan/.config/nvim/pack/plugin/start/vim-lsp.git
																																																							;;
																																																						71)
																																																							#vim-lsp
																																																							echo "Installing Vim-Lsp-Ale"
																																																							git clone https://github.com/rhysd/vim-lsp-ale.git /home/batan/.config/nvim/pack/plugin/start/vim-lsp-ale.git
																																																							;;
																																																						72)
																																																							#Prettier
																																																							echo "Installing Prettier"
																																																							git clone https://github.com/prettier/prettier.git ~/.config/nvim/pack/plugins/start/prettier/
																																																							;;
																																																						73)
																																																							#Unite.vim
																																																							echo "Installing Unite.vim"
																																																							git clone https://github.com/Shougo/unite.vim.git ~/.config/nvim/pack/plugins/start/unite.vim
																																																							;;
																																																						74)
																																																							#Turtle Note
																																																							echo "Downloading Turtle Note. Dont forget to install manually"
																																																							;;
																																																						75)
																																																							#Megasync
																																																							echo "Downloading Megasync from homepage"
																																																							wget https://mega.nz/linux/repo/xUbuntu_23.04/amd64/megasync-xUbuntu_23.04_amd64.deb && sudo apt-get install "$PWD/megasync-xUbuntu_23.04_amd64.deb"
																																																							;;
																																																						76)
																																																							#speedread
																																																							echo "Cloning text reader for dyslexic linux users"
																																																							git clone https://github.com/pasky/speedread.git
																																																							;;
																																																						77)
																																																							#shalarm
																																																							echo "Cloning shalarm"
																																																							git clone https://github.com/jahendrie/shalarm.git
																																																							;;
																																																						78)
																																																							#speedtest-cli
																																																							echo "Installing speedtest-cli, you are with telstra, only god knows why you need this tool!"
																																																							apt-get install speedtest-cli
																																																							;;
																																																						79)
																																																							#festival
																																																							echo "Installing festival"
																																																							apt-get install festival
																																																							;;
																																																						80)
																																																							#Espeak
																																																							echo "Installing espeak"
																																																							apt-get install espeak
																																																							;;
																																																						81)
																																																							#Terminor
																																																							echo "Installing Terminator"
																																																							apt-get install festvox-us-slt-hts
																																																							;;
																																																						82)
																																																							#Festvox-us-slt-hts
																																																							echo "Installing Festvox-us"
																																																							sudo apt-get install festvox-us-slt-hts
																																																							;;
																																																						83)
																																																							#fzf
																																																							echo "Installing fzf"
																																																							sudo apt-get install fzf
																																																							;;
																																																						84)
																																																							#rofi
																																																							echo "Installing rofi"
																																																							sudo apt-get install rofi
																																																							;;
																																																						85)
																																																							#ddgr
																																																							echo "Installing ddgr"
																																																							sudo apt-get install ddgr
																																																							;;
																																																						86)
																																																							#tldr
																																																							echo "Installing tldr"
																																																							sudo apt-get install tldr
																																																							;;
																																																						87)
																																																							#Protovpn Stable
																																																							echo "installing ProtonVPN-stable"
																																																							wget https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.3-2_all.deb
																																																							sudo apt-get install ./protonvpn-stable-release_1.0.3-2_all.deb
																																																							;;
																																																						88)
																																																							#Ctags
																																																							echo "Installing Exuberant Ctags"
																																																							sudo apt-get install exuberant-ctags
																																																							;;
																																																						89)
																																																							#Chs and Stockfish
																																																							echo "Installing stockfish and chs"
																																																							pip3 install chs
																																																							sudo apt-get install stockfish
																																																							pipx install chs
																																																							;;
																																																						90)
																																																							#Liferea
																																																							echo "Installing Liferea"
																																																							sudo apt instlal liferea
																																																							;;
																																																						91)
																																																							#Newsboat
																																																							echo "Installing Liferera"
																																																							sudo apt-get install newboat
																																																							;;
																																																						92)
																																																							#Install Graphne Theme
																																																							git clone https://github.com/vinceliuice/Graphite-gtk-theme.git
																																																							cd Graphite-gtk-theme
																																																							./install.sh

																																																							;;
																																																						93)
																																																							#Obsidian Theme
																																																							echo "Installing Obsidian Theme...!"
																																																							apt-get install obsidian-2-gtk-theme
																																																							;;
																																																						94)
																																																							#Obsidian Icon Theme
																																																							echo "Installing Obsidian-Icon-Theme"
																																																							apt-get install obsidian-icon-theme
																																																							;;
																																																						95)
																																																							#Falkon
																																																							echo "Installing falkon browser"
																																																							apt-get install falkon
																																																							;;
																																																						96)
																																																							#Kodi
																																																							echo "Installing Kodi and Repos"
																																																							apt-get install kodi kodi-repository-kodi
																																																							;;
																																																						97)
																																																							#Awsom Vim COlorschemes
																																																							echo "Cloning Awsom VIm Colorscheems"
																																																							git clone https://github.com/rafi/awesome-vim-colorschemes.git /home/batan/.config/nvim/pack/plugins/start/awsome-vim-colorschemes
																																																							;;
																																																						98)
																																																							#VIM PLUGINS
																																																							echo "Installing all VIM Plugins"
																																																							git clone https://github.com/vimwiki/vimwiki.git /home/batan/.vim/pack/plugins/start/vimwiki
																																																							git clone https://github.com/farseer90718/vim-taskwarrior /home/batan/.vim/pack/plugins/start/vim-taskwarrior
																																																							git clone https://github.com/tools-life/taskwiki.git /home/batan/.vim/pack/plugins/start/taskwiki --branch dev
																																																							git clone https://github.com/godlygeek/tabular.git /home/batan/.vim/pack/plugins/start/tabular
																																																							git clone https://github.com/mattn/calendar-vim.git /home/batan/.vim/pack/plugins/start/calendar-vim
																																																							git clone https://github.com/majutsushi/tagbar /home/batan/.vim/pack/plugins/start/tagbar
																																																							git clone https://github.com/powerman/vim-plugin-AnsiEsc /home/batan/.vim/pack/plugins/start/vim-plugin-AnsiEsc
																																																							git clone https://github.com/dhruvasagar/vim-table-mode.git /home/batan/.vim/pack/plugins/start/table-mode
																																																							git clone https://github.com/Shougo/deoplete.nvim.git /home/batan/.vim/pack/plugins/start/deoplete
																																																							git clone https://github.com/mattn/emmet-vim.git /home/batan/.vim/pack/plugins/start/emmet-vim
																																																							git clone https://github.com/dense-analysis/ale.git /home/batan/.vim/pack/plugins/start/ale
																																																							git clone https://github.com/othree/html5.vim.git /home/batan/.vim/pack/plugins/start/html5.vim
																																																							git clone https://github.com/tpope/vim-surround.git /home/batan/.vim/pack/plugins/start/surround-vim
																																																							git clone https://github.com/prabirshrestha/vim-lsp /home/batan/.vim/pack/plugin/start/vim-lsp.git
																																																							git clone https://github.com/rhysd/vim-lsp-ale.git /home/batan/.vim/pack/plugin/start/vim-lsp-ale.git
																																																							git clone https://github.com/prettier/prettier.git /home/batan/.vim/pack/plugins/start/prettier/
																																																							git clone https://github.com/Shougo/unite.vim.git /home/batan/.vim/pack/plugins/start/unite.vim
																																																							git clone https://github.com/rafi/awesome-vim-colorschemes.git /home/batan/.vim/pack/plugins/start/awsome-vim-colorschemes
																																																							;;
																																																						99)
																																																							#NVIM PLUGINS
																																																							echo "Installing all NVIM Plugins"
																																																							git clone https://github.com/vimwiki/vimwiki.git /home/batan/.config/nvim/pack/plugins/start/vimwiki
																																																							git clone https://github.com/farseer90718/vim-taskwarrior /home/batan/.config/nvim/pack/plugins/start/vim-taskwarrior
																																																							git clone https://github.com/tools-life/taskwiki.git /home/batan/.config/nvim/pack/plugins/start/taskwiki --branch dev
																																																							git clone https://github.com/godlygeek/tabular.git /home/batan/.config/nvim/pack/plugins/start/tabular
																																																							git clone https://github.com/mattn/calendar-vim.git /home/batan/.config/nvim/pack/plugins/start/calendar-vim
																																																							git clone https://github.com/majutsushi/tagbar /home/batan/.config/nvim/pack/plugins/start/tagbar
																																																							git clone https://github.com/powerman/vim-plugin-AnsiEsc /home/batan/.config/nvim/pack/plugins/start/vim-plugin-AnsiEsc
																																																							git clone https://github.com/dhruvasagar/vim-table-mode.git /home/batan/.config/nvim/pack/plugins/start/table-mode
																																																							git clone https://github.com/Shougo/deoplete.nvim.git /home/batan/.config/nvim/pack/plugins/start/deoplete
																																																							git clone https://github.com/mattn/emmet-vim.git /home/batan/.config/nvim/pack/plugins/start/emmet-vim
																																																							git clone https://github.com/dense-analysis/ale.git /home/batan/.config/nvim/pack/plugins/start/ale
																																																							git clone https://github.com/othree/html5.vim.git /home/batan/.config/nvim/pack/plugins/start/html5.vim
																																																							git clone https://github.com/tpope/vim-surround.git /home/batan/.config/nvim/pack/plugins/start/surround-vim
																																																							git clone https://github.com/prabirshrestha/vim-lsp /home/batan/.config/nvim/pack/plugin/start/vim-lsp.git
																																																							git clone https://github.com/rhysd/vim-lsp-ale.git /home/batan/.config/nvim/pack/plugin/start/vim-lsp-ale.git
																																																							git clone https://github.com/prettier/prettier.git /home/batan/.config/nvim/pack/plugins/start/prettier/
																																																							git clone https://github.com/Shougo/unite.vim.git /home/batan/.config/nvim/pack/plugins/start/unite.vim


																																																							;;


																																																					esac
																																																				done
						fi
					}
	#}}} <#1370
#{{{ >>>   install_cloudflared >#1371
install_cloudflared() {
curl -fsSL https://pkg.cloudflare.com/pubkey.gpg | sudo tee /etc/apt/trusted.gpg.d/cloudflare.asc
echo "deb http://pkg.cloudflare.com/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudflare.list
sudo apt-get update && sudo apt-get install cloudflared
}
#}}} <#1377
#{{{ >>>   install_falkon >#1378
install_falkon() {
DEPS_FALKON=(kpackagetool5 libaccounts-glib0 libaccounts-qt5-1 libdmtx0b libkaccounts2 libkf5bluezqt-data libkf5bluezqt6 libkf5declarative-data libkf5declarative5 libkf5package-data libkf5package5 libkf5prison5 libkf5prisonscanner5 libkf5purpose-bin libkf5purpose5 libkf5quickaddons5 libqt5multimedia5 libqt5qmlworkerscript5 libqt5quickcontrols2-5 libqt5quicktemplates2-5 libqt5webengine5 libsignon-qt5-1 qml-module-org-kde-bluezqt qml-module-org-kde-kquickcontrolsaddons qml-module-org-kde-prison qml-module-qt-labs-folderlistmodel qml-module-qt-labs-settings qml-module-qtqml qml-module-qtquick-controls2 qml-module-qtquick-dialogs qml-module-qtquick-privatewidgets qml-module-qtquick-templates2 qml-module-qtquick-window2 qml-module-qtquick2 qml-module-qtwebengine)

for pack in ${DEPS_FALKON[@]}, do
dpkg -s $pack >/dev/null 2>&1
if [[ $? == 1 ]]; then
echo -e "\033[34mInstalling \033[31m$pack \033[34m...\033[0m"
sudo apt install -y $pack >/dev/null 2>&1
fi
done

}
#}}} <#1391
#{{{ >>>   install_encryptpad >#1392
install_encryptpad() {
  DEPS=(qtbase5-dev gcc g++ make python3 zlib1g-dev pkg-config)

  for pkg in "${DEPS[@]}"; do
    if ! dpkg -s "$pkg" &>/dev/null; then
      echo -e "\033[34mInstalling \033[32m$pkg\033[0m"
      sudo apt-get install -y "$pkg" >/dev/null
    fi
  done

  if [[ -d encryptpad ]]; then rm -rf encryptpad; fi
  git clone https://github.com/ParrotSec/encryptpad.git
  cd encryptpad || return
  ./configure.py --build-botan --build-zlib
  make -j"$(nproc)"
  sudo make install
}
#}}} <#1410
#{{{ >>>   install_gnome-boxes >#1411
install_gnome-boxes() {
DEPS_GNOME_BOXES="dmeventd gnome-boxes gnutls-bin ibverbs-providers ipxe-qemu libaio1 libboost-thread1.74.0 libbrlapi0.8 libcacard0 libcapstone4 libcue2 libdevmapper-event1.02.1 libexecs0 libexempi8 libexiv2-27 libfdt1 libfmt9 libgexiv2-2 libgfapi0 libgfrpc0 libgfxdr0 libglusterfs0 libgnutls-dane0 libgsf-1-114 libgsf-1-common libgxps2 libibverbs1 libiptcdata0 libiscsi7 liblvm2cmd2.03 libosinfo-1.0-0 libosinfo-bin libosinfo-l10n libphodav-3.0-0 libphodav-3.0-common librados2 librbd1 librdmacm1 libslirp0 libspice-client-glib-2.0-8 libspice-client-gtk-3.0-5 libspice-server1 libssh-4 libtotem-plparser-common libtotem-plparser18 libtpms0 libtracker-sparql-3.0-0 libunbound8 libusbredirhost1 libusbredirparser1 libvdeplug2 libvirglrenderer1 libvirt-daemon-driver-lxc libvirt-daemon-driver-qemu libvirt-daemon-driver-vbox libvirt-daemon-driver-xen libvirt-daemon libvirt-glib-1.0-0 libvirt-glib-1.0-data libvirt-l10n libvirt0 libxencall1 libxendevicemodel1 libxenevtchn1 libxenforeignmemory1 libxengnttab1 libxenhypfs1 libxenmisc4.17 libxenstore4 libxentoolcore1 libxentoollog1 lvm2 netcat-openbsd osinfo-db ovmf qemu-block-extra qemu-system-common qemu-system-data qemu-system-gui qemu-system-x86 qemu-utils seabios spice-client-glib-usb-acl-helper swtpm-libs swtpm-tools swtpm thin-provisioning-tools tracker-extract tracker-miner-fs tracker spice-vdagent spice-webdavd"

for pack in ${DEPS_GNOME_BOXES[@]}, do
dpkg -s $pack >/dev/null 2>&1
if [[ $? == 1 ]]; then
echo -e "\033[34mInstalling \033[31m$pack \033[34m...\033[0m"
sudo apt install -y $pack >/dev/null 2>&1
fi
done

}
#}}} <#1424
#{{{ >>>   install_budgie >#1425
install_budgie() {
	DEPS_BUDGIE=(budgie-app-launcher-applet budgie-dropby-applet budgie-recentlyused-applet budgie-applications-menu-applet budgie-extras-common budgie-rotation-lock-applet budgie-appmenu-applet budgie-extras-daemon budgie-showtime-applet budgie-brightness-controller-applet budgie-fuzzyclock-applet budgie-sntray-plugin budgie-clockworks-applet budgie-hotcorners-applet budgie-takeabreak-applet budgie-control-center budgie-indicator-applet budgie-trash-applet budgie-control-center-data budgie-kangaroo-applet budgie-visualspace-applet budgie-core budgie-keyboard-autoswitch-applet budgie-wallstreet budgie-network-manager-applet budgie-weathershow-applet budgie-countdown-applet budgie-previews budgie-window-shuffler budgie-desktop budgie-previews-applet budgie-workspace-stopwatch-applet budgie-desktop-doc budgie-quickchar budgie-workspace-wallpaper-applet budgie-desktop-view budgie-quicknote-applet)

for pack in ${DEPS_BUDGIE[@]};
do
dpkg -s $pack>/dev/null 2>&1
if [[ $? == 1 ]];
then
	echo -e "\033[34mInstalling \033[32m$pack \033[34m...\033[0m"
	sudo apt install $pack -y >/dev/null 2>&1
fi
done
}
#}}} <#1439
#{{{ >>>   install_xfce4 >#1440
install_xfce4() {
DEPS_XFCE="catfish desktop-defaults-mx-xfce-desktop desktop-defaults-mx-xfce-system mx23-artwork xfce-superkey-mx xfce4-appfinder xfce4-battery-plugin xfce4-clipman xfce4-cpufreq-plugin xfce4-cpugraph-plugin xfce4-datetime-plugin xfce4-diskperf-plugin xfce4-docklike-plugin xfce4-fsguard-plugin xfce4-genmon-plugin xfce4-mount-plugin xfce4-netload-plugin xfce4-notes xfce4-notes-plugin xfce4-notifyd xfce4-panel xfce4-places-plugin xfce4-power-manager xfce4-power-manager-data xfce4-power-manager-plugins xfce4-pulseaudio-plugin xfce4-screenshooter xfce4-sensors-plugin xfce4-session xfce4-settings xfce4-smartbookmark-plugin xfce4-systemload-plugin xfce4-taskmanager xfce4-terminal xfce4-timer-plugin xfce4-verve-plugin xfce4-wavelan-plugin xfce4-weather-plugin xfce4-whiskermenu-plugin xfce4-xkb-plugin xfwm4 xfconf xfdesktop4 xfdesktop4-data thunar-archive-plugin thunar-shares-plugin thunar-modified-desktop-file thunar-data thunar-gtkhash thunar-volman thunar-custom-actions-mx mx-comfort-themes"
for pak in ${DEPS_XFCE[@]}; do
	dpkg -s $pak >/dev/null 2>&1
	if [[ $? == "1" ]]; then
		echo -e "\033[34mInstalling \033[32m$pak \033[34m...\033[0m"
		sudo apt-get install -y $pak >/dev/null 2>&1
	fi
done
}
#}}} <#1451
#{{{ >>>   install_gnome_base >#1452
install_gnome-base() {
DEPS_GNOME_BASE="apg desktop-base evolution-data-server-common fonts-quicksand gdm3 geocode-glib-common gir1.2-accountsservice-1.0 gir1.2-adw-1 gir1.2-gdesktopenums-3.0 gir1.2-gdm-1.0 gir1.2-geoclue-2.0 gir1.2-gnomebluetooth-3.0 gir1.2-gnomedesktop-3.0 gir1.2-gweather-4.0 gir1.2-ibus-1.0 gir1.2-javascriptcoregtk-4.1 gir1.2-mutter-11 gir1.2-nm-1.0 gir1.2-nma-1.0 gir1.2-rsvg-2.0 gir1.2-soup-3.0 gir1.2-upowerglib-1.0 (0. gir1.2-webkit2-4.1 gnome-backgrounds gnome-bluetooth-3-common gnome-control-center-data gnome-control-center gnome-desktop3-data gnome-panel-data gnome-panel gnome-session-bin gnome-session-common gnome-session gnome-settings-daemon-common gnome-settings-daemon gnome-shell-common (43. gnome-shell-extensions gnome-shell (43. gstreamer1.0-pipewire libcamel-1.2-64 libcolord-gtk4-1 libcrack2 (2. libcue2 libecal-2.0-2 libedataserver-1.2-27 libexempi8 libgdm1 libgeoclue-2-0 libgeocode-glib-2-0 libgexiv2-2 libgjs0g libgnome-autoar-0-0 libgnome-bg-4-2 libgnome-bluetooth-3.0-13 libgnome-bluetooth-ui-3.0-13 libgnome-desktop-3-20 libgnome-desktop-4-2 libgnome-panel0 libgnome-rr-4-2 libgoa-backend-1.0-1 libgsound0 libgtop-2.0-11 libgtop2-common libgweather-4-0 libgweather-4-common libgxps2 libibus-1.0-5 libiptcdata0 libmozjs-102-0 libmutter-11-0 libosinfo-1.0-0 libosinfo-l10n libportal-gtk4-1 libportal1 libpwquality-common libpwquality1 librest-1.0-0 (0. libsnapd-glib-2-1 libtotem-plparser-common libtotem-plparser18 libtracker-sparql-3.0-0 libxkbregistry0 mutter-common nautilus osinfo-db tracker-extract tracker-miner-fs tracker usb.ids webp-pixbuf-loader xwayland"

for i in ${DEPS_GNOME_BASE[@]};
do
	dpkg -s $i >/dev/null 2>&1
	if [[ $? == 1 ]];
	then
		echo -e "\033[34mInstalling \033[31m$i \033[34m...\033[0m"
		sudo apt install -y $i >/dev/null 2>&1
	fi
done
}
#}}} <#1466
#{{{ >>>   install_mate >#1467
install_mate() {

DEPS_MATE="mate-core mate-desktop-environment mate-desktop-environment-core caja marco mate-control-center mate-desktop mate-icon-theme mate-menus mate-notification-daemon mate-panel mate-polkit mate-session-manager mate-settings-daemon mate-terminal mate-themes"

for pak in ${DEPS_MATE[@]}; do
  dpkg -s $pak >/dev/null 2>&1
  if [[ $? == "1" ]]; then
    echo -e "\033[34mInstalling \033[32m$pak\033[34m ...\033[0m"
    sudo apt-get install -y $pak >/dev/null 2>&1
}
#}}} <#1478
#{{{ >>>   install_dwm >#1479
install_dwm() {
git clone https://github.com/baann/dwm
cd dwm
make
sudo make install
}
#}}} <#1486

#{{{ >>>   install_kodi >#1488
install_kodi() {
DEPS_KODI=(fonts-noto-hinted fonts-roboto-hinted fonts-roboto-unhinted javascript-common kodi kodi-bin kodi-data kodi-eventclients-common kodi-eventclients-kodi-send kodi-eventclients-ps3 kodi-eventclients-python kodi-game-libretro kodi-inputstream-adaptive kodi-inputstream-ffmpegdirect kodi-peripheral-joystick kodi-peripheral-xarcade kodi-pvr-mythtv kodi-repository-kodi kodi-tools-texturepacker kodi-vfs-sftp kodi-visualization-fishbmc kodi-visualization-shadertoy kodi-visualization-shadertoy-data kodi-visualization-spectrum libboost-python1.74.0 libcec6 libcrossguid0 libdate-tz3 libfstrcmp0 libiso9660-11 libjs-iscroll libjs-jquery libjsoncpp25 libkissfft-float131 liblirc-client0 libmariadb3 libmicrohttpd12 libnfs13 libp8-platform2 libpcrecpp0v5 libshairplay0 libspdlog1.10 libtinyxml2.6.2v5 libva-wayland2 libwayland-client++1 libwayland-cursor++1 libwayland-egl++1 libwebm1 mariadb-common minidlna mysql-common python3-bluez python3-gattlib python3-pycryptodome python3-usb)
for pack in ${DEPS_KODI[@]}; do
dpkg -s $pack >/dev/null 2>&1
if [[ $? == 1 ]]; then
echo -e "\033[34mInstalling \033[31m$pack \033[34m...\033[0m"
sudo apt install -y $pack >/dev/null 2>&1
fi
done
#ADDONS
echo -e "\033[34mGetting zip from \033[33mAussieAddons\033[34m ...\033[0m"
wget https://github.com/aussieaddons/repo/archive/refs/heads/master.zip
echo -e "\033[34mGetting TheCrewTeam.zip from \033[33mTheCrewTeam\033[34m ...\033[0m"
wget https://github.com/team-crew/team-crew.github.io/blob/master/repository.thecrew-0.3.7.zip
}
#}}} <#1504
#{{{>>>    install_ollama >#1505
install_ollama() {
#remove any old libraries
sudo rm -rf /usr/lib/ollama

#Download and extract the package:
curl -L https://ollama.com/download/ollama-linux-amd64.tgz -o ollama-linux-amd64.tgz
sudo tar -C /usr -xzf ollama-linux-amd64.tgz

#run ollama
ollama serve

#Create the ollama user:
sudo useradd -r -s /bin/false -U -m -d /usr/share/ollama ollama
sudo usermod -a -G ollama $(whoami)

#Create the systemd service file:
cat <<EOF | sudo tee /etc/systemd/system/ollama.service
[Unit]
Description=Ollama Service
After=network-online.target

[Service]
ExecStart=/usr/bin/ollama serve
User=ollama
Group=ollama
Restart=always
RestartSec=3
Environment="PATH=$PATH"

[Install]
WantedBy=default.target
EOF
}
#}}} <#1539
#{{{>>>   install_ollama_mistral >#1540
install_ollama_mistral() {
for file in python3-venv python3-pip pipx python3-dev; do
	dpkg -s $file &>/dev/null 2>&1
	if [[ $? -eq 1 ]]; then
		echo -e "\033[0;33mInstalling \033[0;32m$file\033[0m"
		sudo apt install -y $file >/dev/null 2>&1
	fi
	done

python3 -m .venv /home/batan/.venv
source /home/batan/.venv/bin/activate

  pipx install langchain sentence_transformers faiss-cpu ctransformers


  cat<< 'EOL'>mini-lm-file-creation.py
  """
This script creates a database of information gathered from local text files.
"""

from langchain.document_loaders import DirectoryLoader, TextLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.embeddings import HuggingFaceEmbeddings
from langchain.vectorstores import FAISS

# define what documents to load
loader = DirectoryLoader("./", glob="*.txt", loader_cls=TextLoader)

# interpret information in the documents
documents = loader.load()
splitter = RecursiveCharacterTextSplitter(chunk_size=500,
                                          chunk_overlap=50)
texts = splitter.split_documents(documents)
embeddings = HuggingFaceEmbeddings(
    model_name="sentence-transformers/all-MiniLM-L6-v2",
    model_kwargs={'device': 'cpu'})

# create and save the local database
db = FAISS.from_documents(texts, embeddings)
db.save_local("faiss")
EOL

cat<< 'EOL'>LM-reads-vector-FAISS-database.py
"""
This script creates a database of information gathered from local text files.
"""

from langchain.document_loaders import DirectoryLoader, TextLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.embeddings import HuggingFaceEmbeddings
from langchain.vectorstores import FAISS

# define what documents to load
loader = DirectoryLoader("./", glob="*.txt", loader_cls=TextLoader)

# interpret information in the documents
documents = loader.load()
splitter = RecursiveCharacterTextSplitter(chunk_size=500,
                                          chunk_overlap=50)
texts = splitter.split_documents(documents)
embeddings = HuggingFaceEmbeddings(
    model_name="sentence-transformers/all-MiniLM-L6-v2",
    model_kwargs={'device': 'cpu'})

# create and save the local database
db = FAISS.from_documents(texts, embeddings)
db.save_local("faiss")
EOL
}
#}}} <#1610
#{{{>>>   install_nix >#1611
install_nix() {
	sudo apt install nix-setup-systemd -y
    sh <(curl -L https://nixos.org/nix/install) --daemon
    nix-channel --update
	clear
	echo -e "\033[34mTo install packages run:"
	echo -e "\033[37m nix-env -iA nixpkgs.neovim\033[0m"
}
#}}} <#1620
#{{{ >>>   install_steam >#1621
install_steam() {
for package in ${DEPS_STEAM[@]}; do
	dpkg -s $package >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo -e "\033[33mInstalling \033[4m$package \033[33m...\033[0m"
		sudo apt-get install -y $package>>/dev/null 2>&1
	fi
done
}
#}}} <#1631
#{{{>>>   install_cubic >#1632
install_cubic() {
sudo apt install --no-install-recommends dpkg
echo "deb https://ppa.launchpadcontent.net/cubic-wizard/release/ubuntu/ noble main" | sudo tee /etc/apt/sources.list.d/cubic-wizard-release.list
curl -S "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x081525e2b4f1283b" | sudo gpg --batch --yes --dearmor --output /etc/apt/trusted.gpg.d/cubic-wizard-ubuntu-release.gpg

sudo apt update
sudo apt install --no-install-recommends cubic
}
#}}} <#1641
#{{{>>>   install_anonsurf >#1642
install_anonsurf() {
git clone https://github.com/ParrotSec/anonsurf.git
cd anonsurf
sudo make
sudo make install
cd
}
#}}} <#1650
#{{{>>>   install_funkwhale >#1651
install_funkwhale() {

DEPS_DOCKER_DEBIAN="docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin ca-certificates curl gnupg lsb-release"

for pak in ${DEPS_DOCKER_DEBIAN[@]};
do
	dpkg -s $pak >/dev/null 2>&1
	if [[ $? == '1' ]];
	then
		echo -e "\033[33mInstalling $pak\033[0m"
		sudo apt install $pak -y
	else
		echo -e "\033[33m$pak already installed\033[0m"
	fi
done

# Function to display error and exit
error_exit() {
  echo "Error: $1" >&2
  exit 1
}

# Verifying Debian and Ubuntu
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	if [ -f /etc/os-release ]; then
		# Source the os-release file to get distribution info
		. /etc/os-release
		OS=$NAME
		VER=$VERSION_ID
	elif [ -f /etc/lsb-release ]; then
		# For older systems, use lsb_release if available
		. /etc/lsb-release
		OS=$DISTRIB_ID
		VER=$DISTRIB_RELEASE
	elif [ -f /etc/debian_version ]; then
		# For Debian-based systems without os-release
		OS="Debian"
		VER=$(cat /etc/debian_version)
	else
		# Unknown Linux system
		OS=$(uname -s)
		VER=$(uname -r)
	fi
fi
echo -e "${B}Detected Linux system:$OS"
DITRIB=$OS



# Installing Docker on Ubuntu

#if [[ $DITRIB == 'Ubuntu']];
#then
#
#for dependency in ${DEPS_DOCKER_UBUNTU[@]};
#do
#	dpkg -s $dependency >/dev/null 2>&1
#	if [[ $? == '1' ]];
#then
#	echo -e "\033[33mInstalling $dependency\033[0m"
#	sudo apt install $dependency -y
#else
#	echo -e "\033[33m$dependency already installed\033[0m"
#	fi
#


#if [[ $DISTRIB == 'Debian']];
#then

# Update the package list and install prerequisites
echo "Updating package list and installing prerequisites..."
sudo apt update || error_exit "Failed to update package list"
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release || error_exit "Failed to install prerequisites"

# Add Docker's official GPG key
echo "Adding Docker's official GPG key..."
sudo mkdir -p /etc/apt/keyrings || error_exit "Failed to create keyring directory"
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg || error_exit "Failed to add Docker's GPG key"

# Set up the Docker repository
echo "Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null || error_exit "Failed to set up Docker repository"

# Update package list and install Docker
echo "Installing Docker..."
sudo apt update || error_exit "Failed to update package list"

#if [[ $DITRIB == 'Debian']];
#then
#
#for dependency in ${DEPS_DOCKER_DEBIAN[@]};
#do
#	dpkg -s $dependency >/dev/null 2>&1
#	if [[ $? == '1' ]];
#then
#	echo -e "\033[33mInstalling $dependency\033[0m"
#	sudo apt install $dependency -y
#else
#	echo -e "\033[33m$dependency already installed\033[0m"
#	fi
#done
#sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || error_exit "Failed to install Docker"

# Verify Docker installation
echo "Verifying Docker installation..."
docker --version || error_exit "Docker installation failed"

# Prompt for Funkwhale configuration
read -e -p "Enter the Funkwhale hostname (e.g., yourdomain.funkwhale): " -i 'funkwhale' FUNKWHALE_HOSTNAME
read -e -p "Enter the full path for Funkwhale data directory (e.g., /path/to/data): " -i '/media/batan/100/Music/data' DATA_DIR
read -e -p "Enter the full path for Funkwhale music directory (e.g., /path/to/music): " -i '/media/batan/100/Music/' MUSIC_DIR

if [[ ! -d "$DATA_DIR" ]]; then
	mkdir -p "$DATA_DIR"
fi


# Check if directories exist
[ ! -d "$DATA_DIR" ] && error_exit "Data directory does not exist: $DATA_DIR"
[ ! -d "$MUSIC_DIR" ] && error_exit "Music directory does not exist: $MUSIC_DIR"

# Run the Funkwhale Docker container
echo "Running Funkwhale container..."
docker run \
    --name=funkwhale \
    -e FUNKWHALE_HOSTNAME="$FUNKWHALE_HOSTNAME" \
    -e NESTED_PROXY=0 \
    -v "$DATA_DIR:/data" \
    -v "$MUSIC_DIR:/music:ro" \
    -p 3030:80 \
    thetarkus/funkwhale || error_exit "Failed to start Funkwhale container"

echo "Funkwhale is now running. Access it at http://localhost:3030 or http://$FUNKWHALE_HOSTNAME"


}
#}}} <#1795

#{{{ >>>   install_grub >#1797
install_grub() {
if [[ d != /home/batan/themes ]]; then
sudo mkdir -p /home/batan/themes
fi
git clone https://github.com/batann/Vimix /home/batan/themes

install.grub.sh<<EOF>cat
#!/bin/bash

#THEME_DIR='/usr/share/grub/themes'
THEME_DIR='/boot/grub/themes'
THEME_NAME=''

function echo_title() {     echo -ne "\033[1;44;37m${*}\033[0m\n"; }
function echo_caption() {   echo -ne "\033[0;1;44m${*}\033[0m\n"; }
function echo_bold() {      echo -ne "\033[0;1;34m${*}\033[0m\n"; }
function echo_danger() {    echo -ne "\033[0;31m${*}\033[0m\n"; }
function echo_success() {   echo -ne "\033[0;32m${*}\033[0m\n"; }
function echo_warning() {   echo -ne "\033[0;33m${*}\033[0m\n"; }
function echo_secondary() { echo -ne "\033[0;34m${*}\033[0m\n"; }
function echo_info() {      echo -ne "\033[0;35m${*}\033[0m\n"; }
function echo_primary() {   echo -ne "\033[0;36m${*}\033[0m\n"; }
function echo_error() {     echo -ne "\033[0;1;31merror:\033[0;31m\t${*}\033[0m\n"; }
function echo_label() {     echo -ne "\033[0;1;32m${*}:\033[0m\t"; }
function echo_prompt() {    echo -ne "\033[0;36m${*}\033[0m "; }

function splash() {
    local hr
    hr=" **$(printf "%${#1}s" | tr ' ' '*')** "
    echo_title "${hr}"
    echo_title " * $1 * "
    echo_title "${hr}"
    echo
}

function check_root() {
    # Checking for root access and proceed if it is present
    ROOT_UID=0
    if [[ ! "${UID}" -eq "${ROOT_UID}" ]]; then
        # Error message
        echo_error 'Run me as root.'
        echo_info 'try sudo ./install.sh'
        exit 1
    fi
}

function select_theme() {
    themes=( 'Vimix' )

    echo '\nChoose The Theme You Want: '
                splash 'Installing Vimix Theme...'
}

function backup() {
    # Backup grub config
    echo_info 'cp -an /etc/default/grub /etc/default/grub.bak'
    cp -an /etc/default/grub /etc/default/grub.bak
}

function install_theme() {
    # create themes directory if not exists
    if [[ ! -d "${THEME_DIR}/${THEME_NAME}" ]]; then
        # Copy theme
        echo_primary "Installing ${THEME_NAME} theme..."

        echo_info "mkdir -p \"${THEME_DIR}/${THEME_NAME}\""
        mkdir -p "${THEME_DIR}/${THEME_NAME}"

        echo_info "cp -a ./themes/\"${THEME_NAME}\"/* \"${THEME_DIR}/${THEME_NAME}\""
        cp -a ./themes/"${THEME_NAME}"/* "${THEME_DIR}/${THEME_NAME}"
    fi
}

function config_grub() {
    echo_primary 'Enabling grub menu'
    # remove default grub style if any
    echo_info "sed -i '/GRUB_TIMEOUT_STYLE=/d' /etc/default/grub"
    sed -i '/GRUB_TIMEOUT_STYLE=/d' /etc/default/grub

    echo_info "echo 'GRUB_TIMEOUT_STYLE=\"menu\"' >> /etc/default/grub"
    echo 'GRUB_TIMEOUT_STYLE="menu"' >> /etc/default/grub

    #--------------------------------------------------

    echo_primary 'Setting grub timeout to 60 seconds'
    # remove default timeout if any
    echo_info "sed -i '/GRUB_TIMEOUT=/d' /etc/default/grub"
    sed -i '/GRUB_TIMEOUT=/d' /etc/default/grub

    echo_info "echo 'GRUB_TIMEOUT=\"60\"' >> /etc/default/grub"
    echo 'GRUB_TIMEOUT="60"' >> /etc/default/grub

    #--------------------------------------------------

    echo_primary "Setting ${THEME_NAME} as default"
    # remove theme if any
    echo_info "sed -i '/GRUB_THEME=/d' /etc/default/grub"
    sed -i '/GRUB_THEME=/d' /etc/default/grub

    echo_info "echo \"GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"\" >> /etc/default/grub"
    echo "GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"" >> /etc/default/grub

    #--------------------------------------------------

    echo_primary 'Setting grub graphics mode to auto'
    # remove default timeout if any
    echo_info "sed -i '/GRUB_GFXMODE=/d' /etc/default/grub"
    sed -i '/GRUB_GFXMODE=/d' /etc/default/grub

    echo_info "echo 'GRUB_GFXMODE=\"auto\"' >> /etc/default/grub"
    echo 'GRUB_GFXMODE="auto"' >> /etc/default/grub
}

function update_grub() {
    # Update grub config
    echo_primary 'Updating grub config...'
    if [[ -x "$(command -v update-grub)" ]]; then
        echo_info 'update-grub'
        update-grub

    elif [[ -x "$(command -v grub-mkconfig)" ]]; then
        echo_info 'grub-mkconfig -o /boot/grub/grub.cfg'
        grub-mkconfig -o /boot/grub/grub.cfg

    elif [[ -x "$(command -v grub2-mkconfig)" ]]; then
        if [[ -x "$(command -v zypper)" ]]; then
            echo_info 'grub2-mkconfig -o /boot/grub2/grub.cfg'
            grub2-mkconfig -o /boot/grub2/grub.cfg

        elif [[ -x "$(command -v dnf)" ]]; then
            echo_info 'grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg'
            grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
        fi
    fi
}

function main() {
    splash 'The Matrix awaits you...'

    check_root
    select_theme

    install_theme

    config_grub
    update_grub

    echo_success 'Boot Theme Update Successful!'
}

main
EOF
sudo chmod a+x install.grub.sh
sudo bash install.grub.sh
}
#}}} <#1953


#{{{>>>   install_custom_grub >#1956
install_custom_grub() {
	clear

if [[ ! -d /home/batan/themes ]]; then
	mkdir /home/batan/themes
fi
git clone https://github.com/batann/Vimix /home/batan/themes/

install.grub.sh<<EOF>cat
#!/bin/bash

#THEME_DIR='/usr/share/grub/themes'
THEME_DIR='/boot/grub/themes'
THEME_NAME=''

function echo_title() {     echo -ne "\033[1;44;37m${*}\033[0m\n"; }
function echo_caption() {   echo -ne "\033[0;1;44m${*}\033[0m\n"; }
function echo_bold() {      echo -ne "\033[0;1;34m${*}\033[0m\n"; }
function echo_danger() {    echo -ne "\033[0;31m${*}\033[0m\n"; }
function echo_success() {   echo -ne "\033[0;32m${*}\033[0m\n"; }
function echo_warning() {   echo -ne "\033[0;33m${*}\033[0m\n"; }
function echo_secondary() { echo -ne "\033[0;34m${*}\033[0m\n"; }
function echo_info() {      echo -ne "\033[0;35m${*}\033[0m\n"; }
function echo_primary() {   echo -ne "\033[0;36m${*}\033[0m\n"; }
function echo_error() {     echo -ne "\033[0;1;31merror:\033[0;31m\t${*}\033[0m\n"; }
function echo_label() {     echo -ne "\033[0;1;32m${*}:\033[0m\t"; }
function echo_prompt() {    echo -ne "\033[0;36m${*}\033[0m "; }

function splash() {
    local hr
    hr=" **$(printf "%${#1}s" | tr ' ' '*')** "
    echo_title "${hr}"
    echo_title " * $1 * "
    echo_title "${hr}"
    echo
}

function check_root() {
    # Checking for root access and proceed if it is present
    ROOT_UID=0
    if [[ ! "${UID}" -eq "${ROOT_UID}" ]]; then
        # Error message
        echo_error 'Run me as root.'
        echo_info 'try sudo ./install.sh'
        exit 1
    fi
}

function select_theme() {
    themes=( 'Vimix' )

    echo '\nChoose The Theme You Want: '
                splash 'Installing Vimix Theme...'
}

function backup() {
    # Backup grub config
    echo_info 'cp -an /etc/default/grub /etc/default/grub.bak'
    cp -an /etc/default/grub /etc/default/grub.bak
}

function install_theme() {
    # create themes directory if not exists
    if [[ ! -d "${THEME_DIR}/${THEME_NAME}" ]]; then
        # Copy theme
        echo_primary "Installing ${THEME_NAME} theme..."

        echo_info "mkdir -p \"${THEME_DIR}/${THEME_NAME}\""
        mkdir -p "${THEME_DIR}/${THEME_NAME}"

        echo_info "cp -a ./themes/\"${THEME_NAME}\"/* \"${THEME_DIR}/${THEME_NAME}\""
        cp -a ./themes/"${THEME_NAME}"/* "${THEME_DIR}/${THEME_NAME}"
    fi
}

function config_grub() {
    echo_primary 'Enabling grub menu'
    # remove default grub style if any
    echo_info "sed -i '/GRUB_TIMEOUT_STYLE=/d' /etc/default/grub"
    sed -i '/GRUB_TIMEOUT_STYLE=/d' /etc/default/grub

    echo_info "echo 'GRUB_TIMEOUT_STYLE=\"menu\"' >> /etc/default/grub"
    echo 'GRUB_TIMEOUT_STYLE="menu"' >> /etc/default/grub

    #--------------------------------------------------

    echo_primary 'Setting grub timeout to 60 seconds'
    # remove default timeout if any
    echo_info "sed -i '/GRUB_TIMEOUT=/d' /etc/default/grub"
    sed -i '/GRUB_TIMEOUT=/d' /etc/default/grub

    echo_info "echo 'GRUB_TIMEOUT=\"60\"' >> /etc/default/grub"
    echo 'GRUB_TIMEOUT="60"' >> /etc/default/grub

    #--------------------------------------------------

    echo_primary "Setting ${THEME_NAME} as default"
    # remove theme if any
    echo_info "sed -i '/GRUB_THEME=/d' /etc/default/grub"
    sed -i '/GRUB_THEME=/d' /etc/default/grub

    echo_info "echo \"GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"\" >> /etc/default/grub"
    echo "GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"" >> /etc/default/grub

    #--------------------------------------------------

    echo_primary 'Setting grub graphics mode to auto'
    # remove default timeout if any
    echo_info "sed -i '/GRUB_GFXMODE=/d' /etc/default/grub"
    sed -i '/GRUB_GFXMODE=/d' /etc/default/grub

    echo_info "echo 'GRUB_GFXMODE=\"auto\"' >> /etc/default/grub"
    echo 'GRUB_GFXMODE="auto"' >> /etc/default/grub
}

function update_grub() {
    # Update grub config
    echo_primary 'Updating grub config...'
    if [[ -x "$(command -v update-grub)" ]]; then
        echo_info 'update-grub'
        update-grub

    elif [[ -x "$(command -v grub-mkconfig)" ]]; then
        echo_info 'grub-mkconfig -o /boot/grub/grub.cfg'
        grub-mkconfig -o /boot/grub/grub.cfg

    elif [[ -x "$(command -v grub2-mkconfig)" ]]; then
        if [[ -x "$(command -v zypper)" ]]; then
            echo_info 'grub2-mkconfig -o /boot/grub2/grub.cfg'
            grub2-mkconfig -o /boot/grub2/grub.cfg

        elif [[ -x "$(command -v dnf)" ]]; then
            echo_info 'grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg'
            grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
        fi
    fi
}

function main() {
    splash 'The Matrix awaits you...'

    check_root
    select_theme

    install_theme

    config_grub
    update_grub

    echo_success 'Boot Theme Update Successful!'
}

main
EOF


chmod +x /home/batan/install.grub.sh
sudo /home/batan/./install.grub.sh
}
#}}} <#2116
#{{{>>>   install_custom_plymouth >#2117
install_custom_plymouth() {
	DEPS="plymouth plymouth-x11 trash-cli git"
	for packs in ${DEPS[@]}; do
	dpkg -s ${packs} &> /dev/null 2>&1
	if [ $? != 1 ]; then
		sudo apt install ${packs} -y
	fi
done
clear
	echo -e "\033[1;32mInstalling Custom LC-Plymouth Theme\033[0m"
git clone https://github.com/batann/lc-plymouth

if [[ ! -d "/usr/share/plymouth/themes" ]]; then
	sudo mkdir -p /usr/share/plymouth/themes/anon
	sudo cp /home/batan/lc-plymouth/* /usr/share/plymouth/themes/anon
else
	sudo mv /usr/share/plymouth/themes/anon /usr/share/plymouth/themes/anon.bak
	sudo mkdir -p /usr/share/plymouth/themes/anon
	sudo cp /home/batan/lc-plymouth/* /usr/share/plymouth/themes/anon
fi

cd /usr/share/plymouth/themes
sudo plymouth-set-default-theme anon
sudo update-initramfs -u
sudo update-grub
cd /home/batan
}
#}}} <#2145



