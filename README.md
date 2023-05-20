# gitlab-backup

## About

Gets a list of the projects on a gitlab instance, and clones the repos and wikis.

**NOTE: This does not backup:**  
**- Merge requests**  
**- Issues board**  
**- Snippets**  
**- CI/CD stuff**  
**- etc.**  
**- Members, user information etc.**  

## Usage

1. Update the variables at the top of build.sh
2. Run `./build.sh`  
3. A new backup should now be under the backups/ folder
