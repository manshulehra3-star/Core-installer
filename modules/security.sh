#!/usr/bin/env bash
# ==============================================================================
# SECURITY MANAGER MODULE — CORE MAIN V1
# ==============================================================================

module_security_manager() {
    ui_draw_header
    ui_draw_box_start "SECURITY AUDIT & MANAGER"

    echo -e "${BOLD}${WHITE}RUNNING SYSTEM SECURITY AUDIT...${NC}\n"

    # 1. SSH Security Check
    echo -n "1. SSH Root Login: "
    if grep -E -q "^PermitRootLogin[[:space:]]+yes" /etc/ssh/sshd_config 2>/dev/null; then
        echo -e "${YELLOW}[ENABLED] - Recommend key-based auth or disabling direct root log-in.${NC}"
    else
        echo -e "${GREEN}[HARDENED / SECURE]${NC}"
    fi

    # 2. Firewall Check
    echo -n "2. Firewall Protection: "
    if ufw status 2>/dev/null | grep -q "Status: active"; then
        echo -e "${GREEN}[ACTIVE]${NC}"
    else
        echo -e "${RED}[INACTIVE] - Recommend enabling UFW.${NC}"
    fi

    # 3. Fail2Ban Check
    echo -n "3. Fail2Ban Intrusion Prevention: "
    if systemctl is-active --quiet fail2ban 2>/dev/null; then
        echo -e "${GREEN}[RUNNING]${NC}"
    else
        echo -e "${YELLOW}[NOT ACTIVE / NOT INSTALLED]${NC}"
    fi

    # 4. Open Ports Inspection
    echo ""
    echo -e "${BOLD}${WHITE}4. Open Public Listening Ports:${NC}"
    if command -v ss >/dev/null 2>&1; then
        ss -tuln | awk 'NR>1 {print "   - " $1 " " $5}' | head -n 8
    else
        netstat -tuln | awk 'NR>2 {print "   - " $1 " " $4}' | head -n 8
    fi

    echo ""
    echo -e "${GREEN}──────────────────────────────────────────────────────${NC}"
    echo -e "  ${GREEN}[1]${NC} Install Fail2Ban"
    echo -e "  ${GREEN}[2]${NC} Secure SSH Config (Disable Password Auth)"
    echo -e "  ${GREEN}[0]${NC} Back"

    read -rp "Select Option: " sec_choice
    case "$sec_choice" in
        1)
            apt-get update -y >> "$LOG_FILE" 2>&1
            apt-get install -y fail2ban >> "$LOG_FILE" 2>&1
            systemctl enable --now fail2ban >> "$LOG_FILE" 2>&1
            echo -e "${BADGE_OK} Fail2Ban installed and running."
            pause_prompt
            ;;
        2)
            if confirm_action "Disable SSH password authentication? Ensure SSH keys are configured!"; then
                sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
                systemctl restart sshd >> "$LOG_FILE" 2>&1
                echo -e "${BADGE_OK} SSH Password Auth disabled."
            fi
            pause_prompt
            ;;
        0) return ;;
    esac
}
