# Review

Introduction
------------

Review is a tool to automate common tasks taken while working with Stash pull-requests.

Example
-------

Send out a pull request

```
$ cat <<EOF > .reviewrc
stash: https://stash.greenplum.com
to:
  project: HEIM
  repo: heimdall
  branch: master
reviewers:
  - capwed
EOF
# Send out a review based off the current branch
$ review submit
```

Change the reviewers

```
$ review submit --reviewer munges --reviewer capwed
```

Pull-request to a different branch

```
$ review submit --branch feature/zones
```

Merge the pull-request and cleanup local copies

```
$ review merge
```

Merge the pull-request, but keep the local branch

```
$ review merge --no-delete
```
