run() {
  read -p "Please enter your username ($USER): " username
  read -s -p "Please enter your password: " password
  # the newline in password doesn't get used, so inject a newline
  info ""

  if [ -z "$username" ]; then
    username="$USER"
  fi

  echo "I got your password ($password) $username!"
}

# The structure of a pull-request is as follows
# POST application/json /rest/api/1.0/projects/{projectKey}/repos/{repositorySlug}/pull-requests
# {
#   "title": "<name>",
#   "description": "<desc>",
#   "open": true,
#   "closed": false,
#   "fromRef": {
#     "id": "refs/heads/feature-ABC-123",
#     "name": null,
#     "project": {
#       "key": "PRJ"
#     }
#   },
#   "toRef": {
#     "id": "refs/heads/master",
#     "repository": {
#       "slug": "my-repo",
#       "name": null,
#       "project": {
#         "key": "PRJ"
#       }
#     }
#   },
#   "reviewers": [
#     {
#       "user": {
#         "name": "charlie",
#         "emailAddress": "charlie@gopivotal.com"
#       }
#     }
#   ]
# }
pull_request() {
}
