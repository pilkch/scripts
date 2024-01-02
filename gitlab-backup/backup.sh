#!/bin/bash -xe

GITLAB_HOST=<PUT YOUR GITLAB HOSTNAME HERE>
GITLAB_PORT=443
GITLAB_ACCESS_TOKEN=<PUT YOUR GITLAB ACCESS TOKEN HERE>

# Create our backup folder
DATE=$(date '+%Y%m%d')
mkdir -p "backups/$DATE"
cd "backups/$DATE"

# Get a list of the projects from the gitlab API
API_RESPONSE=$(curl -k --header  "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN"  "https://$GITLAB_HOST:$GITLAB_PORT/api/v4/projects")


# Parse the project URLs
PROJECT_URLS=$(echo $API_RESPONSE | jq -r '.[].ssh_url_to_repo')

# Clone each project
# eg. myproject
while IFS= read -r REPO_URL; do
  git clone --mirror $REPO_URL
done <<< "$PROJECT_URLS"


# Parse the project paths with namespaces
# eg. mygroup/myproject
PROJECT_PATHS_WITH_NAMESPACES=$(echo $API_RESPONSE | jq -r '.[].path_with_namespace')

# Clone the wiki if there is one
while IFS= read -r PROJECT_PATH_WITH_NAMESPACE; do
  # Not every project has a wiki, this is allowed to fail
  git clone --mirror "git@$GITLAB_HOST:$PROJECT_PATH_WITH_NAMESPACE.wiki.git" || true
done <<< "$PROJECT_PATHS_WITH_NAMESPACES"
