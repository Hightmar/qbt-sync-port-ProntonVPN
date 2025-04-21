#!/bin/bash

VPN_GATEWAY="10.2.0.1"
QBIT_HOST="localhost"
QBIT_PORT="8080"
QBIT_USER="MyUser"
QBIT_PASS="MyPassword"

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
LOG_FILE="$SCRIPT_DIR/qbt-port-sync.log"
last_port=""

log() {
    local message
    message="$(date '+%Y-%m-%d %H:%M:%S') - $1"
    echo "$message"
    echo "$message" >> "$LOG_FILE"
}

while true; do
    output=$(natpmpc -a 1 0 udp 300 -g "$VPN_GATEWAY" && natpmpc -a 1 0 tcp 300 -g "$VPN_GATEWAY")

    # Extract mapped port (UDP + TCP)
    mapfile -t ports < <(grep "Mapped public port" <<< "$output" | grep -oP 'port \K[0-9]{5}')

    if [[ ${#ports[@]} -eq 2 && "${ports[0]}" == "${ports[1]}" ]]; then
        mapped_port="${ports[0]}"

        if [[ "$mapped_port" != "$last_port" ]]; then
            log "New port detected : $mapped_port"
            last_port="$mapped_port"

            # Authentification qBittorrent
            cookie=$(curl -s -i --data "username=$QBIT_USER&password=$QBIT_PASS" \
                http://$QBIT_HOST:$QBIT_PORT/api/v2/auth/login \
                | grep -Fi set-cookie | cut -d' ' -f2 | tr -d '\r\n')

            if [[ -n "$cookie" ]]; then
                curl -s --cookie "$cookie" "http://$QBIT_HOST:$QBIT_PORT/api/v2/app/setPreferences" \
                    --data-urlencode "json={\"listen_port\":$mapped_port}"
                log "Port qBittorrent updated : $mapped_port"
                #./notif-discord.sh "$mapped_port"
            else
                log "Error: Authentication to qBittorrent API failed"
                #./notif-discord.sh fail
            fi
        fi
    else
        log "Error: ports incoherent or not detected."
    fi

    sleep 300
done