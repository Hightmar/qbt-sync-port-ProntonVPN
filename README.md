
# qBittorrent Port Sync with NAT-PMP

This project provides two Bash scripts to automatically synchronize the listening port of qBittorrent with the port assigned via NAT-PMP, and optionally send Discord notifications.

## Overview

- `qbt-port-sync.sh`: Checks every 5 minutes for a new NAT-PMP mapped port and updates the qBittorrent listening port via its Web API.
- `notif-discord.sh`: (Optional) Sends a notification to a Discord webhook when the port is successfully updated or if an error occurs.

## Prerequisites

1. Install `natpmpc` (NAT-PMP client).
2. Ensure `curl` is installed and available.
3. Set the following environment variables in `qbt-port-sync.sh` with your own values:

```bash
VPN_GATEWAY="10.2.0.1"
QBIT_HOST="localhost"
QBIT_PORT="8080"
QBIT_USER="MyUser"
QBIT_PASS="MyPassword"
```

4. If using Discord notifications, set the `WEBHOOK_URL` in `notif-discord.sh`:

```bash
WEBHOOK_URL="https://discord.com/api/webhooks/[...]"
```


## Usage

1. Make both scripts executable:

```bash
chmod +x qbt-port-sync.sh notif-discord.sh
```

2. (Optional) Uncomment the line in `qbt-port-sync.sh` to enable Discord notifications:

```bash
# ./notif-discord.sh "$mapped_port"
```

3. Run `qbt-port-sync.sh` in the background or as a service:

```bash
./qbt-port-sync.sh &
```

### Running as a systemd service (optional)

You can run the sync script using `systemd` for automatic startup and recovery.

Create a file `/etc/systemd/system/qbt-port-sync.service` with the following content:

```ini
[Unit]
Description=Sync qBittorrent port with ProtonVPN NAT-PMP
After=network-online.target

[Service]
Type=simple
ExecStart=/path/to/file/qbt-sync-port-ProntonVPN/qbt-port-sync.sh
WorkingDirectory=/path/to/folder/qbt-sync-port-ProntonVPN
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

> ⚠️ Make sure to update the `ExecStart` and `WorkingDirectory` paths with the correct locations of your script.

Then reload the systemd daemon and enable the service:

```bash
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now qbt-port-sync.service
```


## Logging

A log file `qbt-port-sync.log` will be created in the same directory as the script, tracking port updates and any errors encountered.

---

Feel free to modify and adapt the script for your own NAT-PMP + VPN + qBittorrent setup.
