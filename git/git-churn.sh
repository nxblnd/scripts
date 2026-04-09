#!/usr/bin/env sh

# Get list of files and number of commits since last year
# Track recently changed files

git rev-list --since="1 year ago" HEAD | \
    git diff-tree --stdin --name-only --no-commit-id -r | \
    sort | uniq -c | sort -nr
