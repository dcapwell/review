# Review

A tool to automate common tasks taken while working with Stash pull-requests.

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

Adding a new command
--------------------

Review uses a simple plugin system for adding new commands; a command is detected by doing a directory listing of the 'subcmds' directory for '.sh' bash files.  The name of the command is the name of the file, so 'helloworld.sh' would create a command 'helloworld'.  This is enough to get the command to show up in the help menu.  

The help menu displays the command name and a summary next to it.  For a command to provide a summary, a 'command_name.summary' can be provided.  This file is just a plain text file, but should be kept to one line.

When a user selects the command (review helloworld), the command will be included into the bash session (you have access to utilities in review), and a function will be called named 'run'; this is a mandatory function that a command must provide.

Example:

Register new command with review

```
$ cat <<EOF > subcmds/helloworld.sh
run() {
  echo "Hello World"
}
EOF

$ ./review
Usage: review COMMAND [arg...]

Commands:
  helloworld
  submit         Send difference out for review
  sync           Sync with 'to' branch

$ ./review helloworld
Hello World

$ cat <<EOF > subcmds/helloworld.summary
Say 'Hello World'
EOF

$ ./review
Usage: review COMMAND [arg...]

Commands:
  helloworld     Say 'Hello World'
  submit         Send difference out for review
  sync           Sync with 'to' branch
```
