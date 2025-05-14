inst_budgie() {
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
inst_budgie
