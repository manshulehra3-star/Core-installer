bash
#!/usr/bin/env bash
# ==============================================================================
# UI LIBRARY — CORE MAIN V1
# ==============================================================================

# Color Definitions
export NC="\033[0m"
export BOLD="\033[1m"
export DIM="\033[2m"

export GREEN="\033[38;5;82m"
export WHITE="\033[38;5;15m"
export GRAY="\033[38;5;245m"
export RED="\033[38;5;196m"
export YELLOW="\033[38;5;214m"
export BLUE="\033[38;5;39m"
export CYAN="\033[38;5;51m"

# Indicators
export BADGE_OK="${GREEN}[✓]${NC}"
export BADGE_WARN="${YELLOW}[!]${NC}"
export BADGE_ERR="${RED}[✗]${NC}"
export BADGE_INFO="${CYAN}[•]${NC}"

# Terminal Utilities
ui_clear() {
    clear 2>/dev/null || tput clear 2>/dev/null || echo -e "\033c"
}

ui_draw_header() {
    ui_clear
    local current_time hostname_val user_val ram_val cpu_val disk_val lxc_val kvm_val

    current_time=$(date "+%H:%M:%S")
    hostname_val=$(hostname)
    user_val=$(whoami)
    ram_val=$(get_ram_info)
    cpu_val=$(get_cpu_info)
    disk_val=$(get_disk_info)
    lxc_val=$(check_lxc_avail)
    kvm_val=$(check_kvm_avail)

    echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${WHITE}${BOLD}                    CORE MAIN V1                      ${GREEN}║${NC}"
    echo -e "${GREEN}║${GRAY}              INFINITE CORE • CONTROL               ${GREEN}║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
    echo -e "${WHITE} Time:        ${CYAN}${current_time}${NC}"
    echo -e "${WHITE} VPS Name:    ${GREEN}${hostname_val}${NC}"
    echo -e "${WHITE} User:        ${GREEN}${user_val}${NC}"
    echo -e "${WHITE} RAM:         ${ram_val}${NC}"
    echo -e "${WHITE} CPU:         ${cpu_val}${NC}"
    echo -e "${WHITE} Disk:        ${disk_val}${NC}"
    echo -e "${WHITE} LXC:         ${lxc_val}${NC}"
    echo -e "${WHITE} KVM:         ${kvm_val}${NC}"
    echo -e "${GREEN}──────────────────────────────────────────────────────${NC}"
}

ui_draw_box_start() {
    local title="$1"
    local width=48
    local pad=$(( (width - ${#title}) / 2 ))
    printf "${GREEN}╔"
    printf '═%.0s' {1..48}
    printf "╗\n${NC}"
    printf "${GREEN}║${BOLD}${WHITE}%*s%s%*s${NC}${GREEN}║\n" "$pad" "" "$title" "$(( width - pad - ${#title} ))" ""
    printf "${GREEN}╠"
    printf '═%.0s' {1..48}
    printf "╣\n${NC}"
}

ui_draw_box_end() {
    printf "${GREEN}╚"
    printf '═%.0s' {1..48}
    printf "╝\n${NC}"
}

ui_print_step() {
    local step="$1"
    local total="$2"
    local message="$3"
    echo -e "${CYAN}[${step}/${total}]${NC} ${WHITE}${message}${NC}"
}

ui_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}
