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

## gitlab-backup/backup.sh

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

1. Update the variables at the top of backup.sh
2. Run the backup script:
```bash
cd gitlab-backup
./backup.sh
```
3. A new backup should now be under the backups/ folder
