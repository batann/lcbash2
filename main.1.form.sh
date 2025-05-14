#!/bin/bash
# Script Nu.a Display Form for interactive-mode
B='\033[0;30m'
Re='\033[0;31m'
Gr='\033[0;32m'
Bl='\033[0;34m'
Pu='\033[0;35m'
Cy='\033[0;36m'
Ye='\033[1;33m'
Wh='\033[1;37m'
N='\033[0m'
#   ANSI CODE BACKGROUND  ##################################################################
BBlue='\e[0;104m'
BBlack='\e[0;100m'
RRed='\e[0;100m'
GGreen='\e[0;100m'
YYellow='\e[0;100m'
BBlue='\e[0;100m'
PPurple='\e[0;100m'
CCyan='\e[0;100m'
WWhite='\e[0;100m'
clear
tput civis
tput cup 0 0
echo -e "\033[40m\033[32m=================================================================\033[m"
tput cup 1 0
echo -e "${Cy}To set up gpg encyption please provide${N}"
tput cup 2 4
echo -e "${Pu}full_name           ${Re}:${N}"
tput cup 3 4
echo -e "${Pu}email_address       ${Re}:${N}"
tput cup 4 4
echo -e "${Pu}passphrase          ${Re}:${N}"
tput cup 5 4
echo -e "${Pu}app_passphrase      ${Re}:${N}"
echo -e "\033[40m\033[32m---------------------------------------------------------------\033[m"

tput cup 7 0
echo -e "${Cy}To set up samba0shares please provide${N}"
tput cup 8 4
echo -e "${Pu}passphrase          ${Re}:${N}"
tput cup 9 4
echo -e "${Pu}samba user          ${Re}:${N}"
tput cup 10 4
echo -e "${Pu}permissions RW      ${Re}:${N}"
echo -e "\033[40m\033[32m---------------------------------------------------------------\033[m"
tput cup 12 0
echo -e "${Cy}To decrypt default credentials provide${N}"
tput cup 13 4
echo -e "${Pu}passphrase          ${Re}:${N}"
tput cup 14 0
echo -e "\033[40m\033[32m---------------------------------------------------------------\033[m"
tput cup 15 0
echo -e "${Cy}To set up mashpodder provide${N}"
tput cup 16 4
echo -e "${Pu}base directory      ${Re}:${N}"
tput cup 17 0
echo -e "\033[40m\033[32m===============================================================\033[m"











tput cup 18 0
echo -e "${Cy}To set up minidlna please provide ${N}"
tput cup 19 4
echo -e "${Pu}base dir for media ${Re}:${N}"
tput cup 20 9
echo -e "${Bl}Video         ${Re}:${N}"
tput cup 21 9
echo -e "${Bl}Audio         ${Re}:${N}"
tput cup 22 9
echo -e "${Bl}Images        ${Re}:${N}"
tput cup 23 9
echo -e "${Bl}Documents     ${Re}:${N}"
tput cup 24 0
echo -e "\033[40m\033[32m===============================================================\033[m"
tput cup 25 0
echo -e "${Cy} Mark following pakages with yes or no${N}"
tput cup 26 0
echo -e "${Re}>>> ${Wh}1${Pu}) ${Wh}Yes"
tput cup 27 0
echo -e "${Re}>>> ${Wh}2${Pu}) ${Wh}No "
echo -e "\033[40m\033[32m---------------------------------------------------------------\033[m"
tput cup 29 4
echo -e "${Pu}Lamp Server       ${Re}:${N}"
tput cup 30 4
echo -e "${Pu}Custm Fonts       ${Re}:${N}"
tput cup 31 4
echo -e "${Pu}Backgrounds       ${Re}:${N}"
tput cup 32 4
echo -e "${Pu}Lamp Server       ${Re}:${N}"
tput cup 33 4
echo -e "${Pu}Lamp Server       ${Re}:${N}"
tput cup 34 4
echo -e "${Pu}Lamp Server       ${Re}:${N}"
tput cup 35 4
echo -e "${Pu}Lamp Server       ${Re}:${N}"
tput cup 36 4
echo -e "${Pu}Lamp Server       ${Re}:${N}"
tput cup 37 4
echo -e "${Pu}Lamp Server       ${Re}:${N}"
tput cup 38 4
echo -e "${Pu}Lamp Server       ${Re}:${N}"
tput cup 39 4
echo -e "${Pu}Lamp Server       ${Re}:${N}"
tput cup 40 0
echo -e "\033[40m\033[32m==============================================================\033[m"
tput cup 43 0








tput cup 45 3
echo -e "$Bl==================================="
tput cup 46 3
echo -e "=== ${Wh}  Enter${Cy} [${Gr}ANY${Cy}]${Wh} to continuue  $Bl==="
tput cup 47 3
echo -e "==================================="


read -n1 lol
tput cup 45 0
tput el
tput cup 46 0
tput el
tput cup 47 0
tput el

tput cup 2 29
echo -e "${Re}>>>${Gr}"
tput cup 2 34
read -e -i "fairdinkum batan" full_name


tput cup 3 29
echo -e "${Re}>>>${Gr}"
tput cup 3 34
read -e -i "" email_address

tput cup 4 29
echo -e "${Re}>>>${Gr}"
tput cup 4 34
read -e -i "Ba7an" passphrase

