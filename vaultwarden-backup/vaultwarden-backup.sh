#!/bin/bash -xe

# Usage:
# (cd vaultwarden-backup && ./vaultwarden-backup.sh)

# The vaultwarden backup process is more complicated than the other services because there is no web API for backing up the vaultwarden data
# 1. Create the backup as the vaultwarden user by copying the backup script to the vault warden user folder and running it as the vaultwarden user
sudo cp "$PWD/user-vaultwarden-backup.sh" /home/vaultwarden/
sudo chown vaultwarden:vaultwarden /home/vaultwarden/user-vaultwarden-backup.sh
sudo -u vaultwarden /home/vaultwarden/user-vaultwarden-backup.sh
sudo rm -f /home/vaultwarden/user-vaultwarden-backup.sh

# 2. Copy the backup to the regular users' backup location
DATE=$(date '+%Y%m%d')
VAULTWARDEN_BACKUP_FOLDER="$HOME/backups/$DATE"
mkdir -p "$VAULTWARDEN_BACKUP_FOLDER"
sudo cp "/home/vaultwarden/backups/${DATE}/vaultwarden/vaultwarden${DATE}.tar.gz.gpg" "$VAULTWARDEN_BACKUP_FOLDER/"
sudo chown "$USER":"$USER" "$VAULTWARDEN_BACKUP_FOLDER/vaultwarden${DATE}.tar.gz.gpg"
