#!/usr/bin/env fish

function try_installing
    echo "Installation is not implemented"
    return 1
end

function check_dependencies
    argparse 'i/install' -- $argv

    set missing_dependencies
    for dependency in $argv
        if not type -q $dependency
            set --append missing_dependencies $dependency
        end
    end

    if test (count $missing_dependencies) -ne 0
        echo "These dependencies are missing: $missing_dependencies"

        if set -q _flag_install
            try_installing
        else
            return 1
        end
    end
end

function main
    set options 'h/help' 'i/install'
    argparse $options -- $argv || return 1

    if set -q _flag_help
        print_help \
            --name (status basename) \
            --description "Check dependency program availability" \
            --flag="h/help//Print help message" \
            --flag="i/install//Try installing missing dependencies" \
            --args="program1 [program2, program3, ...]"
        return
    end

    if set -q _flag_install
        check_dependencies --install $argv
    else
        check_dependencies $argv
    end
end

main $argv
