
TOKEN_NAME=root-1
TOKEN_VALUE=TEST_TOKEN #glpat-VN8LuQVR1234K-gseQ1F 
GIT_RAILS_COMMAND="token = User.find_by_username('root').personal_access_tokens.create(scopes: [:api], name: '$TOKEN_NAME', expires_at: Date.today + 1.days); token.set_token('$TOKEN_VALUE'); token.save!"
echo $GIT_RAILS_COMMAND
kubectl exec -it -n gitlab gitlab-regional-0 -- gitlab-rails runner "$GIT_RAILS_COMMAND"


GITLAB_URL="https://git.${DOMAIN}"

# Your GitLab Private Token with API scope
GIT_ROOT_PASSWORD=$(kubectl exec -it -n gitlab gitlab-regional-0 --  grep 'Password:' /etc/gitlab/initial_root_password | awk '{print $2}')
GIT_ROOT_USER="root"
# User details
USER_NAME="ArgoCD Puller"
USERNAME="argocd-puller"
EMAIL="argocd@${DOMAIN}"
PASSWORD="secure_password_123"

# Construct the JSON payload
JSON_PAYLOAD=$(cat <<EOF
{
  "name": "${USER_NAME}",
  "username": "${USERNAME}",
  "email": "${EMAIL}",
  "password": "${PASSWORD}",
  "skip_confirmation": true
}
EOF
)

# Create User
USER_INFO=$(curl -k -X POST \
     --header "PRIVATE-TOKEN: ${TOKEN_VALUE}" \
     --header "Content-Type: application/json" \
     --data "${JSON_PAYLOAD}" \
     "${GITLAB_URL}/api/v4/users")
USER_ID=$(echo $USER_INFO | jq .id | awk '{print $2}')

# Create TOKEN 
curl --request POST \
     --header "PRIVATE-TOKEN: ${TOKEN_VALUE}" \
     --header "Content-Type: application/json" \
     --data '{
         "name": "'"${USER_NAME}"'",
         "user_id"
         "scopes": ["api", "read_repository"],
         "expires_at": "2026-08-01" 
     }' \
     "${GITLAB_URL}/api/v4/users/${USER_ID}/personal_access_tokens"


TOKEN_NAME="My Read TOKEN"
TOKEN_EXP="YYYY-MM-DD"
USER_ID=4
TOKEN_INFO=$(curl -k --request POST \
  --header "PRIVATE-TOKEN: ${TOKEN_VALUE}" \
  --data "name=${TOKEN_NAME}" --data "expires_at=${TOKEN_EXP}" \
  --data "scopes[]=api" --data "scopes[]=read_repository" \
  --url "${GITLAB_URL}/api/v4/users/${USER_ID}/personal_access_tokens")

USER_TOKEN=$(echo $TOKEN_INFO | jq .token )

echo "Find user token details: $USER_NAME $TOKEN_NAME $USER_TOKEN"

