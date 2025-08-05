TOKEN_VALUE=$1 

# Create Group 
GROUP_NAME="My New Group"
GROUP_PATH="my-new-group"
GROUP_DESCRIPTION="A group created via API"
GROUP_VISIBILITY="private"

GROUP_INFO=$(curl -k --request POST --header "Private-Token: ${TOKEN_VALUE}" \
     --header "Content-Type: application/json" \
     --data '{"name": "'"${GROUP_NAME}"'", "path": "'"${GROUP_PATH}"'", "description": "'"${GROUP_DESCRIPTION}"'", "visibility": "'"${GROUP_VISIBILITY}"'"}' \
     https://git.${DOMAIN}/api/v4/groups)

GROUP_ID=$(echo $GROUP_INFO | jq .id)

# Create project 
PROJECT_NAME="My Test Project"
PROJECT_PATH="my-project"
PROJECT_VISIBILITY="private"

PROJECT_INFO=$(curl -k --request POST \
    --header "Content-Type: application/json" \
    --header "Private-Token: ${TOKEN_VALUE}" \
    --data '{ "name": "'"${PROJECT_NAME}"'", "path": "'"${PROJECT_PATH}"'", "visibility": "'"${PROJECT_VISIBILITY}"'","namespace_id": "'"${GROUP_ID}"'" }' \
    "https://git.${DOMAIN}/api/v4/projects")
