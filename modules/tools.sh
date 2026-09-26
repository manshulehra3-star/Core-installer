#!/usr/bin/env bash
# ==============================================================================
# SERVER TOOLS MODULE — CORE MAIN V1
# ==============================================================================

module_server_tools() {
    while true; do
        ui_draw_header
        ui_draw_box_start "SERVER TOOLS"
        echo -e "  ${GREEN}[1]${NC} VPS / Container Create (LXC)"
        echo -e "  ${GREEN}[2]${NC} SSHX.io Management"
        echo -e "  ${GREEN}[3]${NC} Cloudflared Tunnel"
        echo -e "  ${GREEN}[4]${NC} Docker Controller"
        echo -e "  ${GREEN}[5]${NC} Firewall Manager"
        echo -e "  ${GREEN}[0]${NC} Back"
        ui_draw_box_end

        read -rp "Select Option: " choice
        case "$choice" in
            1) tool_lxc_creator ;;
            2) tool_sshx ;;
            3) tool_cloudflared ;;
            4) tool_docker_menu ;;
            5) tool_firewall_menu ;;
            0) break ;;
            *) echo -e "${BADGE_ERR} Invalid Option"; sleep 1 ;;
        esac
    done
}

tool_lxc_creator() {
    ui_draw_header
    ui_draw_box_start "VPS / CONTAINER CREATOR"

    if ! command -v lxc-create >/dev/null 2>&1 && ! command -v lxc >/dev/null 2>&1; then
        echo -e "${BADGE_ERR} ${RED}LXC is NOT AVAILABLE on this server host.${NC}"
        echo -e "${GRAY}LXC tools (lxc/lxd) must be installed and virtualized natively on the host.${NC}"
        pause_prompt
        return
    fi

    local c_name c_ram c_cpu c_disk c_user c_pass
    read -rp "Container Name: " c_name
    read -rp "RAM Limit (e.g. 1024M): " c_ram
    read -rp "CPU Cores (e.g. 2): " c_cpu
    read -rp "Disk Size (e.g. 10G): " c_disk
    read -rp "Username: " c_user
    read -rsp "Password: " c_pass
    echo ""

    if [[ -z "$c_name" || -z "$c_user" || -z "$c_pass" ]]; then
        echo -e "${BADGE_ERR} Required fields missing."
        pause_prompt
        return
    fi

    echo -e "${BADGE_INFO} Provisioning LXC Container '$c_name'..."
    if command -v lxc >/dev/null 2>&1; then
        lxc launch images:ubuntu/22.04 "$c_name" >> "$LOG_FILE" 2>&1
        lxc config set "$c_name" limits.memory "$c_ram" >> "$LOG_FILE" 2>&1
        lxc config set "$c_name" limits.cpu "$c_cpu" >> "$LOG_FILE" 2>&1
        lxc exec "$c_name" -- useradd -m -s /bin/bash "$c_user" >> "$LOG_FILE" 2>&1
        echo "${c_user}:${c_pass}" | lxc exec "$c_name" -- chpasswd >> "$LOG_FILE" 2>&1
        
        local container_ip
        container_ip=$(lxc list "$c_name" -c 4 --format csv | awk '{print $1}')

        echo ""
        echo -e "${BADGE_OK} ${GREEN}Container Created${NC}\n"
        echo -e "Container: ${WHITE}${c_name}${NC}"
        echo -e "Username:  ${WHITE}${c_user}${NC}"
        echo -e "Password:  ${WHITE}********${NC}"
        echo -e "IP Address:${CYAN}${container_ip:-Fetching...}${NC}"
        echo -e "Access via: ${GREEN}lxc exec ${c_name} -- /bin/bash${NC}"
    else
        echo -e "${BADGE_ERR} Could not execute LXC provisioner."
    fi

    pause_prompt
}

tool_sshx() {
    ui_draw_header
    ui_draw_box_start "SSHX.IO BRIDGE TOOL"

    echo -e "${WHITE}SSHX allows lightweight collaborative web terminal sessions.${NC}\n"
    read -rp "Enter SSHX command/token (e.g. 'curl -sSF https://sshx.io/get | sh'): " sshx_cmd

    if [[ -z "$sshx_cmd" ]]; then
        echo -e "${BADGE_ERR} Command cannot be empty."
        pause_prompt
        return
    fi

    if confirm_action "Execute SSHX session command on this server?"; then
        echo -e "${BADGE_INFO} Running SSHX..."
        eval "$sshx_cmd"
    fi
    pause_prompt
}

