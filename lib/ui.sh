#!/usr/bin/env bash
# ==============================================================================
# File: lib/ui.sh
# Module: User Interface & Header Display
# ==============================================================================

# Static time calculation — called ONCE per header draw
get_system_time() {
    date "+%Y-%m-%d %H:%M:%S"
}

ui_clear() {
    clear 2>/dev/null || tput clear 2>/dev/null || echo -e "\033c"
}

show_header() {
    ui_clear
    local current_time
    current_time=$(get_system_time)

    echo -e "\033[38;5;82m╔══════════════════════════════════════════════════════╗\033[0m"
    echo -e "\033[38;5;82m║\033[38;5;15m\033[1m                    CORE MAIN V1                      \033[38;5;82m║\033[0m"
    echo -e "\033[38;5;82m║\033[38;5;245m              INFINITE CORE • CONTROL               \033[38;5;82m║\033[0m"
    echo -e "\033[38;5;82m╚══════════════════════════════════════════════════════╝\033[0m"
    echo -e " Time:        \033[38;5;51m${current_time}\033[0m"
    echo -e " VPS Name:    \033[38;5;82m$(hostname 2>/dev/null || echo "VPS")\033[0m"
    echo -e " User:        \033[38;5;82m$(whoami 2>/dev/null || echo "root")\033[0m"
    echo -e "\033[38;5;82m──────────────────────────────────────────────────────\033[0m"
}

pause_prompt() {
    echo ""
    read -rp "Press [ENTER] to return to main menu..." unused_var
}
