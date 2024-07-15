#!/bin/bash -xe

# NOTE: This is aimed at backing up the configuration and user data from a vaultwarden container running under the vaultwarden user
# It is very lazy, just tarring and gpg encrypting the whole vaultwarden data directory
# We really only need a few of these directories and folders, but it is just as much effort to backup the whole thing
# https://github-wiki-see.page/m/dani-garcia/vaultwarden/wiki/Backing-up-your-vault
# https://dizzytech.de/posts/backing_up_vaultwarden/

# GPG encrypting files
# https://www.redhat.com/sysadmin/encryption-decryption-gpg

# Usage:
# Check vaultwarden-backup.sh for the usage of this script
#
# Decrypting later (You will be prompted for the password used to encrypt it earlier)
# gpg --output vaultwarden20240114.tar.gz --decrypt vaultwarden20240114.tar.gz.gpg

VAULTWARDEN_GPG_PASSWORD=<PUT A LONG RANDOMLY GENERATED PASSWORD HERE>

# Create our backup folder
DATE=$(date '+%Y%m%d')
BACKUP_FOLDER="$HOME/backups/$DATE/vaultwarden"
rm -rf "$BACKUP_FOLDER"
mkdir -p "$BACKUP_FOLDER"
cd "$BACKUP_FOLDER"

VAULTWARDEN_DATA_FOLDER="$HOME/srv/vaultwarden/data"
VAULTWARDEN_SQLITE_DATABASE_FILE="$VAULTWARDEN_DATA_FOLDER/db.sqlite3"

BACKUP_FILE_DB="$BACKUP_FOLDER/db.sqlite3"
BACKUP_FILE_ARCHIVE_GPG="$BACKUP_FOLDER/vaultwarden${DATE}.tar.gz.gpg"

# Backup the sqlite database
if /usr/bin/sqlite3 "$VAULTWARDEN_SQLITE_DATABASE_FILE" ".backup '$BACKUP_FILE_DB'"; then
  echo "Written temporary backup file to $BACKUP_FILE_DB"
else
  echo "Backup of the database failed"
  exit 1
fi

# TODO: This is kind of terrible but works
ALL_DATA_FILES=$(cd $VAULTWARDEN_DATA_FOLDER && ls)
DATA_FILES=""
for f in $ALL_DATA_FILES
do
  # Add all the file names that don't begin with "db.sqlite3" (Possible files might include db.sqlite3, db.sqlite3-shm, and db.sqlite3-wal)
  if [[ "$f" != db.sqlite3* ]]; then
    DATA_FILES="$DATA_FILES $f"
  fi
done

# Tar everything and GPG encrypt it
# NOTE: We add the vaultwarden data files except for db.sqlite3* files, then add back in our backed up db.sqlite3 file
if eval /bin/tar -cz -C "$VAULTWARDEN_DATA_FOLDER" $DATA_FILES -C "$BACKUP_FOLDER" db.sqlite3 | gpg --batch --no-options --no-tty --yes --symmetric \
    --passphrase "$VAULTWARDEN_GPG_PASSWORD" --cipher-algo AES256 -o "$BACKUP_FILE_ARCHIVE_GPG"; then
  echo " Successfully created gpg (password) encrypted backup $BACKUP_FILE_ARCHIVE_GPG"
else
  echo "Encrypted backup failed!"
  exit 1
fi

# Delete the sqlite database backup file
rm -rf "$BACKUP_FILE_DB"
