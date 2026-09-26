#!/usr/bin/env bash

# ==============================================================================
# File: main.sh
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source module files
[[ -f "${SCRIPT_DIR}/lib/ui.sh" ]] && source "${SCRIPT_DIR}/lib/ui.sh"
[[ -f "${SCRIPT_DIR}/lib/logging.sh" ]] && source "${SCRIPT_DIR}/lib/logging.sh"
[[ -f "${SCRIPT_DIR}/lib/checks.sh" ]] && source "${SCRIPT_DIR}/lib/checks.sh"
[[ -f "${SCRIPT_DIR}/lib/helpers.sh" ]] && source "${SCRIPT_DIR}/lib/helpers.sh"

show_main_menu() {
    while true; do
        # 1. Open Menu / Return to Menu
        # 2. Render Header (calculates date ONCE)
        show_header

        echo "1) Panel Installer"
        echo "2) Wings Installer"
        echo "3) Server Tools"
        echo "4) Security Manager"
        echo "5) System Manager"
        echo "6) Exit"
        echo ""

        # 3. Blocking input prompt (screen will NOT clear or refresh while typing)
        read -rp "Select an option [1-6]: " choice

        case "$choice" in
            1)
                type run_panel_installer &>/dev/null && run_panel_installer || echo "Panel Installer module loaded."
                pause_prompt
                ;;
            2)
                type run_wings_installer &>/dev/null && run_wings_installer || echo "Wings Installer module loaded."
                pause_prompt
                ;;
            3)
                type run_server_tools &>/dev/null && run_server_tools || echo "Server Tools module loaded."
                pause_prompt
                ;;
            4)
                type run_security_manager &>/dev/null && run_security_manager || echo "Security Manager module loaded."
                pause_prompt
                ;;
            5)
                type run_system_manager &>/dev/null && run_system_manager || echo "System Manager module loaded."
                pause_prompt
                ;;
            6)
                echo "Exiting..."
                exit 0
                ;;
            *)
                echo "Invalid option."
                sleep 1
                ;;
        esac
    done
}

# Launch main menu
show_main_menu
