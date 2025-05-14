#!/bin/bash
# vim:fileencoding=utf-8:foldmethod=marker
#
#{{{ >>>   Variables >#4
DIRBASE="/home/batan/lcbash"
DIRUSER="/media/batan/{100,200,300,400,500,600,700,800,900}"
DIRCONF=("lc-bashrc" "lc-clipboard" "lc-fm" "lc-gutenberg" "lc-mashpodder" "lc-ollama" "lc-ranger" "lists")
FILESDOT=("fzf.bash" "inputrc" "lc-cd" "lc-sign" "megarc" "music.kdl" "oolite-starter.conf" "profile" "rss.opml" "taskrc" "tkremind" "tmux.conf" "vimrc" "Xauthority" "xboardrc" "Xdefaults" "xinitrc" "Xresources")
FILESBASH=("bashrc" "bashrc.aliases" "bashrc.navigation")
FILESFUNCTIOS=""
#}}} <#11




#{{{ >>>   lc-daemon >#16

#run every half hour:
#{{{   >>>   remove cache pngs >#19
#System Maintanance to run in background on set intervals
#AS PART OF lc-deamon
CACHE_PNG=$(find .cache/ -maxdepth 3 -type f -name "*.png"|wc -l) #shred not remove eg -exec shred -z -f -n1 {} +
shred_cache_png() {
	find /home/batan/.cache -maxdepth 3 -type f -name "*.png" -exec shred -z -f -n1 {} +
}
remove_cache_png() {
	find /home/batan/.cache -maxdepth 3 -type f -name "*.png" -exec rm -rf {} +
}
#}}} <#29
#{{{ >>>   browser_history_to_list >#30
browser_history_to_list() {
browser-history|sort -u|sed 's!.*http!http!g'|sed 's![,].*$!!g'>> /home/batan/.config/lists/firefox.list
cat /home/batan/.config/lists/firefox.list|grep -vE "chess.com|duckduckgo "|sort -u >> /home/batan/firefox.list
 rm /home/batan/.config/lists/firefox.list
 mv /home/batan/firefox.list /home/batan/.config/lists/firefox.list
}
#}}} <#37
#{{{ >>>   backup_bash_history >#38
backup_bash_history() {
cat /home/batan/.bash_history* >> /home/batan/.config/lists/commands.md
cat /home/batan/.config/lists/commands.md|sort -u >> /home/batan/commands.md
rm /home/batan/.config/lists/commands.md
mv /home/batan/commands.md /home/batan/.config/lists/commands.md
}
#}}} <#45
#{{{ >>>   announce time hourly >#46
announce_time() {
while :; do
    notify-send -t 11000 "Time is:" "<span color='Yellow' font='36px'>"$(date +%H:%M)" </span>"
    edge-playback -t $(date +%H:%M)
    sleep 2400
done
}
#}}} <#54
#{{{ >>>   notification to display quotes or rendom comments from /home/batan/.config/lists/comments.md >#55
#while :; do notify-send -t 12000 "Excuse:" "$(cat /home/batan/.config/lists/comments.md|sort -R|tail -n1)" && sleep 5m ;done
#}}} <#57

