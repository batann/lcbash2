#!/bin/bash
# vim:fileencoding=utf-8:foldmethod=marker
#
# script to run on session-start to handle all background processes that are currently handled by dotfiles or helper scripts such as .profil and so on.
# Listening for clipboard changes
# Handling the Control FIle
# ect


base_dir="$HOME/.local/run/lcsession"
mkdir -p "$base_dir"
log_dir="$HOME/.local/log/lcsession"
mkdir -p "$log_dir"

clip_pid="$base_dir/clipboard.pid"
dir_pid="$base_dir/dirwatch.pid"

clip_log="$log_dir/clipboard.log"
dir_log="$log_dir/dirwatch.log"

start_clipboard() {
  (
    while true; do
      {
        xclip -o -selection primary 2>/dev/null | tee "$HOME/.lcclip" >> "$clip_log"
      } || echo "[$(date +%F\ %T)] Clipboard watcher crashed" >> "$clip_log"
      sleep 2
    done
  ) &
  echo $! > "$clip_pid"
}

start_dirwatch() {
  watched_dir="$HOME/lcwatch"
  mkdir -p "$watched_dir"
  (
    while true; do
      inotifywait -m -r -e modify,create,delete "$watched_dir" 2>> "$dir_log" |
      while read -r line; do
        echo "$(date +%F\ %T) $line" >> "$dir_log"
      done
      echo "[$(date +%F\ %T)] Directory watcher crashed, restarting..." >> "$dir_log"
      sleep 2
    done
  ) &
  echo $! > "$dir_pid"
}

stop_process() {
  pid_file="$1"
  if [[ -f "$pid_file" ]]; then
    pid=$(cat "$pid_file")
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid"
      echo "Stopped process $pid"
    else
      echo "Process $pid not running"
    fi
    rm -f "$pid_file"
  fi
}

status_process() {
  pid_file="$1"
  name="$2"
  if [[ -f "$pid_file" ]]; then
    pid=$(cat "$pid_file")
    if kill -0 "$pid" 2>/dev/null; then
      echo "$name: running (PID $pid)"
    else
      echo "$name: not running (stale PID $pid)"
    fi
  else
    echo "$name: not running"
  fi
}

case "$1" in
  start)
    [[ -f "$clip_pid" ]] && kill -0 "$(cat "$clip_pid")" 2>/dev/null || start_clipboard
    [[ -f "$dir_pid" ]] && kill -0 "$(cat "$dir_pid")" 2>/dev/null || start_dirwatch
    ;;
  stop)
    stop_process "$clip_pid"
    stop_process "$dir_pid"
    ;;
  status)
    status_process "$clip_pid" "Clipboard Watcher"
    status_process "$dir_pid" "Directory Watcher"
    ;;
  *)
    echo "Usage: $0 start|stop|status"
    ;;
esac

