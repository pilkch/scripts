#!/bin/bash -xe

# NOTE: We call homeassistant-websocket-api-helper to create the actual backup, then GPG encrypt it

# homeassistant-websocket-api-helper
# https://github.com/pilkch/homeassistant-websocket-api-helper

# GPG encrypting files
# https://www.redhat.com/sysadmin/encryption-decryption-gpg

# Usage:
# 1. Build homeassistant-websocket-api-helper and copy it to the homeassistant-backup/ folder
# 2. Copy the configuration.json.example to the homeassistant-backup/ folder and update the api_token, host_name, and port fields
# 3. Optionally, copy the self-signed certificate to the homeassistant-backup/ folder and update the path in the self_signed_certificate field
# 4. Set HOMEASSISTANT_GPG_PASSWORD in the script below to a unique randomly generated password
# 5. Run ./homeassistant-backup.sh
#
# A file something like this will be created:
# $HOME/backups/$DATE/homeassistant/homeassistant${DATE}.tar.gpg
#
# Decrypting later (You will be prompted for the password used to encrypt it earlier)
# gpg --output homeassistant20240114.tar --decrypt homeassistant20240114.tar.gpg

HOMEASSISTANT_GPG_PASSWORD=<PUT A LONG RANDOMLY GENERATED PASSWORD HERE>

# Remove any existing backups
rm -rf ./backup*.*.tar

# Create our backup folder
DATE=$(date '+%Y%m%d')
BACKUP_FOLDER="$HOME/backups/$DATE/homeassistant"
rm -rf "$BACKUP_FOLDER"
mkdir -p "$BACKUP_FOLDER"

# Create a HomeAssistant backup with the homeassistant-websocket-api-helper
if !  ./homeassistant-websocket-api-helper --create-and-download-backup ; then
  echo "Calling homeassistant-websocket-api-helper has failed"
  exit 1
fi

# Check if the backup file was created
if [ ! ls ./backup$DATE.*.tar 1> /dev/null 2>&1 ] ; then
  echo "Backup file not found ./backup$DATE.*.tar"
  exit 1
fi

BACKUP_FILE_ARCHIVE=$(ls backup$DATE.*.tar)
BACKUP_FILE_ARCHIVE_GPG="$BACKUP_FOLDER/homeassistant${DATE}.tar.gpg"

# GPG encrypt the tar file
if cat "$BACKUP_FILE_ARCHIVE" | gpg --batch --no-options --no-tty --yes --symmetric \
    --passphrase "$HOMEASSISTANT_GPG_PASSWORD" --cipher-algo AES256 -o "$BACKUP_FILE_ARCHIVE_GPG"; then
  echo "Failed to encrypt the backup file"
  exit 1
fi

# Check if the GPG encrypted file was created
if [ ! -f "$BACKUP_FILE_ARCHIVE_GPG" ]; then
  echo "Backup file not found $BACKUP_FILE_ARCHIVE_GPG"
  exit 1
fi

# Delete the unencrypted backup file
rm -rf "$BACKUP_FILE_ARCHIVE"
