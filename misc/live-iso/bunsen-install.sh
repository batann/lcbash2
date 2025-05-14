#!/bin/bash
# This is intended to be a general-purpose script to install
# a desktop environment, possibly BunsenLabs,
# on a Debian netinstall base. (See README.md for more details.)
# It will modify and add some system files, install the necessary
# packages and copy configuration files into your home directory.
# These changes might be reversible, but no guarantees are offered,
# and all the usual caveats apply.
# This install script is intended to be run on a newly installed
# system with no personal settings or data. Attempts will be made to
# backup any such data that might exist, but do not rely on it.

# USAGE
# This script should come in a folder called bunsen-?-netinstall,
# along with a collection of other necessary files.
# Change directory (cd) into that folder and run this script:
# ./install
# to start the installation process.
# A folder bunsen-netinstall-logs will be added to your home folder,
# to a location set in the "config" file (probably ~/.cache).
# This may safely be removed if the installation was successful.
# A folder /backup (or other name) on your root file system will hold
# backups of system files replaced during the install.

################################################

set -o nounset # do not accept unset variables
# If not running in terminal, exit with message
[[ -t 0 && -t 1 && -t 2 ]] || { echo "$0: This script must be run from a terminal" >&2; exit 1; }

# If running in a TTY, disable screen blanking
[[ "$TERM" = "linux" ]] && setterm -blank 0

[[ -r config ]] || { echo "$0: Cannot find necessary file \"config\"" >&2; exit 1; }
. config
for i in log_dir backup_dir backup_suffix necessary_files replaced_dirs
do
    [[ -n $i ]] || { echo "$0: Config variable $i has not been set. Please check the \"config\" file." >&2; exit 1; }
done
install_backup_dir="${backup_dir}"/install
snapshots_dir="${backup_dir}"/snapshots
backup_dir="$install_backup_dir"

logfile=error.log # temporary logfile in installer directory
exec > >( tee -a "$logfile" ) 2>&1

user=$USER

# Debian release that this BunsenLabs system will be based on (lowercase)
debian_base=bookworm

# in case script is run after installing bunsen-os-release (lowercase too)
bunsen_codename=boron

msg() {
    echo "
    $1
"
}

bigmsg() {
    tput bold
    echo "
    $1
------------------------------------------------"
    tput sgr0
    sleep 3
}

errmsg() {
    tput bold
    echo "######## ERROR ########
    $1
------------------------------------------------"
    tput sgr0
    sleep 4
}

log() {
    echo "
$1
" >> "$logfile"
}

warnlog() {
    echo "######## WARNING ########
$1
------------------------------------------------" >> "$logfile"
}

confirm() { # $1 is message, $2 is desired return value: 0 or 1 (passed to 'giveup')
    echo "
$1
(press enter to continue, any other key to exit)
"
    read -srn1
    [[ -n $REPLY ]] && giveup "terminated by $user, goodbye!" "$2"
    log "$user chose to continue"
}

option() {
    echo "
$1
(press enter to agree, any other key to pass)
"
    read -srn1
    [[ $REPLY ]] && { log "$user did not agree"; return 1; }
    log "$user agreed"
    return 0
}

giveup() { # $1 is message, $2 is desired return value: 0 or 1
    if [[ ${2:-1} = 0 ]]
    then
        bigmsg "$1"
    else
        errmsg "$1"
    fi
    [[ ${replaced_dirs[0]} != "none" ]] && {
        for i in "${replaced_dirs[@]}"
        do
            sudo test -d "$i" || { # if dir has not been replaced by new version, put back the original backup
                if sudo test -d  "${i%/*}"
                then
                    sudo test -d "${backup_dir}/$i" && sudo mv "${backup_dir}/$i" "${i%/*}"  || errmsg "Unable to restore missing folder $i ."
                else
                    errmsg "Cannot move $i to ${i%/*} : no such directory."
                fi
            }
        done
    }
    echo "now exiting..."
    exit ${2:-1}
}

net_test() {
    tries=4
    printf 'checking network connection... '
    while [[ $tries -gt 0 ]]
    do
        wget -O - 'http://ftp.debian.org/debian/README' >/dev/null 2>&1 && {
            msg '[OK]'
            return 0
        }
        ((tries--))
        sleep 1
    done
    msg '[FAILED]'
    return 1
}

# pass Debian or BunsenLabs
check_repo() {
    local repo_name="$1"
    msg "checking $repo_name repository is online..."
    case "$repo_name" in
    Debian)
        local repo_url='https://deb.debian.org/debian'
        local dist="$debian_base"
        ;;
    BunsenLabs)
        local repo_url='https://pkg.bunsenlabs.org/debian'
        local dist="$bunsen_codename"
        ;;
    *)
        giveup "Sorry, I don't understand the repository name $repo_name" 1
        ;;
    esac