###   functions - lisening to changes in clipbord and lc-gutenberg directory >#58
#{{{ >>>   clear clipbord >#60
xclip -selection clipboard /dev/null && xclip -selection primary /dev/null
#}}} <#62
#{{{ >>>   Text To Voice >#63
#watch directory for changes
lc-clipboard_gutenberg() {
WATCH_DIR="/home/batan/.config/lc-gutenberg"
VOICE="en-US-EmmaNeural"  # Change this if needed

inotifywait -m -e create --format '%f' "$WATCH_DIR" | while read -r file; do
    [[ $file == *.txt ]] || continue

    base="${file%.txt}"
    txt="$WATCH_DIR/$file"
    mp3="$WATCH_DIR/$base.mp3"

    /home/batan/.local/bin/edge-tts --voice "$VOICE" -f "$txt" --write-media "$mp3" &>/dev/null
    mpv --no-terminal "$mp3"
read -n1 -p "asd" fff
    rm -f "$txt" "$mp3"
done
}
#}}} <#82
#{{{ >>>   Move Reg >#83
move_register() {

        cat /home/batan/.config/lc-clipboard/register9|grep "http" >> /home/batan/.config/lc-clipboard/auto.register.md 2>/dev/null
		rm -f /home/batan/.config/lc-clipboard/register9 2>/dev/null
		mv /home/batan/.config/lc-clipboard/register8 /home/batan/.config/lc-clipboard/register9 2>/dev/null
		mv /home/batan/.config/lc-clipboard/register7 /home/batan/.config/lc-clipboard/register8 2>/dev/null
		mv /home/batan/.config/lc-clipboard/register6 /home/batan/.config/lc-clipboard/register7 2>/dev/null
		mv /home/batan/.config/lc-clipboard/register5 /home/batan/.config/lc-clipboard/register6 2>/dev/null
		mv /home/batan/.config/lc-clipboard/register4 /home/batan/.config/lc-clipboard/register5 2>/dev/null
		mv /home/batan/.config/lc-clipboard/register3 /home/batan/.config/lc-clipboard/register4 2>/dev/null
		mv /home/batan/.config/lc-clipboard/register2 /home/batan/.config/lc-clipboard/register3 2>/dev/null
		mv /home/batan/.config/lc-clipboard/register1 /home/batan/.config/lc-clipboard/register2 2>/dev/null
		touch /home/batan/.config/lc-clipboard/register1
}
#}}} <#98
#{{{ >>>   lc-clipboard background >#99
lc-clipboard-logic() {
    DIR_BASE="$HOME/.config/lc-clipboard"
    CONFIG_FILE="$DIR_BASE/config"
	TOGGLE_FILE="$DIR_BASE/toggle_*"
    if [[ $TOGGLE_FILE == "toggle_tts" ]]; then
        MODECLIP="I"
    elif [[ $TOGGLE_FILE == "toggle_clipboard" ]]; then
        MODECLIP="II"
    elif [[ $TOGGLE_FILE == "toggle_music" ]]; then
        MODECLIP="III"
    elif [[ $TOGGLE_FILE == "toggle_search" ]]; then
        MODECLIP="IV"
    elif [[ $TOGGLE_FILE == "toggle_cloud" ]]; then
        MODECLIP="V"
    fi


#	TOGGLE_FILE="$DIR_BASE/toggle_register"
 #   mkdir -p "$DIR_BASE"
 #   touch "$CONFIG_FILE"

    previous_clipboard=""

    while true; do
        # Load config values (key=value format)
        [[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"
        current_clipboard=$(xclip -o -selection clipboard 2>/dev/null)
        cleaned_clipboard=$(echo "$current_clipboard" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

        # Skip empty or unchanged clipboard
        [[ -z "$cleaned_clipboard" || "$cleaned_clipboard" == "$previous_clipboard" ]] && sleep 0.0001 && continue
		if [[ -f "$TOGGLE_FILE" ]]; then
			xclip -o -selection clipboard >> /home/batan/.config/lc-gutenberg/$(( $(ls /home/batan/.config/lc-gutenberg/*.txt|wc -l 2>/dev/null) + 1 )).txt
        else
			move_register
			echo "$cleaned_clipboard" > "$DIR_BASE/register1"
		fi


        # === Conditional Logic ===
        if [[ "$cleaned_clipboard" == http* ]]; then
            echo "$cleaned_clipboard" >> "$DIR_BASE/urls.log"

        elif grep -qi youtube <<< "$cleaned_clipboard"; then
            echo "$cleaned_clipboard" >> "$DIR_BASE/youtube.log"

        elif [[ "${LOG_PLAIN}" == "true" ]]; then
            echo "$cleaned_clipboard" >> "$DIR_BASE/plain.log"

 #       elif [[ -n "$REDIRECT_PATH" ]]; then
 #           echo "$cleaned_clipboard" >> "$REDIRECT_PATH"
#
#        elif [[ "$CENSOR" == "true" ]]; then
#            echo "[CENSORED]" >> "$DIR_BASE/censored.log"

#        elif [[ "$cleaned_clipboard" == *password* ]]; then
#            echo "[SECRET]" >> "$DIR_BASE/secrets.log"

        fi
 echo $cleaned_clipboard >> ~/urls.txt
        previous_clipboard="$cleaned_clipboard"
        sleep 0.0001
    done
}
#}}} <#164
#{{{ >>>   execute above functions in detached background and display respective PID >#165
announce_time &
PIDannouncetime=$!
echo "Announce_time: $PIDannouncetime"
lc-clipboard_gutenberg &
PIDgutenberg=$!
echo "Gutenberg: $PIDgutenberg"
lc-clipboard-logic &
PIDclipboard=$!
echo "Clipboard: $PIDclipboard"
#}}} <#175
#}}} <#176





#{{{ >>>   functions >#182
update_dotfiles() {
	for i in $(ls $DIRBASHE/dotfiles); do
		if [[ $i == "/home/batan/.$i" ]]; then
			mv /home/batan/.$i /home/batan/.$i.org
		fi
		cp $DIRBASE/dotfiles/$i /home/batan/.$i
	done
}

setlightdm() {
	if [[ -f /etc/lightdm/lightdm-gtk-greeter.conf ]]; then
	cat /etc/lightdm/lightdm-gtk-greeter.conf|grep lightdm.png >/dev/null 2>&1
	if [[ $? == "0" ]]; then
		return
	fi
	else
		git clone https://github.com/batann/lightdm-gtk-greeter
		sudo mv /etc/lightdm/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf.org
		sudo mv lightdm-gtk-greeter/* /etc/lightdm
	fi

}

#}}} <#206
