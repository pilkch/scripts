#!/bin/bash -xe

DATE=$(date '+%Y%m%d')

TYPE="$1"
if [ "$TYPE" = "manual" ]; then
  # Manually called by the user, requires the user to enter the sudo password for each backup

  # Create our vaultwarden backup
  (cd vaultwarden-backup && ./vaultwarden-backup.sh)

  # Create our tandoor backup
  (cd tandoor-backup && ./tandoor-backup.sh)
else
  # Automated backups from a systemd service

  # Create our backups
  ./github-backup.sh
  ./gitlab-backup.sh

  # Create our homeassistant backup
  (cd homeassistant-backup && ./homeassistant-backup.sh)
fi

# The backups have been created, so move them to the samba share
SAMBA_SHARE_BACKUPS=/data/backups
mkdir -p "$SAMBA_SHARE_BACKUPS"
mv "$HOME/backups/$DATE" "$SAMBA_SHARE_BACKUPS/servers-backup$DATE"
