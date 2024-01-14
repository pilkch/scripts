#!/bin/bash -xe

function vaultwarden_backup {
  # The vaultwarden backup process is more complicated because there is no web API for backing up the vaultwarden data
  # 1. Create the backup as the vaultwarden user
  sudo cp "$PWD/vaultwarden-backup.sh" /home/vaultwarden/
  sudo chown vaultwarden:vaultwarden /home/vaultwarden/vaultwarden-backup.sh
  sudo -u vaultwarden /home/vaultwarden/vaultwarden-backup.sh

  # 2. Copy the backup to the regular users' backup location
  VAULTWARDEN_BACKUP_FOLDER="$HOME/backups/$DATE/vaultwarden"
  rm -rf "$VAULTWARDEN_BACKUP_FOLDER"
  mkdir -p "$VAULTWARDEN_BACKUP_FOLDER"
  sudo cp "/home/vaultwarden/backups/${DATE}/vaultwarden/vaultwarden${DATE}.tar.gz.gpg" "$VAULTWARDEN_BACKUP_FOLDER/"
  sudo chown $USER:$USER "$VAULTWARDEN_BACKUP_FOLDER/vaultwarden${DATE}.tar.gz.gpg"
}


DATE=$(date '+%Y%m%d')

# Create our backups
./github-backup.sh
./gitlab-backup.sh
./homeassistant-backup.sh

# Create our vaultwarden backup
vaultwarden_backup

# The backups have been created, so move them to the samba share
mkdir -p "/data/backups/"
mv "$HOME/backups/$DATE" "/data/backups/$DATE"
