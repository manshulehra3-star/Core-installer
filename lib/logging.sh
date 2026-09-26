#!/usr/bin/env bash
# ==============================================================================
# LOGGING LIBRARY — CORE MAIN V1
# ==============================================================================

LOG_DIR="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")/logs"
mkdir -p "$LOG_DIR"
export LOG_FILE="$LOG_DIR/core_installer_$(date +%Y%m%d).log"

log_info() {
    echo "[INFO] [$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log_warn() {
    echo "[WARN] [$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log_error() {
    echo "[ERROR] [$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Scrub sensitive patterns (passwords, tokens, keys) before logging
log_scrubbed() {
    local raw_message="$1"
    local sanitized
    sanitized=$(echo "$raw_message" | sed -E 's/(password|token|secret|key|app_key)=[^ &]+/ \1=***REDACTED***/gi')
    echo "[EXEC] [$(date '+%Y-%m-%d %H:%M:%S')] $sanitized" >> "$LOG_FILE"
}
