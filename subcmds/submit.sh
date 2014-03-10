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

## create a temp file for processing
tmp_dir() {
  local dir="/tmp/review/work/$(uuidgen)"
  mkdir -p "$dir"
  echo "$dir"
}

extract_json_value() {
  local file="$1"
  local key="$2"

  python <<EOF
import json
json_data = open('${file}')
data = json.load(json_data)
json_data.close()

print data['${key}']
EOF
}

review_dir() {
  if [ $# -lt 1 ]; then
    fatal "review_dir requires the id of the review"
  fi
  local id="$1"
  local dir="${DATA_DIR}/reviews/${id}"

  echo "$dir"
}

pull_request() {
  ## get post body
  local data="$(generate_data)"
  # flatten the json
  data=$(echo "$data" | tr "\n" " ")

  ## http url to post to
  local stash_url="${stash}/rest/api/1.0/projects/$(to_lowercase ${to_project})/repos/${to_repo}/pull-requests"

  ## get staging directory
  local staging_dir=$(tmp_dir)
  local results="$staging_dir/result.json"

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
    info "Staging dir: ${staging_dir}"
    info "Results file: ${results}"
  fi
  curl -s --show-error --fail --output "${results}" -u "${USERNAME}" "${stash_url}" -X POST -H'Content-Type: application/json' -d"$data"

  if [ -e "$results" ]; then
    ## find the id from the json and save that to the review db
    local id=$(extract_json_value "$results" "id")
    local review=$(review_dir "$id")
    mkdir -p "$review"
    mv "$results" "$review/pull-request.json"
  fi
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
