#!/bin/bash -xe

# NOTE: This is aimed at backing up a user's repos on the public github.com

GITHUB_USERNAME=<PUT YOUR GITHUB USER NAME HERE>

# Created here https://github.com/settings/tokens
GITHUB_ACCESS_TOKEN=<PUT YOUR GITHUB ACCESS TOKEN HERE>

# Create our backup folder
DATE=$(date '+%Y%m%d')
rm -rf "backups/$DATE/github"
mkdir -p "backups/$DATE/github"
cd "backups/$DATE/github"

# Get a list of the projects from the github API
# NOTE: We only want projects that are not forks (Ignores one off merge requests for random public projects), and we only need the git_url attribute
PROJECTS=$(curl -L -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $GITHUB_ACCESS_TOKEN" -H "X-GitHub-Api-Version: 2022-11-28" -H "type: owner" https://api.github.com/user/repos | jq -r '.[] | select(.fork==false) | "\(.full_name)"')

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
