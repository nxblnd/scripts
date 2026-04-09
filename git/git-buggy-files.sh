#!/usr/bin/env sh

# Get list of files and number of commits
# These files are changed when commit message contains words about fixing broken stuff

git rev-list --regexp-ignore-case --extended-regexp --grep='fix|bug|broken' HEAD | \
    git diff-tree --stdin --name-only --no-commit-id -r | \
    sort | uniq -c | sort -nr

