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

# parse_yaml() {
#    local prefix=$2
#    local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
#    sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
#         -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
#    awk -F$fs '{
#       indent = length($1)/2;
#       vname[indent] = $2;
#       for (i in vname) {if (i > indent) {delete vname[i]}}
#       if (length($3) > 0) {
#          vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
#          printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
#       }
#    }'
# }

function ryaml {
  ruby -ryaml -e 'puts ARGV[1..-1].inject(YAML.load(File.read(ARGV[0]))) {|acc, key| acc[key] }' "$@"
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
  # read -p "Please enter your user name ($USER): " username
  # read -s -p "Please enter your password: " password
  # # the newline in password doesn't get used, so inject a newline
  # info ""

  # if [ -z "$username" ]; then
  #   username="$USER"
  # fi

  #pull_request

  ryaml .reviewrc
}
