#!/usr/bin/env fish

function init -a name
    if test -z "$name"
        set name "./"
    end

    goto $name

    git init
    git commit -m "Initial commit" --allow-empty
end

function main
    switch $argv[1]
        case init
            init $argv[2..]
        case *
            echo "Unknown subcommand"
            exit 1
    end
end

main $argv
