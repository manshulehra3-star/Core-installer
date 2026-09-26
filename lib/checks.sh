#!/usr/bin/env bash
# ==============================================================================
# CHECKS & DIAGNOSTICS LIBRARY — CORE MAIN V1
# ==============================================================================

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${BADGE_ERR} ${RED}Error: CORE MAIN V1 requires root access.${NC}"
        echo -e "Please run with: ${GREEN}sudo bash install.sh${NC}"
        exit 1
    fi
}

check_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        if [[ "$ID" != "ubuntu" && "$ID" != "debian" && "$ID_LIKE" != *"ubuntu"* && "$ID_LIKE" != *"debian"* ]]; then
            echo -e "${BADGE_WARN} ${YELLOW}Warning: Target OS ($NAME) is not Debian/Ubuntu-based.${NC}"
            echo -e "Some automated installation operations may fail."
        fi
    else
        echo -e "${BADGE_WARN} ${YELLOW}Unable to detect OS distribution type.${NC}"
    fi
}

get_ram_info() {
    if command -v free >/dev/null 2>&1; then
        local used total
        used=$(free -h | awk '/Mem:/ {print $3}')
        total=$(free -h | awk '/Mem:/ {print $2}')
        echo "${used} / ${total}"
    else
        echo "N/A"
    fi
}

get_cpu_info() {
    local cores model
    cores=$(nproc 2>/dev/null || echo "1")
    model=$(lscpu 2>/dev/null | grep "Model name:" | sed 's/Model name:[ \t]*//' | head -n 1)
    [[ -z "$model" ]] && model=$(grep -m1 "model name" /proc/cpuinfo 2>/dev/null | cut -d: -f2 | xargs)
    [[ -z "$model" ]] && model="Generic CPU"
    echo "${cores} Cores (${model:0:22})"
}

get_disk_info() {
    if command -v df >/dev/null 2>&1; then
        local used total free_space
        used=$(df -h / | awk 'NR==2 {print $3}')
        total=$(df -h / | awk 'NR==2 {print $2}')
        free_space=$(df -h / | awk 'NR==2 {print $4}')
        echo "${used} / ${total} (${free_space} free)"
    else
        echo "N/A"
    fi
}

check_lxc_avail() {
    if command -v lxc >/dev/null 2>&1 || command -v lxc-create >/dev/null 2>&1 || [[ -d /dev/lxc ]]; then
        echo -e "${GREEN}AVAILABLE${NC}"
    elif grep -q "container=lxc" /proc/1/environ 2>/dev/null; then
        echo -e "${YELLOW}INSIDE CONTAINER${NC}"
    else
        echo -e "${RED}NOT AVAILABLE${NC}"
    fi
}

check_kvm_avail() {
    if [[ -e /dev/kvm ]]; then
        echo -e "${GREEN}AVAILABLE${NC}"
    elif grep -E -q '(vmx|svm)' /proc/cpuinfo 2>/dev/null; then
        echo -e "${GREEN}AVAILABLE (CPU HARDWARE support)${NC}"
    else
        echo -e "${RED}NOT AVAILABLE${NC}"
    fi
}

get_public_ip_v4() {
    curl -s4 --max-time 3 https://api.ipify.org || curl -s4 --max-time 3 https://ifconfig.me || echo "Unavailable"
}

get_public_ip_v6() {
    curl -s6 --max-time 3 https://api64.ipify.org || echo "Unavailable/None"
}

get_local_ip_v4() {
    ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}' || hostname -I | awk '{print $1}' || echo "127.0.0.1"
}
