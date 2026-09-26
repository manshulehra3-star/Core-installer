#!/usr/bin/env bash
# ==============================================================================
# PTERODACTYL WINGS MODULE — CORE MAIN V1
# ==============================================================================

module_wings_installer() {
    while true; do
        ui_draw_header
        ui_draw_box_start "WINGS INSTALLER"
        echo -e "  ${GREEN}[1]${NC} Install Wings"
        echo -e "  ${GREEN}[2]${NC} Uninstall Wings"
        echo -e "  ${GREEN}[3]${NC} Node Health"
        echo -e "  ${GREEN}[0]${NC} Back"
        ui_draw_box_end

        read -rp "Select Option: " choice
        case "$choice" in
            1) install_wings_sub ;;
            2) uninstall_wings_sub ;;
            3) node_health_sub ;;
            0) break ;;
            *) echo -e "${BADGE_ERR} Invalid Option"; sleep 1 ;;
        esac
    done
}

install_wings_sub() {
    ui_draw_header
    ui_draw_box_start "INSTALL PTERODACTYL WINGS"

    local panel_url wings_config wings_port sftp_port="2022"

    read -rp "Panel URL (e.g., https://panel.domain.com): " panel_url
    echo -e "${YELLOW}Paste the Wings Configuration Token / YAML block from Panel below.${NC}"
    echo -e "${GRAY}(Press ENTER after pasting, then press Ctrl+D if EOF, or paste inline content):${NC}"
    
    read -rp "Wings Configuration Content/Token: " wings_config
    read -rp "Wings Port [8080]: " wings_port
    wings_port=${wings_port:-8080}

    if [[ -z "$wings_config" ]]; then
        echo -e "${BADGE_ERR} Configuration token cannot be empty."
        pause_prompt
        return
    fi

    echo ""
    ui_print_step "1" "5" "Checking & Installing Docker..."
    if ! command -v docker >/dev/null 2>&1; then
        curl -sSL https://get.docker.com/ | sh >> "$LOG_FILE" 2>&1
        systemctl enable --now docker >> "$LOG_FILE" 2>&1
    fi

    ui_print_step "2" "5" "Installing Wings Binary..."
    mkdir -p /etc/pterodactyl /var/log/pterodactyl
    curl -L -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64" >> "$LOG_FILE" 2>&1
    chmod +x /usr/local/bin/wings

    ui_print_step "3" "5" "Applying configuration..."
    if [[ "$wings_config" =~ ^\{.*\} ]]; then
        echo "$wings_config" > /etc/pterodactyl/config.yml
    else
        # If passed raw YAML text or block
        echo "$wings_config" > /etc/pterodactyl/config.yml
    fi

    ui_print_step "4" "5" "Configuring Service & Starting Wings..."
    cat <<EOF > /etc/systemd/system/wings.service
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service
PartOf=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
LimitNOFILE=1048576
LimitNPROC=524288
LimitCORE=infinity
ExecStart=/usr/local/bin/wings
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload >> "$LOG_FILE" 2>&1
    systemctl enable --now wings >> "$LOG_FILE" 2>&1

    ui_print_step "5" "5" "Checking Node Status..."
    sleep 2

    echo ""
    if systemctl is-active --quiet wings; then
        echo -e "${BADGE_OK} ${GREEN}Wings Installed${NC}"
        echo -e "${BADGE_OK} ${GREEN}Docker Connected${NC}"
        echo -e "${BADGE_OK} ${GREEN}Configuration Applied${NC}"
        echo -e "${BADGE_OK} ${GREEN}Wings Service Running${NC}\n"
        echo -e "Node Status: ${GREEN}ONLINE${NC}"
        echo -e "SFTP Port:   ${WHITE}${sftp_port}${NC}"
        echo -e "Daemon Port: ${WHITE}${wings_port}${NC}"
    else
        echo -e "${BADGE_ERR} ${RED}Wings service failed to start. Check logs in /var/log/pterodactyl or systemctl status wings.${NC}"
    fi

    pause_prompt
}

uninstall_wings_sub() {
    ui_draw_header
    ui_draw_box_start "UNINSTALL WINGS"

    if ! confirm_action "WARNING: This will safely remove Pterodactyl Wings daemon. Docker containers will remain intact."; then
        return
    fi

    echo -e "${BADGE_INFO} Stopping Wings Service..."
    systemctl stop wings >> "$LOG_FILE" 2>&1
    systemctl disable wings >> "$LOG_FILE" 2>&1

    echo -e "${BADGE_INFO} Removing Wings files & systemd configuration..."
    rm -f /etc/systemd/system/wings.service
    rm -f /usr/local/bin/wings
    systemctl daemon-reload >> "$LOG_FILE" 2>&1

    echo -e "${BADGE_OK} ${GREEN}Wings successfully uninstalled.${NC}"
    pause_prompt
}

node_health_sub() {
    ui_draw_header
    ui_draw_box_start "NODE HEALTH DIAGNOSTICS"

    echo -n "Wings Daemon Service: "
    if systemctl is-active --quiet wings; then
        echo -e "${GREEN}[RUNNING]${NC}"
    else
        echo -e "${RED}[STOPPED / NOT INSTALLED]${NC}"
    fi

    echo -n "Docker Daemon Service: "
    if systemctl is-active --quiet docker; then
        echo -e "${GREEN}[RUNNING]${NC}"
    else
        echo -e "${RED}[OFFLINE]${NC}"
    fi

    echo -n "Wings Config File:     "
    if [[ -f /etc/pterodactyl/config.yml ]]; then
        echo -e "${GREEN}[PRESENT]${NC}"
    else
        echo -e "${RED}[MISSING]${NC}"
    fi

    echo -n "Listening Ports (2022): "
    if netstat -tuln 2>/dev/null | grep -q ":2022 " || ss -tuln 2>/dev/null | grep -q ":2022 "; then
        echo -e "${GREEN}[LISTENING]${NC}"
    else
        echo -e "${YELLOW}[NOT DETECTED]${NC}"
    fi

    pause_prompt
}
