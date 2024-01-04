#!/bin/bash -xe

# Create our backups
./github-backup.sh
./gitlab-backup.sh
./homeassistant-backup.sh
./vaultwarden-backup.sh

# Copy the backups to the samba share
DATE=$(date '+%Y%m%d')
mv "backups/$DATE" "/data/backups/$DATE"
