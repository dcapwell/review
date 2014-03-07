# Review

Introduction
------------

Review is a tool to automate common tasks taken while working with Stash pull-requests.

Example
-------

Send out a pull request

```
$ cat <<EOF > .reviewrc
stash: https://stash.example.com
to:
  project: PRJ
  repo: my-project
  branch: master
reviewers:
  - dcapwell
EOF
# Send out a review based off the current branch
$ review submit
```
