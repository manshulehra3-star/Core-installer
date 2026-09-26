#!/usr/bin/env bash

# ==============================================================================
# File: lib/ui.sh
# ==============================================================================

ui_clear() {
    clear 2>/dev/null || tput clear 2>/dev/null || echo -e "\033c"
}

show_header() {
    ui_clear
    
    # Get time ONCE at the exact moment this function is called
    local current_time
    current_time=$(date "+%Y-%m-%d %H:%M:%S")

    echo "=========================================================="
    echo "                     CORE MAIN V1                         "
    echo "               System Time: $current_time                 "
    echo "=========================================================="
    echo ""
}

pause_prompt() {
    echo ""
    read -rp "Press [ENTER] to return to main menu..."
}
