#!/usr/bin/env bash

# File: main.sh

# Ensure no background timer/watch process is spawned on launch
stop_background_clock() {
    if [[ -n "$CLOCK_PID" ]]; then
        kill "$CLOCK_PID" 2>/dev/null || true
        unset CLOCK_PID
    fi
}

show_main_menu() {
    while true; do
        # Clear once per render, not on a timer
        clear
        show_header

        echo "1) Panel Installer"
        echo "2) Wings Installer"
        echo "3) Server Tools"
        echo "4) Security Manager"
        echo "5) System Manager"
        echo "6) Exit"
        echo ""
        
        # Standard blocking read keeps input completely stable
        read -rp "Select an option [1-6]: " choice

        case "$choice" in
            1)
                run_panel_installer
                ;;
            2)
                run_wings_installer
                ;;
            3)
                run_server_tools
                ;;
            4)
                run_security_manager
                ;;
            5)
                run_system_manager
                ;;
            6)
                echo "Exiting..."
                exit 0
                ;;
            *)
                echo -e "\nInvalid option. Press Enter to continue..."
                read -r
                ;;
        esac
    done
}

# Entry point
stop_background_clock
show_main_menu
