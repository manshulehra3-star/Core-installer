#!/usr/bin/env bash
# ==============================================================================
# File: main.sh
# Module: CORE MAIN V1 Entry Point & Execution Loop
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source library modules
[[ -f "${SCRIPT_DIR}/lib/ui.sh" ]] && source "${SCRIPT_DIR}/lib/ui.sh"
[[ -f "${SCRIPT_DIR}/lib/logging.sh" ]] && source "${SCRIPT_DIR}/lib/logging.sh"
[[ -f "${SCRIPT_DIR}/lib/checks.sh" ]] && source "${SCRIPT_DIR}/lib/checks.sh"
[[ -f "${SCRIPT_DIR}/lib/helpers.sh" ]] && source "${SCRIPT_DIR}/lib/helpers.sh"

# Explicitly clean up any remaining legacy background subshells/jobs
kill_legacy_clock_jobs() {
    if [[ -n "${CLOCK_PID:-}" ]]; then
        kill "$CLOCK_PID" 2>/dev/null || true
        unset CLOCK_PID
    fi
}

show_main_menu() {
    kill_legacy_clock_jobs

    while true; do
        # 1. Render main screen and compute system time ONCE
        show_header

        # 2. Display options
        echo -e "  \033[38;5;82m[1]\033[0m Panel Installer"
        echo -e "  \033[38;5;82m[2]\033[0m Wings Installer"
        echo -e "  \033[38;5;82m[3]\033[0m Server Tools"
        echo -e "  \033[38;5;82m[4]\033[0m Security Manager"
        echo -e "  \033[38;5;82m[5]\033[0m System Manager"
        echo ""
        echo -e "  \033[38;5;82m[0]\033[0m Exit"
        echo ""

        # 3. Standard blocking prompt (terminal execution freezes until Enter is pressed)
        read -rp "Select Option [0-5]: " choice

        # 4. Action routing
        case "$choice" in
            1)
                if declare -f run_panel_installer >/dev/null; then
                    run_panel_installer
                else
                    echo -e "\n[+] Launching Panel Installer..."
                fi
                pause_prompt
                ;;
            2)
                if declare -f run_wings_installer >/dev/null; then
                    run_wings_installer
                else
                    echo -e "\n[+] Launching Wings Installer..."
                fi
                pause_prompt
                ;;
            3)
                if declare -f run_server_tools >/dev/null; then
                    run_server_tools
                else
                    echo -e "\n[+] Launching Server Tools..."
                fi
                pause_prompt
                ;;
            4)
                if declare -f run_security_manager >/dev/null; then
                    run_security_manager
                else
                    echo -e "\n[+] Launching Security Manager..."
                fi
                pause_prompt
                ;;
            5)
                if declare -f run_system_manager >/dev/null; then
                    run_system_manager
                else
                    echo -e "\n[+] Launching System Manager..."
                fi
                pause_prompt
                ;;
            0)
                echo -e "\nExiting CORE MAIN V1..."
                exit 0
                ;;
            *)
                echo -e "\nInvalid option. Please enter 0-5."
                sleep 1
                ;;
        esac
    done
}

# Entry Point Execution
show_main_menu
