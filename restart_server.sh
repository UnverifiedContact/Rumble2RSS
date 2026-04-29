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

stop_server() {
    if is_running; then
        echo "Stopping existing Rumble2RSS process..."
        pkill -f "$R2R_MATCH"
        sleep 2
        
        # Force kill if still running
        if is_running; then
            echo "Force stopping Rumble2RSS process..."
            pkill -9 -f "$R2R_MATCH"
            sleep 1
        fi
    else
        echo "No Rumble2RSS process running"
    fi
}

start_server() {
    echo "Starting Rumble2RSS..."
    nohup "$R2R_PYTHON" "$R2R_SCRIPT" >>"$R2R_LOG" 2>&1 &
}

echo "Restarting Rumble2RSS server..."
stop_server
start_server
sleep 2

if ! is_running; then
    echo "Error: Failed to restart Rumble2RSS. Check ${R2R_LOG} for details."
    exit 1
fi

if is_healthy; then
    echo "Rumble2RSS restarted successfully and is healthy on port ${R2R_PORT}"
else
    echo "Warning: Rumble2RSS restarted but health check failed. Check ${R2R_LOG} for details."
    exit 1
fi
