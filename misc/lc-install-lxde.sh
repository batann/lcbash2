#!/bin/bash
DEPS_LXDE=( "gpicview" "libfm-data" "libfm-extra4" "libfm-gtk-data" "libfm-gtk4" "libfm-modules" "libfm4" "libgspell-1-2" "libgspell-1-common" "libgtksourceview-4-0" "libgtksourceview-4-common" "libkeybinder0" "libmenu-cache-bin" "libmenu-cache3" "libmousepad0" "libobrender32v5" "libobt2v5" "libwnck-common" "libwnck22" "lxappearance-obconf" "lxde-common" "lxde-core" "lxde-icon-theme" "lxde" "lxhotkey-core" "lxhotkey-gtk" "lxinput" "lxlauncher" "lxpanel-data" "lxpanel" "lxpolkit" "lxrandr" "lxsession-data" "lxsession-edit" "lxsession-logout" "lxsession" "lxtask" "lxterminal" "mousepad" "obconf" "openbox-lxde-session" "openbox" "pcmanfm")

for pak in ${DEPS_LXDE[@]}; do
	dpkg -s $pak >/dev/null 2>&1
	if [[ $? == "1" ]]; then
		echo -e "\033[34mInstalling \033[32m$pak\033[34m ...\033[0m"
		sudo apt install -y $pak >/dev/null 2>&1
	fi
done


