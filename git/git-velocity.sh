#!/usr/bin/env sh

# Print number of commits in each month

git rev-list HEAD | \
    git show --stdin --no-patch --format='%cd' --date='format:%Y-%m' | \
    sort | uniq -c
