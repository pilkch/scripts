#!/bin/bash -xeu

# NOTE: This mirrors repos from a private gitlab instance (And probably gitlab.com) to the public github.com (And probably private instances)

GITLAB_HOST=<PUT YOUR GITLAB HOSTNAME HERE>
GITLAB_PORT=443
GITLAB_ACCESS_TOKEN=<PUT YOUR GITLAB ACCESS TOKEN HERE>
GITLAB_GROUP=<PUT YOU GITLAB GROUP FOLDER, eg. myparent/mygroup>
GITLAB_GROUP_ID=<PUT YOUR GITLAB GROUP ID HERE, eg. 10>

GITHUB_HOST=<PUT YOUR GITHUB HOSTNAME HERE>
GITHUB_USER=<PUT YOUR GITHUB USERNAME HERE>

# Create our backup folder
DATE=$(date '+%Y%m%d')
WORKING_FOLDER="$HOME/.gitlab-to-github-mirror/"
mkdir -p "$WORKING_FOLDER"
cd "$WORKING_FOLDER"

# Get a list of up to 100 projects in this group with via the gitlab API
API_RESPONSE=$(curl -k --header "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" "https://$GITLAB_HOST:$GITLAB_PORT/api/v4/groups/$GITLAB_GROUP_ID/projects?&per_page=100")

# Parse the project URLs
PROJECTS=$(echo $API_RESPONSE | jq -r '.[].name' | sort)

# We get a list with entries like "myproject"
echo "PROJECTS=$PROJECTS"

# Clone each project
# eg. myproject.git
while IFS= read -r PROJECT; do
  # NOTE: We don't care about issues, merge requests, releases, etc.
  if [[ -d "$PROJECT.git" ]]; then
    # We already have a cloned mirror, so just perform an update
    (cd "$PROJECT.git" && git remote update origin)
  else
    # We haven't cloned the mirror yet
    # git@gitlab.local:myparent/mygroup/myproject.git
    git clone --mirror "git@$GITLAB_HOST:$GITLAB_GROUP/$PROJECT.git"
  fi

  pushd "$PROJECT.git"
  git remote add github "git@${GITHUB_HOST}:${GITHUB_USER}/${PROJECT}.git" || git remote set-url github "git@${GITHUB_HOST}:${GITHUB_USER}/${PROJECT}.git"
  # Push, ignoring errors because existing refs will cause a non-zero result
  git push github --mirror || true
  popd

  # Check if there is a wiki
  #API_RESPONSE=$(curl -k --header "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" "https://$GITLAB_HOST:$GITLAB_PORT/api/v4/projects/dev%2Fpublic%2F$PROJECT/wikis/home")
  #echo $API_RESPONSE

  # Clone the wiki if there is one
  if [[ -d "$PROJECT.wiki.git" ]]; then
    # We already have a cloned mirror, so just perform an update
    (cd "$PROJECT.wiki.git" && git remote update origin)
  else
    # We haven't cloned the mirror yet
    # git@gitlab.local:myparent/mygroup/myproject.wiki.git
    CLONE_OUTPUT=$(git clone --mirror "git@$GITLAB_HOST:$GITLAB_GROUP/$PROJECT.wiki.git" 2>&1)
    if [[ "$CLONE_OUTPUT" == *"You appear to have cloned an empty repository"* ]]; then
      # There probably weren't any wiki pages created for this project yet, so the cloned git repo is empty,
      # don't bother mirroring it, just delete the folder
      rm -rf "$PROJECT.wiki.git"
    fi
  fi

  # The wiki may or may not have now been cloned and we might be able to push it to the new server
  if [[ -d "$PROJECT.wiki.git" ]]; then
    pushd "$PROJECT.wiki.git"
    git remote add github "git@${GITHUB_HOST}:${GITHUB_USER}/${PROJECT}.wiki.git" || git remote set-url github "git@${GITHUB_HOST}:${GITHUB_USER}/${PROJECT}.wiki.git"
    # Push, ignoring errors because existing refs will cause a non-zero result
    git push github --mirror || true
    popd
  fi
done <<< "$PROJECTS"
