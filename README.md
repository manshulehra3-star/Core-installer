# CORE MAIN V1 — INFINITE CORE CONTROL TOOLKIT

A modular, production-ready Linux terminal management and installation suite designed for modern VPS and dedicated servers running Ubuntu/Debian. Built for high reliability, clear UI execution, and seamless mobile SSH/Termius usage.

## Features
- **Dynamic Header Bar**: Real-time stats (CPU, RAM, Disk, LXC/KVM availability, and live clock).
- **Pterodactyl Panel Installer**: Automated dependency installation, DB setup, Nginx configuration, cron/queue creation, and admin account setup.
- **Pterodactyl Wings Installer**: Automated Wings installation, config token applier, health checks, and non-destructive removal.
- **Server Tools**: LXC Container Manager, SSHX.io session bridge, Cloudflare Tunnel connector, Docker lifecycle management, and UFW Firewall controller.
- **Security Manager**: Comprehensive audit for SSH settings, open ports, Fail2Ban setup, and permissions.
- **System Manager**: Deep hardware detection, multi-interface IP reporting, safe package updates, dependency repair, log viewer, backup utility, and double-confirmed VPS resets.

## Quick Start

```bash
git clone [https://github.com/infinite-core/core-main-v1.git](https://github.com/infinite-core/core-main-v1.git)
cd core-main-v1
chmod +x install.sh
sudo bash install.sh
