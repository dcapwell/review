branch_id() {
  git rev-parse --symbolic-full-name HEAD
}

branch_name() {
  git rev-parse --abbrev-ref HEAD
}

branch_commit_messages() {
  local fromBranch="$1"
  git log ${fromBranch}..HEAD --no-merges --no-color --pretty=format:%s
}

generate_data() {
  # user must be looked up by name and not email
  cat <<EOF
{
  "title": "$(branch_name)",
  "description": "$(branch_commit_messages master)",
  "open": true,
  "closed": false,
  "fromRef": {
    "id": "$(branch_id)",
    "project": {
      "key": "HEIM"
    }
  },
  "toRef": {
    "id": "refs/heads/master",
    "repository": {
      "slug": "heimdall",
      "name": "heimdall",
      "project": {
        "key": "HEIM"
      }
    }
  },
  "reviewers": [
    {
      "user": {
        "name": "munges"
      }
    }
  ]
}
EOF
}

pull_request() {
  local data="$(generate_data)"
  # flatten the json
  data=$(echo "$data" | tr "\n" " ")
  curl -si 'https://wbe_headless:yahoo@stash.greenplum.com/rest/api/1.0/projects/heim/repos/heimdall/pull-requests' -X POST -H'Content-Type: application/json' -d"$data"
}

run() {
  read -p "Please enter your user name ($USER): " username
  read -s -p "Please enter your password: " password
  # the newline in password doesn't get used, so inject a newline
  info ""

  if [ -z "$username" ]; then
    username="$USER"
  fi

  pull_request
}