tool_cloudflared() {
    ui_draw_header
    ui_draw_box_start "CLOUDFLARED TUNNEL CONNECTOR"

    if ! command -v cloudflared >/dev/null 2>&1; then
        echo -e "${BADGE_INFO} Installing cloudflared binary..."
        curl -L -o /usr/local/bin/cloudflared "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64" >> "$LOG_FILE" 2>&1
        chmod +x /usr/local/bin/cloudflared
    fi

    read -rp "Enter Cloudflare Tunnel Token: " cf_token

    if [[ -z "$cf_token" ]]; then
        echo -e "${BADGE_ERR} Token cannot be empty."
        pause_prompt
        return
    fi

    echo -e "${BADGE_INFO} Installing and starting Cloudflare Service..."
    cloudflared service install "$cf_token" >> "$LOG_FILE" 2>&1
    systemctl start cloudflared >> "$LOG_FILE" 2>&1

    if systemctl is-active --quiet cloudflared; then
        echo -e "${BADGE_OK} ${GREEN}Cloudflare Tunnel Connected and Running.${NC}"
    else
        echo -e "${BADGE_ERR} Cloudflare service failed to run."
    fi

    pause_prompt
}

tool_docker_menu() {
    while true; do
        ui_draw_header
        ui_draw_box_start "DOCKER CONTROLLER"
        
        echo -n "Status: "
        if systemctl is-active --quiet docker 2>/dev/null; then
            echo -e "${GREEN}ACTIVE / RUNNING${NC}"
        else
            echo -e "${RED}INACTIVE / NOT INSTALLED${NC}"
        fi
        echo ""

        echo -e "  ${GREEN}[1]${NC} Install Docker"
        echo -e "  ${GREEN}[2]${NC} Start Docker"
        echo -e "  ${GREEN}[3]${NC} Stop Docker"
        echo -e "  ${GREEN}[4]${NC} Restart Docker"
        echo -e "  ${GREEN}[0]${NC} Back"
        ui_draw_box_end

        read -rp "Select Option: " choice
        case "$choice" in
            1)
                curl -sSL https://get.docker.com/ | sh >> "$LOG_FILE" 2>&1
                systemctl enable --now docker >> "$LOG_FILE" 2>&1
                echo -e "${BADGE_OK} Docker installed."
                sleep 1
                ;;
            2) systemctl start docker; echo -e "${BADGE_OK} Docker started."; sleep 1 ;;
            3) systemctl stop docker; echo -e "${BADGE_OK} Docker stopped."; sleep 1 ;;
            4) systemctl restart docker; echo -e "${BADGE_OK} Docker restarted."; sleep 1 ;;
            0) break ;;
            *) echo -e "${BADGE_ERR} Invalid Option"; sleep 1 ;;
        esac
    done
}

tool_firewall_menu() {
    while true; do
        ui_draw_header
        ui_draw_box_start "FIREWALL CONTROLLER (UFW)"

        echo -n "Status: "
        if ufw status | grep -q "Status: active"; then
            echo -e "${GREEN}ACTIVE${NC}"
        else
            echo -e "${RED}INACTIVE / DISABLED${NC}"
        fi
        echo ""

        echo -e "  ${GREEN}[1]${NC} Enable Firewall"
        echo -e "  ${GREEN}[2]${NC} Disable Firewall (Warning)"
        echo -e "  ${GREEN}[3]${NC} Allow Port"
        echo -e "  ${GREEN}[4]${NC} Delete Port Rule"
        echo -e "  ${GREEN}[0]${NC} Back"
        ui_draw_box_end

        read -rp "Select Option: " choice
        case "$choice" in
            1)
                ufw --force enable >> "$LOG_FILE" 2>&1
                echo -e "${BADGE_OK} Firewall Enabled."
                sleep 1
                ;;
            2)
                if confirm_action "WARNING: Disabling firewall removes port protection!"; then
                    ufw disable >> "$LOG_FILE" 2>&1
                    echo -e "${BADGE_WARN} Firewall Disabled."
                fi
                sleep 1
                ;;
            3)
                read -rp "Enter Port to Allow (e.g. 80, 443, 22/tcp): " p_num
                ufw allow "$p_num" >> "$LOG_FILE" 2>&1
                echo -e "${BADGE_OK} Rule added."
                sleep 1
                ;;
            4)
                read -rp "Enter Port Rule to Delete (e.g. 80): " p_num
                ufw delete allow "$p_num" >> "$LOG_FILE" 2>&1
                echo -e "${BADGE_OK} Rule removed."
                sleep 1
                ;;
            0) break ;;
            *) echo -e "${BADGE_ERR} Invalid Option"; sleep 1 ;;
        esac
    done
}
