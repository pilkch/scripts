#!/bin/bash -xe

# NOTE: This is aimed at backing up the configuration and user data from a Tandoor container running under the tandoor user
# https://docs.tandoor.dev/system/backup/

# Usage:
# Check tandoor-backup.sh for the usage of this script

DATE="$1"

# Create our backup folder
BACKUP_FOLDER="$HOME/backups/$DATE/tandoor"
rm -rf "$BACKUP_FOLDER"
mkdir -p "$BACKUP_FOLDER"
cd "$BACKUP_FOLDER"

TANDOOR_FOLDER="$HOME/srv/tandoor"

BACKUP_FILE_DB="$BACKUP_FOLDER/pgdump.sql"
BACKUP_FILE_ARCHIVE="$BACKUP_FOLDER/tandoor${DATE}.tar.gz"

# Backup the sqlite database
if podman exec -t tandoor_db_recipes_1 pg_dumpall -U djangouser > $BACKUP_FILE_DB ; then
  echo "Wrote sql backup file to $BACKUP_FILE_DB"
else
  echo "Backup of the database failed"
  exit 1
fi

# Tar everything
if /bin/tar -czf $BACKUP_FILE_ARCHIVE -C "$TANDOOR_FOLDER" mediafiles staticfiles -C "$BACKUP_FOLDER" pgdump.sql ; then
  echo " Successfully created archive backup $BACKUP_FILE_ARCHIVE"
else
  echo "Encrypted backup failed!"
  exit 1
fi

# Delete the sqlite database backup file
rm -rf "$BACKUP_FILE_DB"
