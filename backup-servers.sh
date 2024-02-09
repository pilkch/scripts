#!/bin/bash -xe

DATE=$(date '+%Y%m%d')

# Create our backups
./github-backup.sh
./gitlab-backup.sh

# Create our homeassistant backup
(cd homeassistant-backup && ./homeassistant-backup.sh)

# Create our vaultwarden backup
# NOTE: This requires sudo so we can't call it if we are called from a systemd service file
#(cd vaultwarden-backup && ./vaultwarden-backup.sh)

# The backups have been created, so move them to the samba share
SAMBA_SHARE_BACKUPS=/data/backups
mkdir -p "$SAMBA_SHARE_BACKUPS"
mv "$HOME/backups/$DATE" "$SAMBA_SHARE_BACKUPS/servers-backup$DATE"
