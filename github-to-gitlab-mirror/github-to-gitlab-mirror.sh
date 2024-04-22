#!/bin/bash -xeu

# NOTE: This mirrors repos from the public github.com (And probably private instances) to a private gitlab instance (And probably gitlab.com)

GITHUB_USERNAME=<PUT YOUR GITHUB USER NAME HERE>

# Created here https://github.com/settings/tokens
GITHUB_ACCESS_TOKEN=<PUT YOUR GITHUB ACCESS TOKEN HERE>

GITLAB_HOST=<PUT YOUR GITLAB HOSTNAME HERE>
GITLAB_PORT=443
GITLAB_ACCESS_TOKEN=<PUT YOUR GITLAB ACCESS TOKEN HERE>

# TODO: We could also use the github.com RSS feeds to work out when there are changes:
# https://github.com/pilkch/ac-display/commits.atom

# Create our backup folder
DATE=$(date '+%Y%m%d')
WORKING_FOLDER="$HOME/.github-to-gitlab-mirror/"
mkdir -p "$WORKING_FOLDER"
cd "$WORKING_FOLDER"

# Get a list of the projects from the github API
# NOTE: We only want projects that are not forks (Ignores one off merge requests for random public projects), and we only need the git_url attribute
PROJECTS=$(curl -L -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $GITHUB_ACCESS_TOKEN" -H "X-GitHub-Api-Version: 2022-11-28" -H "type: owner" https://api.github.com/user/repos | jq -r '.[] | select(.fork==false) | "\(.full_name)"')

# We get a list with entries like "pilkch/postcodes"
echo "PROJECTS=$PROJECTS"

# Clone each project
# eg. myproject
while IFS= read -r PROJECT_PATH_WITH_NAMESPACE; do
  declare PROJECT=$(basename $PROJECT_PATH_WITH_NAMESPACE)

  # NOTE: We don't care about issues, merge requests, wikis, releases, etc.
  if [[ -d "$PROJECT.git" ]]; then
    # We already have a cloned mirror, so just perform an update
    (cd "$PROJECT.git" && git remote update origin)
  else
    # We haven't cloned the mirror yet
    git clone --mirror "git@github.com:$PROJECT_PATH_WITH_NAMESPACE.git"
  fi

  # Add the gitlab remote and push to our mirror
  pushd "$PROJECT.git"
  git remote add gitlab "git@${GITLAB_HOST}:${GITLAB_BASE_FOLDER}/${PROJECT}.git" || git remote set-url gitlab "git@${GITLAB_HOST}:${GITLAB_BASE_FOLDER}/${PROJECT}.git"
  # Push, ignoring errors because existing refs will cause a non-zero result
  git push gitlab --mirror || true
  popd
done <<< "$PROJECTS"