#    if curl --output /dev/null --silent --head --fail "${repo_url}/dists/${dist}/InRelease"; then
    if wget --spider --quiet "${repo_url}/dists/${dist}/InRelease"; then
        msg "OK"
        return 0
    else
        errmsg "$repo_name repository seems to be offline"
        return 1
    fi
}

usingDebStable() {
    local reported_codename=$( lsb_release -cs )
    case ${reported_codename,,} in
    "$debian_base"|"$bunsen_codename") return 0 ;;
    esac
    warnlog "'lsb_release -cs' reported wrong codename: $reported_codename"
    return 1
}

trap 'giveup "Script terminated." 1' 1 2 3 15
[[ $user = root ]] && giveup "This script should be run by a normal user, not root" 1

log "
########################################################################
Starting netinstall script for $user at $(date)"

clear
tput bold
echo "Hi $user, welcome to the netinstall script!"
tput sgr0
echo "
$( < greeting )

This script is expected to be run just after completing a netinstall
installation of the Debian Bookworm CORE SYSTEM ONLY.
(See \"Debian Netinstall Hints\" in the README.md file.)
"
confirm "Would you like to start the install now?" 0

net_test || giveup "You do not seem to have a working network connection.
Please fix this issue and run the script again." 1

# make sure repos are online
for i in Debian BunsenLabs
do
    check_repo "$i" || giveup "Unable to continue without working $i repository" 1
done

# check for needed files
missing_files=
for i in "${necessary_files[@]}"
do
    [[ -r $i ]] || missing_files+=" $i"
done
[[ $missing_files ]] && giveup "Some necessary files or folders were missing: $missing_files" 1 || msg "Necessary files: OK"

# setup logfile
[[ -d "$log_dir" ]] || {
    mkdir -p "$log_dir" || giveup "failed to create $log_dir in $HOME" 1
    cp bunsen-netinstall-logs-templates/* "$log_dir" || giveup "failed to copy logfiles directory contents into $log_dir" 1
}
cat "$logfile" >> "$log_dir"/install.log
rm "$logfile" # finished with temporary logfile
logfile="$log_dir"/install.log # this logfile will remain after the install
exec > >( tee -a "$logfile" ) 2>&1
bigmsg "Messages are being saved to $logfile"
cp -f pkgs-recs pkgs-recs-lite pkgs-norecs pkgs-norecs-lite config "$log_dir"

usingDebStable && msg "Debian version: OK" || {
    confirm "You do not appear to have Debian $debian_base
or BunsenLabs $bunsen_codename installed.
If you think this is incorrect,
you may wish to continue with the installation,
otherwise it would be safer to stop.
Would you like to continue anyway?" 1; }

# is X already installed? FIXME Is this the best way to check if there is a desktop system installed already?
hash startx > /dev/null 2>&1 && { warnlog "Command 'startx' is available. Desktop system already installed?"
    confirm "You seem to have some kind of desktop environment already installed.
If you continue with this installation you may have problems,
or even end up with an unusable system.
Would you like to continue anyway?" 1; }

# can use sudo?
echo "
You will need your password to perform certain system tasks.
Please enter it now and it will be stored for a while.
(You may need to enter it again later.)"
sudo -v || giveup "You do not appear to have permission to use sudo,
which is needed in this script.
Please make the necessary adjustments to your system and try again." 1

pkgs_norecs_file=
pkgs_recs_file=

bigmsg "You can choose to install the \"full\" package list, which is the same as
what is installed by the usual iso file, or the \"lite\" list,
which is slightly smaller and more suitable for older machines.
There is also a \"base\" list which installs only the minimum packages needed
for a BunsenLabs desktop, with many common utilities omitted."

PS3='Please enter the number of your choice > '

select list in 'full' 'lite' 'base'
do
    case "$list" in
    full)
        log "$user chose the full install"
        pkgs_norecs_file=pkgs-norecs
        pkgs_recs_file=pkgs-recs
        break
        ;;
    lite)
        log "$user chose the lite install"
        pkgs_norecs_file=pkgs-norecs-lite
        pkgs_recs_file=pkgs-recs-lite
        break
        ;;
    base)
        log "$user chose the base install"
        pkgs_norecs_file=pkgs-norecs-base
        pkgs_recs_file=pkgs-recs-base
        break
        ;;
    esac
done

for i in "$pkgs_norecs_file" "$pkgs_recs_file"
do
    [[ -r $i ]] || giveup "Cannot read package list $i" 1
done

# initial tweaking
bigmsg "Adjusting some system settings."
[[ -r preinstall_commands ]] && {
    . preinstall_commands
}

bigmsg "Upgrading system before install
(this may take a little while)"
bigmsg "Please press 'y' if prompted at some point."

msg "Updating database..."
sudo apt-get --quiet update  || giveup "There was a problem with 'apt-get update'.
There may be some information in ${logfile}." 1

msg "Upgrading packages..."
sudo apt-get --quiet dist-upgrade  || giveup "There was a problem with 'apt-get dist-upgrade'.
There may be some information in ${logfile}." 1

#msg "Removing unnecessary packages..."
#sudo apt-get --quiet autoremove  || giveup "There was a problem with 'apt-get autoremove'.
#There may be some information in ${logfile}." 1

log "Packages originally installed by the Debian netinstaller are recorded in $log_dir/netinstall-core-apps"
[[ -f "$log_dir"/netinstall-core-apps ]] || apt-mark showmanual > "$log_dir"/netinstall-core-apps
log "Packages originally auto-installed by the Debian netinstaller are recorded in $log_dir/netinstall-auto-apps"
[[ -f "$log_dir"/netinstall-auto-apps ]] || apt-mark showauto > "$log_dir"/netinstall-auto-apps

# FIXME put this in a config file?
msg "Installing rsync and apt-transport-https."
sudo apt-get --quiet install rsync apt-transport-https || giveup "Failed to install necessary package 'rsync' or 'apt-transport-https'." 1

[[ ${snapshots[0]} != "none" ]] && {
    bigmsg "Making snapshots of some files or directories"
    for i in "${snapshots[@]}"
    do
        [[ $i ]] || continue # blank line
        i="${i%/}" # remove any trailing slash
        sudo test -e "$i" || { errmsg "$i set in \"snapshots\" in file \"config\" does not exist"; continue;}
        sudo test -e "${snapshots_dir}${i}" && { msg "snapshot of $i already made"; continue;}
        msg "making snapshot of $i in ${snapshots_dir}"
        sudo mkdir -p "${snapshots_dir}${i%/*}"  || errmsg "Failed to make directory ${snapshots_dir}${i%/*}"
        sudo cp -a "$i" "${snapshots_dir}${i%/*}"  || errmsg "Failed to copy $i to ${snapshots_dir}${i%/*}."
    done
}

############ file copying functions ############
# rsync would do almost the same, but this allows us to keep records and be picky about corner cases.

are_identical() { # two files have same content and same permissions
    sudo cmp -s "$1" "$2" && [[ $(sudo stat -c %a "$1") = $(sudo stat -c %a "$2") ]] && return 0
    return 1
}

install_sysdir() { # recursively copy contents of $1 into $2, make backups in $3 of replaced files and keep records of changes
    [[ $# = 3 ]] || giveup "install_sysdir() needs three arguments" 1
    # use 'sudo test' in case file is only accessible to root
    sudo test -d "$1" || giveup "$1 is not an existing directory" 1
    sudo test -d "$2" || giveup "$2 is not an existing directory" 1
    sudo mkdir -p "$3"  || giveup "Unable to make directory $3." 1
    for i in "$1"/*
    do
        sudo test -e "$i" || break # $1 is empty
        [[ $i = *$'\n'* ]] && giveup "Line-break in filename: $i
Please contact the software provider, or remove this file
before running the script again." 1
        [[ $i = *~ ]] && { msg "ignoring backup file $i"; continue; }
        filename="${i##*/}"
        target="${2%/}/${filename}" # avoid double slash if $2 is /
        if sudo test -d "$i"
        then
            if sudo test -e "${target}"
            then
                sudo test -d "${target}" || giveup "${target} exists, but is not a directory." 1
                sudo rsync --dirs --perms "${target}" "$3"  || giveup "There was a problem copying ${target} to $3/${filename}." 1
            else
                msg "adding directory ${target}"
                sudo rsync --dirs --perms "$i" "$2"  || giveup "There was a problem copying $i to $2." 1
                echo "${target}" >> "$log_dir"/sysdirs-added
            fi
            install_sysdir "$i" "${target}" "$3/${filename}"
        else
            if sudo test -e "${target}"
            then
                if are_identical "$i" "${target}"
                then # probably this file was added on a previous run of script
                    msg "$i and ${target} are identical"
                else
                    msg "replacing ${target}"
                    if sudo test -e "$3/${filename}"
                    then
                        msg "A backup copy of ${target} already exists..." # do our best to keep meaningful backups
                        if are_identical "${target}" "$3/${filename}"
                        then
                            msg "but is identical with ${target}"
                        else
                            msg "but an extra backup will be made at $3/${filename}${backup_suffix}"
                            sudo mv "${target}" "$3/${filename}${backup_suffix}"  || giveup "There was a problem moving ${target} to $3/${filename}." 1
                        fi
                    else
                        sudo mv "${target}" "$3/${filename}"  || giveup "There was a problem moving ${target} to $3/${filename}." 1
                    fi
                    sudo cp --preserve=mode "$i" "$2"  || giveup "There was a problem copying $i to $2." 1
                    echo "${target}" >> "$log_dir"/sysfiles-replaced
                fi
            else
                msg "adding ${target}"
                sudo cp --preserve=mode "$i" "$2"  || giveup "There was a problem copying $i to $2." 1
                echo "${target}" >> "$log_dir"/sysfiles-added
            fi
        fi
    done
}

