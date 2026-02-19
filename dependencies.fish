#!/usr/bin/env fish

set options 'h/help' 'i/install'

function print_help
    echo "Check dependency programs" >&2
    echo "Usage: dependencies" \
        "[-h | --help]" \
        "[-i | --install]" \
        "program1 [program2, program3, ...]" >&2
    echo -es \
        "-h, --help\t\tPrint this help\n" \
        "-i, --install\t\tTry installing missing dependencies" >&2
end

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
    argparse $options -- $argv || return 1

    if set -q _flag_help
        print_help
        return
    end

    if set -q _flag_install
        check_dependencies --install $argv
    else
        check_dependencies $argv
    end
end

main $argv
