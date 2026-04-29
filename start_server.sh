#!/usr/bin/env bash

R2R_DIR="${R2R_DIR:-$HOME/personal_scripts/Rumble2RSS}"
R2R_SCRIPT="${R2R_SCRIPT:-$R2R_DIR/rumble2rss.py}"
R2R_PORT="${R2R_PORT:-8555}"
R2R_HEALTH_PATH="${R2R_HEALTH_PATH:-/hello}"
R2R_LOG="${R2R_LOG:-$R2R_DIR/log}"
R2R_PYTHON="${R2R_PYTHON:-$R2R_DIR/venv/bin/python}"
R2R_MATCH="${R2R_MATCH:-rumble2rss.py}"

is_healthy() {
    curl -fsS "http://localhost:${R2R_PORT}${R2R_HEALTH_PATH}" >/dev/null 2>&1
}

is_running() {
    pgrep -f "$R2R_MATCH" >/dev/null 2>&1
}

start_server() {
    nohup "$R2R_PYTHON" "$R2R_SCRIPT" >>"$R2R_LOG" 2>&1 &
}

if is_healthy; then
    echo "Rumble2RSS is already healthy on port ${R2R_PORT}"
    exit 0
fi

if is_running; then
    echo "Rumble2RSS process already running"
    exit 0
fi

start_server
sleep 1

if ! is_running; then
    echo "Warning: Failed to start Rumble2RSS. Check ${R2R_LOG} for details."
    exit 1
fi

echo "Rumble2RSS started successfully"

