## Description

Various scripts that I use at home.

## check-mp3-files.sh

Finds all mp3 files and checks that `file` agrees they are mp3 files.

## download-mp3.sh and download-mp4.sh

Note: These require youtube-dl and optionally yt-dlp.

To download audio:
```bash
./download-mp3.sh https://www.youtube.com/watch?v=LMSRW8ZBZ5M
```
OR to download a portion of the audio:
```bash
./download-mp3.sh https://www.youtube.com/watch?v=LMSRW8ZBZ5M 6:02-6:22
```

To download a video:
```bash
./download-mp4.sh https://www.youtube.com/watch?v=LMSRW8ZBZ5M
```

## backup-servers.sh

### About

Calls the other scripts below to create a backup and copies the backups to a mounted samba share (Or somewhere else on the machine)

### Usage

1. Update the configuration or remove the calls to the below scripts from backup-servers.sh
2. ./backup-servers.sh
3. Backups should now exist on the samba share (Or whatever destination you have entered)


## github-backup.sh

### About

Gets a list of the projects on a github instance, and clones the repos and wikis.

### Usage

1. Update the variables at the top of vaultwarden-backup.sh
2. Only call this script as it is called from backup-servers.sh because we have to do some su magic
3. A new backup should now be under the $HOME/backups/ folder


## gitlab-backup.sh

### About

Gets a list of the projects on a gitlab instance, and clones the repos and wikis.

**NOTE: These do not get backed up:**  
**- Merge requests**  
**- Issues board**  
**- Snippets**  
**- CI/CD stuff**  
**- etc.**  
**- Members, user information etc.**  

### Usage

1. Update the variables at the top of gitlab-backup.sh
2. Run the backup script:
```bash
./gitlab-backup.sh
```
3. A new backup should now be under the $HOME/backups/ folder


## homeassistant-backup.sh

### About

HomeAssistant has a non-trivial websocket API so I've created [a helper](https://github.com/pilkch/homeassistant-websocket-api-helper).

### Usage

It requires building a C++ application and is complicated to set up, please check the notes at the top of homeassistant-backup.sh for using the script.


## vaultwarden-backup.sh

### About

Vaultwarden doesn't have an API so taking a backup means we have to log onto the machine as the local vaultwarden user, get a copy of the files, tar them and copy them back to the calling server.

### Usage

1. Update the variables at the top of vaultwarden-backup.sh
2. Only call this script as it is called from backup-servers.sh because we have to do some su magic
3. A new backup should now be under the $HOME/backups/ folder
