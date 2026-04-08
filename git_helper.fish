#!/usr/bin/env fish

function init -a name
    if test -z "$name"
        set name "./"
    end

    goto $name

    git init
    git commit -m "Initial commit" --allow-empty
end

function churn
    git rev-list --since="1 year ago" HEAD | \
        git diff-tree --stdin --name-only --no-commit-id -r | \
        sort | uniq -c | sort -nr
end

function velocity
    git rev-list HEAD | \
        git show --stdin --no-patch --format='%cd' --date='format:%Y-%m' | \
        sort | uniq -c
end

function main
    switch $argv[1]
        case init
            init $argv[2..]
        case churn
            churn
        case velocity
            velocity
        case *
            echo "Unknown subcommand"
            exit 1
    end
end

main $argv
