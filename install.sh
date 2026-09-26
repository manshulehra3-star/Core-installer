#!/usr/bin/env bash
# ==============================================================================
# CORE MAIN V1 — INFINITE CORE CONTROL INSTALLER
# ==============================================================================

# Strict bash safety options
set -o pipefail

# Directory Discovery
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source Libraries
if [[ -f "$SCRIPT_DIR/lib/ui.sh" ]]; then
    source "$SCRIPT_DIR/lib/ui.sh"
    source "$SCRIPT_DIR/lib/checks.sh"
    source "$SCRIPT_DIR/lib/logging.sh"
    source "$SCRIPT_DIR/lib/helpers.sh"
else
    echo "Error: Missing library files in $SCRIPT_DIR/lib/"
    exit 1
fi

# Source Modules
if [[ -f "$SCRIPT_DIR/modules/panel.sh" ]]; then
    source "$SCRIPT_DIR/modules/panel.sh"
    source "$SCRIPT_DIR/modules/wings.sh"
    source "$SCRIPT_DIR/modules/tools.sh"
    source "$SCRIPT_DIR/modules/security.sh"
    source "$SCRIPT_DIR/modules/system.sh"
else
    echo "Error: Missing module files in $SCRIPT_DIR/modules/"
    exit 1
fi

# Trap Ctrl+C (SIGINT) and exit cleanly
cleanup_and_exit() {
    echo -e "\n\n${BADGE_INFO} ${WHITE}Exiting CORE MAIN V1 cleanly. Goodbye!${NC}"
    exit 0
}
trap cleanup_and_exit SIGINT SIGTERM

# Main Execution Loop
main() {
    check_root
    check_os
    log_info "CORE MAIN V1 Started by root."

    while true; do
        ui_draw_header

        ui_draw_box_start "MAIN MENU"
        echo -e "  ${GREEN}[1]${NC} Panel Installer"
        echo -e "  ${GREEN}[2]${NC} Wings Installer"
        echo -e "  ${GREEN}[3]${NC} Server Tools"
        echo -e "  ${GREEN}[4]${NC} Security Manager"
        echo -e "  ${GREEN}[5]${NC} System Manager"
        echo -e ""
        echo -e "  ${GREEN}[0]${NC} Exit"
        ui_draw_box_end

        read -rp "Select Module [0-5]: " main_choice

        case "$main_choice" in
            1) module_panel_installer ;;
            2) module_wings_installer ;;
            3) module_server_tools ;;
            4) module_security_manager ;;
            5) module_system_manager ;;
            0) cleanup_and_exit ;;
            *)
                echo -e "${BADGE_ERR} Invalid option. Please select 0-5."
                sleep 1
                ;;
        esac
    done
}

# Start Execution
main "$@"
