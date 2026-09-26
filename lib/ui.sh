#!/usr/bin/env bash
# ==============================================================================
# UI & DISPLAY FUNCTIONS
# ==============================================================================

ui_clear() {
    clear 2>/dev/null || tput clear 2>/dev/null || echo -e "\033c"
}

show_header() {
    ui_clear
    local current_time hostname_val user_val

    # Calculated statically at render time — no background process or loop
    current_time=$(date "+%Y-%m-%d %H:%M:%S")
    hostname_val=$(hostname 2>/dev/null || echo "VPS")
    user_val=$(whoami 2>/dev/null || echo "root")

    echo -e "\033[38;5;82m╔══════════════════════════════════════════════════════╗\033[0m"
    echo -e "\033[38;5;82m║\033[38;5;15m\033[1m                    CORE MAIN V1                      \033[38;5;82m║\033[0m"
    echo -e "\033[38;5;82m║\033[38;5;245m              INFINITE CORE • CONTROL               \033[38;5;82m║\033[0m"
    echo -e "\033[38;5;82m╚══════════════════════════════════════════════════════╝\033[0m"
    echo -e " Time:        \033[38;5;51m${current_time}\033[0m"
    echo -e " VPS Name:    \033[38;5;82m${hostname_val}\033[0m"
    echo -e " User:        \033[38;5;82m${user_val}\033[0m"
    echo -e "\033[38;5;82m──────────────────────────────────────────────────────\033[0m"
}

pause_prompt() {
    echo ""
    echo -e "\033[38;5;245mPress [ENTER] to return to menu...\033[0m"
    read -r
}
