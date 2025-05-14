#!/bin/bash

# Path to function source
DAEMON_FUNCS="/home/batan/lcbash/functions/daemon_functions"

# Load daemon function definitions
[[ -f "$DAEMON_FUNCS" ]] || {
    echo "Missing $DAEMON_FUNCS"
    exit 1
}
source "$DAEMON_FUNCS"

# Periodic function list
PERIODIC_FUNCS=(
    remove_cache_png
    browser_history_to_list
    announce_time
    notification_to_user
)

# Ongoing function list (run as background persistent loops)
ONGOING_FUNCS=(
    listen_to_clipboard_changes
    some_function
    some_more_function
)

# Log function (optional)
log() {
    printf "[%s] %s\n" "$(date '+%F %T')" "$*" >> /tmp/lcdaemon.log
}

# --- Periodic Task Runner ---
run_periodic() {
    while true; do
        for func in "${PERIODIC_FUNCS[@]}"; do
            if declare -f "$func" > /dev/null; then
                log "Running periodic: $func"
                "$func" &
            else
                log "Missing function: $func"
            fi
        done
        wait  # Wait for all above to finish before sleeping
        sleep 1800  # 30 minutes
    done
}

# --- Ongoing Background Tasks ---
run_ongoing() {
    for func in "${ONGOING_FUNCS[@]}"; do
        if declare -f "$func" > /dev/null; then
            log "Starting ongoing: $func"
            (
                while true; do
                    "$func" || log "Crash in $func; retrying in 5s"
                    sleep 5
                done
            ) &
        else
            log "Missing function: $func"
        fi
    done
}

# --- Entrypoint ---
main() {
    log "Daemon starting..."
    run_ongoing
    run_periodic
}

main

