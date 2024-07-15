#!/bin/bash -xe

# Usage:
# ./tandoor-backup.sh $DATE

# GPG encrypting files
# https://www.redhat.com/sysadmin/encryption-decryption-gpg

# Decrypting later (You will be prompted for the password used to encrypt it earlier)
# gpg --output tandoor20240114.tar.gz --decrypt tandoor20240114.tar.gz.gpg

TANDOOR_GPG_PASSWORD=<PUT A LONG RANDOMLY GENERATED PASSWORD HERE>

DATE="$1"

# Copy the next stage script to the tandoor user on homeassistant (I run tandoor on my Home Assistant NUC which is basically my "untrusted" server on the wifi VLAN)
sudo cp /home/ansible/user-tandoor-backup.sh /home/tandoor/
sudo chown tandoor:tandoor /home/tandoor/user-tandoor-backup.sh

# Run the actual tandoor backup script as the tandoor user
sudo -u tandoor /home/tandoor/user-tandoor-backup.sh $DATE

TANDOOR_BACKUP_FILE_ARCHIVE="/home/ansible/tandoor${DATE}.tar.gz"
TANDOOR_BACKUP_FILE_ARCHIVE_GPG="/home/ansible/tandoor${DATE}.tar.gz.gpg"

# Copy the backup to the ansible user's home folder
sudo mv /home/tandoor/backups/$DATE/tandoor/tandoor$DATE.tar.gz /home/ansible/


# Encrypt the backup
if /bin/gpg --batch --no-options --no-tty --yes --symmetric --passphrase "$TANDOOR_GPG_PASSWORD" --cipher-algo AES256 -o "$TANDOOR_BACKUP_FILE_ARCHIVE_GPG" --encrypt "$TANDOOR_BACKUP_FILE_ARCHIVE" ; then
  echo " Successfully created gpg encrypted backup $TANDOOR_BACKUP_FILE_ARCHIVE_GPG"
else
  echo "Encrypted backup failed!"
  exit 1
fi

# Clean up
# NOTE: The caller still needs the gpg encrypted backup so we don't delete it, but we can delete the unencrypted backup that was left in the tandoor user's home folder
sudo rm -f /home/tandoor/user-tandoor-backup.sh "/home/tandoor/backups/$DATE/tandoor/tandoor$DATE.tar.gz"
