#!/usr/bin/env bash
# ==============================================================================
# PTERODACTYL PANEL INSTALLER MODULE — CORE MAIN V1
# ==============================================================================

module_panel_installer() {
    ui_draw_header
    ui_draw_box_start "PANEL INSTALLER WIZARD"

    echo -e "${WHITE}This wizard will set up Pterodactyl Panel on this server.${NC}\n"

    # Input gathering
    local admin_email admin_user admin_name admin_pass admin_pass_confirm fqdn

    while true; do
        read -rp "Enter Panel Domain / IP (e.g., panel.domain.com): " fqdn
        if validate_domain_or_ip "$fqdn"; then break; fi
        echo -e "${BADGE_ERR} Invalid FQDN or IP. Try again."
    done

    while true; do
        read -rp "Admin Email: " admin_email
        if validate_email "$admin_email"; then break; fi
        echo -e "${BADGE_ERR} Invalid email format. Try again."
    done

    read -rp "Admin Display Name: " admin_name
    read -rp "Admin Username: " admin_user

    while true; do
        read -rsp "Admin Password: " admin_pass
        echo ""
        read -rsp "Confirm Admin Password: " admin_pass_confirm
        echo ""
        if [[ -n "$admin_pass" && "$admin_pass" == "$admin_pass_confirm" ]]; then
            break
        fi
        echo -e "${BADGE_ERR} Passwords do not match or are empty. Try again."
    done

    echo ""
    if ! confirm_action "Proceed with Pterodactyl Panel Installation?"; then
        return
    fi

    echo ""
    ui_print_step "1" "10" "Checking system & dependencies..."
    run_quiet "apt-get update -y"
    run_quiet "apt-get install -y software-properties-common curl apt-transport-https ca-certificates gnupg lsb-release tar unzip git ufw"

    ui_print_step "2" "10" "Adding PHP & MariaDB repositories..."
    run_quiet "add-apt-repository -y ppa:ondrej/php"
    run_quiet "apt-get update -y"

    ui_print_step "3" "10" "Installing MariaDB, Nginx, Redis & PHP 8.2..."
    run_quiet "apt-get install -y mariadb-server nginx redis-server php8.2 php8.2-cli php8.2-gd php8.2-mysql php8.2-pdo php8.2-mbstring php8.2-tokenizer php8.2-xml php8.2-curl php8.2-zip php8.2-bcmath"

    ui_print_step "4" "10" "Installing Composer..."
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer >> "$LOG_FILE" 2>&1

    ui_print_step "5" "10" "Setting up Database & Credentials..."
    local db_pass
    db_pass=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS panel;"
    mysql -u root -e "CREATE USER IF NOT EXISTS 'pterouser'@'127.0.0.1' IDENTIFIED BY '${db_pass}';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON panel.* TO 'pterouser'@'127.0.0.1' WITH GRANT OPTION;"
    mysql -u root -e "FLUSH PRIVILEGES;"

    ui_print_step "6" "10" "Downloading Pterodactyl Panel files..."
    mkdir -p /var/www/pterodactyl
    cd /var/www/pterodactyl || return
    curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz >> "$LOG_FILE" 2>&1
    tar -xzvf panel.tar.gz >> "$LOG_FILE" 2>&1
    chmod -R 755 storage bootstrap/cache

    ui_print_step "7" "10" "Configuring Environment & Application Key..."
    cp .env.example .env
    COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader --no-interaction >> "$LOG_FILE" 2>&1
    php artisan key:generate --force --no-interaction >> "$LOG_FILE" 2>&1

    # Database setup in environment
    php artisan ptero:env --no-interaction \
        --dbhost="127.0.0.1" \
        --dbport="3306" \
        --dbname="panel" \
        --dbuser="pterouser" \
        --dbpass="${db_pass}" \
        --url="http://${fqdn}" \
        --timezone="UTC" \
        --telemetry="false" >> "$LOG_FILE" 2>&1

    php artisan migrate --seed --force --no-interaction >> "$LOG_FILE" 2>&1

    ui_print_step "8" "10" "Creating Initial Admin User..."
    php artisan ptero:user --no-interaction \
        --email="${admin_email}" \
        --username="${admin_user}" \
        --firstname="${admin_name}" \
        --lastname="Admin" \
        --password="${admin_pass}" \
        --admin=1 >> "$LOG_FILE" 2>&1

    ui_print_step "9" "10" "Configuring Cron, Queue Workers & Permissions..."
    chown -R www-data:www-data /var/www/pterodactyl/*
    (crontab -l 2>/dev/null; echo "* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1") | crontab -

    cat <<EOF > /etc/systemd/system/pteroq.service
[Unit]
Description=Pterodactyl Queue Worker
After=redis-server.service

[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/pterodactyl/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3
StartLimitInterval=180
StartLimitBurst=30

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload >> "$LOG_FILE" 2>&1
    systemctl enable --now pteroq.service redis-server mariadb nginx >> "$LOG_FILE" 2>&1

    ui_print_step "10" "10" "Configuring Web Server (Nginx)..."
    cat <<EOF > /etc/nginx/sites-available/pterodactyl.conf
server {
    listen 80;
    server_name ${fqdn};
    root /var/www/pterodactyl/public;
    index index.html index.htm index.php;
    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/pterodactyl.app-error.log error;

    client_max_body_size 100M;
    client_body_buffer_size 128k;

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF
    ln -sf /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    systemctl restart nginx >> "$LOG_FILE" 2>&1

    echo ""
    echo -e "${BADGE_OK} ${GREEN}Panel Installation Complete${NC}"
    echo -e "${BADGE_OK} ${GREEN}Configuration Complete${NC}"
    echo -e "${BADGE_OK} ${GREEN}Web Server Ready${NC}\n"
    echo -e "Panel URL:      ${CYAN}http://${fqdn}${NC}"
    echo -e "Admin Username: ${WHITE}${admin_user}${NC}"
    echo -e "${GRAY}(Note: You can secure SSL later using Certbot for your domain.)${NC}"

    pause_prompt
}
