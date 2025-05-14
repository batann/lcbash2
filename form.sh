#!/bin/bash
# vim:fileencoding=utf-8:foldmethod=marker
tput civis
clear
tput cup 3 2
echo -e "\033[36mFollowing details are needed for a complete OS Setup incl basic linux tools!\033[0m"
echo -e "\033[33m  ───────────────────────────────────────────────────────────────────────────\033[0m"
tput cup 5 8;echo -e "\033[37mName \033[35m";tput cup 5 25;echo -e ":\033[0m"
tput cup 6 8;echo -e "\033[37mEmail \033[35m";tput cup 6 25;echo -e ":\033[0m"
tput cup 7 8;echo -e "\033[37mPassphrase \033[35m";tput cup 7 25;echo -e ":\033[0m"
tput cup 8 8;echo -e "\033[37mData Partition \033[35m";tput cup 8 25;echo -e ":\033[0m"
tput cup 9 8;echo -e "\033[37mGPG Passphrase \033[35m";tput cup 9 25;echo -e ":\033[0m"
tput cup 10 8;echo -e "\033[37mUser Passphrase \033[35m";tput cup 10 25;echo -e ":\033[0m"
tput cup 11 8;echo -e "\033[37mRoot Passphrase \033[35m";tput cup 11 25;echo -e ":\033[0m"
tput cup 12 8;echo -e "\033[37mNeomutt Password \033[35m";tput cup 12 25;echo -e ":\033[0m"
tput cup 13 8;echo -e "\033[37mxxxxxxxxxxx \033[35m";tput cup 13 25;echo -e ":\033[0m"

echo -e "\033[32m"
tput cup 5 26;read -e -i "batan" bb1
tput cup 6 26;read -e -i "tel.petar@gmail.com" bb2
tput cup 7 26;read -e -i "Ba7an?12982" bb3
tput cup 8 26;read -e -i "c96173e2-aae6-43b1-bad3-2d8fb4e87e25" bb4
tput cup 9 26;read -e -i "Ba7an?12982" bb5
tput cup 10 26;read -e -i "Ba7an?12982" bb6
tput cup 11 26;read -e -i "" bb7
tput cup 12 26;read -e -i "" bb8
tput cup 13 26;read -e -i "" bb9
tput cnorm
