#!/bin/bash -xe

# NOTE: This is aimed at backing up a user's repos on the public github.com

# Created here https://github.com/settings/tokens
# The token needs "Repository permissions -> Metadata: Read only"
GITHUB_ACCESS_TOKEN=<PUT YOUR GITHUB ACCESS TOKEN HERE>

# Create our backup folder
DATE=$(date '+%Y%m%d')
BACKUP_FOLDER="$HOME/backups/$DATE/github"
rm -rf "$BACKUP_FOLDER"
mkdir -p "$BACKUP_FOLDER"
cd "$BACKUP_FOLDER"

# Get a list of the projects from the github API
# NOTE: We only want projects that are not forks (Ignores one off merge requests for random public projects), and we only need the git_url attribute
# NOTE: We specify 100 per page which is the maximum, if you have more than 100 projects then you'll have to implement pagination
PROJECTS=$(curl -L -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $GITHUB_ACCESS_TOKEN" -H "X-GitHub-Api-Version: 2022-11-28" -H "type: owner" https://api.github.com/user/repos?per_page=100 | jq -r '.[] | select(.fork==false) | "\(.full_name)"')

# We get a list with entries like "pilkch/postcodes"
echo "PROJECTS=$PROJECTS"

# Clone each project
# eg. myproject
while IFS= read -r PROJECT_PATH_WITH_NAMESPACE; do
  git clone --mirror "git@github.com:$PROJECT_PATH_WITH_NAMESPACE.git"

  # Clone the wiki if there is one
  # Not every project has a wiki, this is allowed to fail
  # TODO: A further improvement could be only cloning the wiki page if has_wiki: true is set in the json
  git clone --mirror "git@github.com:$PROJECT_PATH_WITH_NAMESPACE.wiki.git" || true
done <<< "$PROJECTS"

# Tar the whole github folder and delete it
cd ..
tar zcf ./github$DATE.tar.gz ./github
rm -rf ./github
