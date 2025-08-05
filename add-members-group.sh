GROUP_ID=5
USER_ID=4
curl -k --request POST \
  --header "PRIVATE-TOKEN: ${TOKEN_VALUE}" \
  --header "Content-Type: application/json" \
  --data '{"user_id": "'"${USER_ID}"'", "access_level": 20}' \
  "https://git.${DOMAIN}/api/v4/groups/${GROUP_ID}/members"  