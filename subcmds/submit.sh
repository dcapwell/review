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
      "key": "${to_project}"
    }
  },
  "toRef": {
    "id": "refs/heads/${to_branch}",
    "repository": {
      "slug": "${to_repo}",
      "name": "${to_repo}",
      "project": {
        "key": "${to_project}"
      }
    }
  },
  "reviewers": [
    {
      "user": {
        "name": "${reviewers[0]}"
      }
    }
  ]
}
EOF
}

pull_request() {
  local data="$(generate_data)"
  # flatten the json
  data=$(echo "$data" | tr -s "\n")
  if [ "$DEBUG" == "true" ]; then
    info "Attempting to submit a pull request for ${USERNAME} with the following details"
    info "Project: ${to_project}"
    info "Repo: ${to_repo}"
    info "Branch: ${to_branch}"
    info "POST data: ${data}"
  fi
  curl -s --show-error --digest -u "${USERNAME}" "${stash}/rest/api/1.0/projects/${to_project}/repos/${to_repo}/pull-requests" -X POST -H'Content-Type: application/json' -d"$data"
}

run() {
  ##TODO talk to Bob about caching this detail
  ##TODO --netrc could be useful?
  read -p "Enter host user name (default: '$USER'): " USERNAME

  if [ -z "$USERNAME" ]; then
    USERNAME="$USER"
  fi

  export USERNAME

  pull_request
}
