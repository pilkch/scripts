#!/bin/bash -xe

# Usage:
# (cd tandoor-backup && ./tandoor-backup.sh)

DATE=$(date '+%Y%m%d')

# Copy the scripts to the ansible user on homeassistant (I run tandoor on my Home Assistant NUC which is basically my "untrusted" server on the wifi VLAN)
scp ./user-ansible-backup.sh ./user-tandoor-backup.sh ansible@homeassistant.network.home:/home/ansible/

# Run the next stage of the backup
ssh ansible@homeassistant.network.home -t "./user-ansible-backup.sh $DATE"

TANDOOR_BACKUP_FILE_ARCHIVE_GPG="/home/ansible/tandoor${DATE}.tar.gz.gpg"

# Copy the backup back to the calling server
TANDOOR_BACKUP_FOLDER="$HOME/backups/$DATE"
mkdir -p "$TANDOOR_BACKUP_FOLDER"
scp ansible@homeassistant.network.home:$TANDOOR_BACKUP_FILE_ARCHIVE_GPG "$TANDOOR_BACKUP_FOLDER/"

# Clean up
ssh ansible@homeassistant.network.home -t "sudo rm -f /home/ansible/user-ansible-backup.sh $TANDOOR_BACKUP_FILE_ARCHIVE_GPG"
