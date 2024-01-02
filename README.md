## gitlab-backup

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
