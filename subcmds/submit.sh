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

generate_reviewers() {
  local list=()
  for user in "${reviewers[@]}"
  do
    list+=( "{ \"user\": { \"name\": \"$user\" } }")
  done

  ##TODO how can I do this in a function?  Can't find a way to pass arrays around
  SAVE_IFS=$IFS
  IFS=","
  echo "${list[*]}"
  IFS=$SAVE_IFS
}

to_lowercase() {
  echo "$@" | tr '[:upper:]' '[:lower:]'
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
    $(generate_reviewers)
  ]
}
EOF
}

pull_request() {
  local data="$(generate_data)"
  # flatten the json
  data=$(echo "$data" | tr "\n" " ")
  local stash_url="${stash}/rest/api/1.0/projects/$(to_lowercase ${to_project})/repos/${to_repo}/pull-requests"
  if [ "$DEBUG" == "true" ]; then
    ##TODO find a cleaner way to flush after the read.  This only affects
    ## this part of the stdout
    echo ""
    info "Attempting to submit a pull request for ${USERNAME} with the following details"
    info "Stash URL: ${stash_url}"
    info "Project: ${to_project}"
    info "Repo: ${to_repo}"
    info "Branch: ${to_branch}"
    info "POST data: ${data}"
  fi
  curl -s --show-error -u "${USERNAME}" "${stash_url}" -X POST -H'Content-Type: application/json' -d"$data"
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