# This function is no longer needed. User files are installed by bl-user-setup (shipped with bunsen-configs) on first login.
# If you adapt this netinstall script for other systems you might want to use it.
install_userdir() { # recursively copy contents of $1 into $2, make backups of replaced files in $2 and keep records of changes
    [[ $# = 2 ]] || giveup "install_userdir() needs two arguments" 1
    [[ -d $1 ]] || giveup "$1 is not an existing directory." 1
    [[ -d $2 ]] || giveup "$2 is not an existing directory." 1
    for i in "$1"/*
    do
        [[ -e $i ]] || break # $1 is empty
        [[ $i = *$'\n'* ]] && giveup "Line-break in filename: $i
Please contact the software provider, or remove this file
before running the script again." 1
        filename="${i##*/}"
        if [[ -d $i ]]
        then
            if [[ -e "$2/${filename}" ]]
            then
                [[ -d "$2/${filename}" ]] || giveup "$2/${filename} exists, but is not a directory." 1
            else
                msg "adding directory $2/${filename}"
                rsync --dirs --perms "$i" "$2"  || giveup "There was a problem copying $i to $2." 1
                echo "$2/${filename}" >> "$log_dir"/userdirs-added
            fi
            install_userdir "$i" "$2/${filename}"
        else
            if [[ -e "$2/${filename}" ]]; then
                if are_identical "$i" "$2/${filename}"; then # probably this file was added on a previous run of script
                    msg "$i and $2/${filename} are identical"
                else
                    msg "replacing $2/${filename}"
                    # keep original backup, but try not to fill user's home with meaningless backup files
                    mv --no-clobber "$2/${filename}" "$2/${filename}${backup_suffix}"  || giveup "There was a problem renaming $2/${filename} to $2/${filename}${backup_suffix}." 1
                    cp --preserve=mode "$i" "$2"  || giveup "There was a problem copying $i to $2." 1
                    echo "$2/${filename}" >> "$log_dir"/userfiles-replaced
                fi
            else
                msg "adding $2/${filename}"
                cp --preserve=mode "$i" "$2"  || giveup "There was a problem copying $i to $2." 1
                echo "$2/${filename}" >> "$log_dir"/userfiles-added
            fi
        fi
    done
}

########## end file copying functions ##########

bigmsg "Adjusting package management (apt) settings."

# gen_sources aims to preserve whatever mirrors user has configured
# while adding 'contrib', 'non-free-firmware' and 'non-free'

if [[ -r gen_sources ]]; then
    if [[ -s  sysfiles1/etc/apt/sources.list ]]; then
        msg "sysfiles1/etc/apt/sources.list already generated"
    else
        msg "generating new sources.list"
        . gen_sources # commands to generate sysfiles1/etc/apt/sources.list
    fi
fi

[[ -s sysfiles1/etc/apt/sources.list ]] || giveup "There is no sources.list file." 1

msg "installing apt configuration files"

install_sysdir sysfiles1 / "${backup_dir}"
bigmsg "Apt settings adjusted."

# Install any necessary APT keys.
[[ -r apt-keys ]] && {
    . apt-keys
}

bigmsg "Installing packages needed for the system.
This may take some time."
#bigmsg "Please press 'y' if prompted at some point."

msg "updating apt database..."
sudo apt-get --quiet update  || {
    warnlog "'apt-get --quiet update' returned an error"
    confirm "There was a problem with 'apt-get update'.
There may be some information in ${logfile}.
Would you like to continue anyway, or exit?" 1
}

msg "upgrading existing packages..."
sudo apt-get --quiet dist-upgrade  || {
    warnlog "'apt-get --quiet dist-upgrade' returned an error"
    confirm "There was a problem with 'apt-get dist-upgrade'.
There may be some information in ${logfile}.
Would you like to continue anyway, or exit?" 1
}

bigmsg "Installing new packages.
There may be around 1000 packages to install,
 so this will probably take a while..."

# recommends settings here will override whatever is set in apt.conf.d

norecs=($( sed 's/\#.*$//' "$pkgs_norecs_file" )) && [[ ${#norecs[@]} -gt 0 ]] && {
    bigmsg "Installing packages, without recommends."
    sudo apt-get --no-install-recommends --quiet install "${norecs[@]}"  || {
        warnlog "'apt-get --no-install-recommends --quiet install' returned an error"
        confirm "There was a problem installing some packages.
    There may be some information in ${logfile}.
    You might want to exit the script, comment out packages causing problems
    in ${pkgs_norecs_file}, and run the script again.
    If the missing packages are unimportant, you might prefer to continue
    with the install and fix the issues later.
    Would you like to ignore the errors and continue now,
    or exit and try to fix the problems?" 1
    }
}

recs=($( sed 's/\#.*$//' "$pkgs_recs_file" )) && [[ ${#recs[@]} -gt 0 ]] && {
    bigmsg "Installing packages, with recommends."
    sudo apt-get -o APT::Install-Recommends=true --quiet install "${recs[@]}"  || {
    warnlog "'apt-get -o APT::Install-Recommends=true --quiet install' returned an error"
    confirm "There was a problem installing some packages.
There may be some information in ${logfile}.
You might want to exit the script, comment out packages causing problems
in ${pkgs_recs_file}, and run the script again.
If the missing packages are unimportant, you might prefer to continue
with the install and fix the issues later.
Would you like to ignore the errors and continue now,
or exit and try to fix the problems?" 1
    }
}

bigmsg "New packages installed"

# get stuff from GitHub, make local repo, install from there
#bigmsg "Importing packages from GitHub"
#[[ -r github_install ]] && {
#    . github_install
#}


bigmsg "Copying in new system files.
Replaced files will be backed up to ${backup_dir}"

# move dirs that will be replaced to backup dir
[[ ${replaced_dirs[0]} != "none" ]] && {
    for i in "${replaced_dirs[@]}"
    do
        sudo test -d "$i" || { errmsg "directory $i set in \"replaced_dirs\" in file \"config\" does not exist"; continue; }
        if sudo test -d "${backup_dir}/$i"
        then
            msg "${backup_dir}/$i already exists.
No need to backup $i"
        else
            bigmsg "$i will be replaced: moving it to ${backup_dir}" # we want to completely replace the directory
            sudo mkdir -p "${backup_dir}/${i%/*}"  || giveup "Unable to make directory ${backup_dir}/${i%/*}." 1
            sudo mv "$i" "${backup_dir}/${i%/*}"  || giveup "Unable to move $i to ${backup_dir}/${i%/*}" 1
        fi
    done
}

shopt -s dotglob # want dotfiles too
install_sysdir sysfiles2 / "${backup_dir}"
shopt -u dotglob

# TODO find a more elegant way of handling this:
# hack to cope with /etc/network/interfaces being undesirably nuked when network-manager is not installed
[[ $(dpkg-query --show --showformat='${db:Status-Abbrev}' 'network-manager' 2>/dev/null) =~ ^(i|h)i' '$ ]] || {
    msg "Restoring overwritten /etc/network/interfaces
from backup at ${backup_dir}/etc/network/interfaces
because network-manager is not installed."
    [[ -r "${backup_dir}/etc/network/interfaces" ]] || {
        errmsg "Cannot restore /etc/network/interfaces from backup.
You may need to edit this file manually to get a working network."
    }
    sudo cp "${backup_dir}/etc/network/interfaces" /etc/network/interfaces
}

bigmsg "system files installed"

#bigmsg "Updating your personal configuration files.
#Replaced files wil be backed up with a suffix of $backup_suffix"

#shopt -s dotglob # want dotfiles too
#install_userdir /etc/skel $HOME
#shopt -u dotglob

#bigmsg "Files updated."

# final tweaking
bigmsg "Adjusting some system settings."
[[ -r postinstall_commands ]] && {
    . postinstall_commands
}

bigmsg "INSTALL FINISHED!"
confirm "You need to restart your computer to log into your new system.
Would you like to continue to restart now,
or exit the script and restart later?" 0
bigmsg "REBOOTING...
(thank you for your patience so far)"
sudo shutdown -r now
exit

