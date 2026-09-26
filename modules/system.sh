#!/usr/bin/env bash
# ==============================================================================
# SYSTEM MANAGER MODULE — CORE MAIN V1
# ==============================================================================

module_system_manager() {
    while true; do
        ui_draw_header
        ui_draw_box_start "SYSTEM MANAGER"
        echo -e "  ${GREEN}[1]${NC} Detailed System Information"
        echo -e "  ${GREEN}[2]${NC} Check VPS IP Addresses"
        echo -e "  ${GREEN}[3]${NC} Update System Packages"
        echo -e "  ${GREEN}[4]${NC} Repair System Dependencies"
        echo -e "  ${GREEN}[5]${NC} View Logs (Panel, Wings, System)"
        echo -e "  ${GREEN}[6]${NC} Backup Configurations"
        echo -e "  ${GREEN}[7]${NC} Fresh VPS / Clean System (Destructive)"
        echo -e "  ${GREEN}[0]${NC} Back"
        ui_draw_box_end

        read -rp "Select Option: " choice
        case "$choice" in
            1) sys_info_sub ;;
            2) sys_ip_sub ;;
            3) sys_update_sub ;;
            4) sys_repair_sub ;;
            5) sys_logs_sub ;;
            6) sys_backup_sub ;;
            7) sys_fresh_reset_sub ;;
            0) break ;;
            *) echo -e "${BADGE_ERR} Invalid Option"; sleep 1 ;;
        esac
    done
}

sys_info_sub() {
    ui_draw_header
    ui_draw_box_start "DETAILED SYSTEM INFO"

    echo -e " OS:            ${WHITE}$(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')${NC}"
    echo -e " Kernel:        ${WHITE}$(uname -r)${NC}"
    echo -e " Architecture:  ${WHITE}$(uname -m)${NC}"
    echo -e " Hostname:      ${WHITE}$(hostname)${NC}"
    echo -e " Uptime:        ${WHITE}$(uptime -p | sed 's/up //')${NC}"
    echo -e " Virtualization:${WHITE}$(systemd-detect-virt 2>/dev/null || echo "Unknown")${NC}"
    echo -e " LXC Status:    ${WHITE}$(check_lxc_avail)${NC}"
    echo -e " KVM Status:    ${WHITE}$(check_kvm_avail)${NC}"

    pause_prompt
}

sys_ip_sub() {
    ui_draw_header
    ui_draw_box_start "VPS IP IDENTIFIER"

    echo -e " Public IPv4:  ${CYAN}$(get_public_ip_v4)${NC}"
    echo -e " Public IPv6:  ${CYAN}$(get_public_ip_v6)${NC}"
    echo -e " Local IPv4:   ${CYAN}$(get_local_ip_v4)${NC}"

    pause_prompt
}

sys_update_sub() {
    ui_draw_header
    ui_draw_box_start "SYSTEM UPDATE"

    echo -e "${BADGE_INFO} Updating package indexes and performing upgrade..."
    apt-get update -y
    apt-get upgrade -y
    echo -e "${BADGE_OK} ${GREEN}System updated successfully.${NC}"

    pause_prompt
}

sys_repair_sub() {
    ui_draw_header
    ui_draw_box_start "REPAIR DEPENDENCIES"

    echo -e "${BADGE_INFO} Fixing broken packages and repairing installation state..."
    dpkg --configure -a >> "$LOG_FILE" 2>&1
    apt-get install -f -y >> "$LOG_FILE" 2>&1
    systemctl daemon-reload >> "$LOG_FILE" 2>&1
    echo -e "${BADGE_OK} ${GREEN}System services and package manager state repaired.${NC}"

    pause_prompt
}

sys_logs_sub() {
    ui_draw_header
    ui_draw_box_start "SYSTEM LOG VIEWER"

    echo -e "  ${GREEN}[1]${NC} View Panel Logs"
    echo -e "  ${GREEN}[2]${NC} View Wings Logs"
    echo -e "  ${GREEN}[3]${NC} View Installer Log"
    echo -e "  ${GREEN}[4]${NC} View Syslog (Tail 30)"
    echo -e "  ${GREEN}[0]${NC} Back"

    read -rp "Select Log: " log_choice
    case "$log_choice" in
        1) tail -n 50 /var/www/pterodactyl/storage/logs/laravel*.log 2>/dev/null || echo "No Panel logs found." ;;
        2) journalctl -u wings -n 50 --no-pager 2>/dev/null || echo "No Wings logs found." ;;
        3) tail -n 50 "$LOG_FILE" ;;
        4) tail -n 30 /var/log/syslog 2>/dev/null || journalctl -n 30 --no-pager ;;
    esac
    pause_prompt
}

sys_backup_sub() {
    ui_draw_header
    ui_draw_box_start "CONFIGURATION BACKUP"

    local backup_dir="/root/core_backups_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"

    echo -e "${BADGE_INFO} Backing up key configuration files..."
    [[ -d /etc/pterodactyl ]] && cp -r /etc/pterodactyl "$backup_dir/wings_etc" 2>/dev/null
    [[ -f /var/www/pterodactyl/.env ]] && cp /var/www/pterodactyl/.env "$backup_dir/panel_env" 2>/dev/null
    [[ -d /etc/nginx/sites-available ]] && cp -r /etc/nginx/sites-available "$backup_dir/nginx_sites" 2>/dev/null

    echo -e "${BADGE_OK} ${GREEN}Configurations backed up to: ${CYAN}${backup_dir}${NC}"
    pause_prompt
}

sys_fresh_reset_sub() {
    ui_draw_header
    ui_draw_box_start "FRESH VPS CLEAN RESET"

    echo -e "${RED}${BOLD}==================== DANGER ZONE ====================${NC}"
    echo -e "${YELLOW}This operation cleans installed services (Nginx, MariaDB, Panel, Wings).${NC}"
    echo -e "${YELLOW}It does NOT destroy the Linux Kernel/OS core files.${NC}"
    echo -e "${RED}${BOLD}====================================================${NC}\n"

    if ! confirm_action "FIRST CONFIRMATION: Are you sure you want to purge Panel/Wings/Nginx setup?"; then
        return
    fi

    echo ""
    read -rp "SECOND CONFIRMATION: Type 'CLEAN ALL DATA' to proceed: " final_check
    if [[ "$final_check" != "CLEAN ALL DATA" ]]; then
        echo -e "${BADGE_INFO} Operation aborted."
        pause_prompt
        return
    fi

    echo -e "${BADGE_INFO} Stopping services..."
    systemctl stop wings pterodactyl nginx mariadb redis-server pteroq 2>/dev/null

    echo -e "${BADGE_INFO} Removing installed Pterodactyl files & configs..."
    rm -rf /var/www/pterodactyl /etc/pterodactyl /etc/systemd/system/pteroq.service /etc/systemd/system/wings.service
    
    systemctl daemon-reload
    echo -e "${BADGE_OK} ${GREEN}System cleaned safely. Ready for fresh installations.${NC}"
    pause_prompt
}
