#!/usr/bin/env bash
# ==============================================================================
# HELPERS & INPUT VALIDATION LIBRARY — CORE MAIN V1
# ==============================================================================

pause_prompt() {
    echo ""
    echo -e "${GRAY}Press [ENTER] to return to menu...${NC}"
    read -r
}

confirm_action() {
    local msg="$1"
    echo -e "${BADGE_WARN} ${YELLOW}${msg}${NC}"
    read -rp "Type 'YES' to confirm: " response
    if [[ "$response" == "YES" ]]; then
        return 0
    else
        echo -e "${BADGE_INFO} Action cancelled by user."
        return 1
    fi
}

validate_email() {
    local email="$1"
    [[ "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]
}

validate_domain_or_ip() {
    local input="$1"
    [[ -n "$input" ]]
}

run_quiet() {
    local cmd="$1"
    log_scrubbed "$cmd"
    eval "$cmd" >> "$LOG_FILE" 2>&1
    return $?
}