tput cup 5 29
echo -e "${Re}>>>${Gr}"
tput cup 5 34
read -e -i "ixeh bhbn dbrq pbyc" app_passphrase

tput cup 8 29
echo -e "${Re}>>>${Gr}"
tput cup 8 34
read -e -i "" SAMBA_PASSWORD

tput cup 9 29
echo -e "${Re}>>>${Gr}"
tput cup 9 34
read -e -i "" SAMBA_USER

tput cup 10 29
echo -e "${Re}>>>${Gr}"
tput cup 10 34
read -e -i "rw" SAMBA_PERMISSIONS

tput cup 13 29
echo -e "${Re}>>>${Gr}"
tput cup 13 34
read -e -i "" GPG_passphrase

tput cup 16 29
echo -e "${Re}>>>${Gr}"
tput cup 16 34
read -e -i "/home/batan/.config/mashpodder" BASE_DIR_MASHPODDER















tput cup 39 29
echo -e "${Re}>>>${Gr}"
tput cup 39 34
read -e -i "" BASE_DIR_MINIDLNA

tput cup 20 29
echo -e "${Re}>>>${Wh}"
tput cup 20 34
read -e -i "$BASE_DIR_MINIDLNA" VIDEO

tput cup 21 29
echo -e "${Re}>>>${Wh}"
tput cup 21 34
read -e -i "$BASE_DIR_MINIDLNA" AUDIO

tput cup 22 29
echo -e "${Re}>>>${Wh}"
tput cup 22 34
read -e -i "$BASE_DIR_MINIDLNA" IMAGES

tput cup 23 29
echo -e "${Re}>>>${Wh}"
tput cup 23 34
read -e -i "$BASE_DIR_MINIDLNA" Documents




tput cup 29 29
echo -e "${Re}>>>${Gr}"
tput cup 29 34
read -n1  aa1
if [[ "$aa1" == "1" ]]; then
	tput cup 39 34
	echo -e "${Wh}Yes"
else
	tput cup 39 34
	echo -e "${Wh}No"
fi


tput cup 30 29
echo -e "${Re}>>>${Gr}"
tput cup 30 34
read -n1 aa2
if [[ "$aa2" == "1" ]]; then
	tput cup 30 34
	echo -e "${Wh}Yes"
else
	tput cup 30 34
	echo -e "${Wh}No"
fi

tput cup 31 29
echo -e "${Re}>>>${Gr}"
tput cup 31 34
read -n1 aa3
if [[ "$aa3" == "1" ]]; then
	tput cup 31 34
	echo -e "${Wh}Yes"
else
	tput cup 31 34
	echo -e "${Wh}No"
fi

tput cup 32 29
echo -e "${Re}>>>${Gr}"
tput cup 32 34
read -n1  aa4
if [[ "$aa4" == "1" ]]; then
	tput cup 32 34
	echo -e "${Wh}Yes"
else
	tput cup 32 34
	echo -e "${Wh}No"
fi

tput cup 33 29
echo -e "${Re}>>>${Gr}"
tput cup 33 34
read -n1  aa5
if [[ "$aa5" == "1" ]]; then
	tput cup 33 34
	echo -e "${Wh}Yes"
else
	tput cup 33 34
	echo -e "${Wh}No"
fi

tput cup 34 29
echo -e "${Re}>>>${Gr}"
tput cup 34 34
read -n1  aa6
if [[ "$aa6" == "1" ]]; then
	tput cup 34 34
	echo -e "${Wh}Yes"
else
	tput cup 34 34
	echo -e "${Wh}No"
fi

tput cup 35 29
echo -e "${Re}>>>${Gr}"
tput cup 35 34
read -n1  aa7
if [[ "$aa7" == "1" ]]; then
	tput cup 35 34
	echo -e "${Wh}Yes"
else
	tput cup 45 34
	echo -e "${Wh}No"
fi

tput cup 36 29
echo -e "${Re}>>>${Gr}"
tput cup 36 34
read -n1  aa8
if [[ "$aa8" == "1" ]]; then
	tput cup 36 34
	echo -e "${Wh}Yes"
else
	tput cup 36 34
	echo -e "${Wh}No"
fi

tput cup 37 29
echo -e "${Re}>>>${Gr}"
tput cup 37 34
read -n1  aa9
if [[ "$aa9" == "1" ]]; then
	tput cup 37 34
	echo -e "${Wh}Yes"
else
	tput cup 37 34
	echo -e "${Wh}No"
fi

tput cup 38 29
echo -e "${Re}>>>${Gr}"
tput cup 38 34
read -n1  aa10
if [[ "$aa10" == "1" ]]; then
	tput cup 38 34
	echo -e "${Wh}Yes"
else
	tput cup 38 34
	echo -e "${Wh}No"
fi
tput cup 39 29
echo -e "${Re}>>>${Gr}"
tput cup 39 34
read -n1  aa11
if [[ "$aa10" == "1" ]]; then
	tput cup 39 34
	echo -e "${Wh}Yes"
else
	tput cup 39 34
	echo -e "${Wh}No"
fi







tput cup 45 3
echo -e "$Bl==================================="
tput cup 46 3
echo -e "=== ${Wh}        Please Wait         $Bl==="
tput cup 47 3
echo -e "==================================="
