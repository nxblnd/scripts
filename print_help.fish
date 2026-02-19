#!/usr/bin/env fish

function print_usage
    set options 'name=' 'flag=*' 'args=?'
    argparse $options -- $argv || return 1

    echo -n "Usage: $_flag_name" >&2
    for flag in $_flag_flag
        set expanded (string split '/' $flag)

        echo -n " [ " >&2

        if test -n "$expanded[1]"
            echo -n "-$expanded[1]" >&2

            if test -n "$expanded[3]"
                echo -n "=<$expanded[3]>" >&2
            end
        end

        if test -n "$expanded[1]" && test -n "$expanded[2]"
            echo -n " | " >&2
        end

        if test -n "$expanded[2]"
            echo -n "--$expanded[2]" >&2

            if test -n "$expanded[3]"
                echo -n "=<$expanded[3]>" >&2
            end
        end

        echo -n " ]" >&2
    end
    echo -n " $_flag_args" >&2
    echo >&2
end

function print_options
    set options 'flag=*'
    argparse $options -- $argv || return 1

    echo "Available flags:" >&2
    for flag in $_flag_flag
        set expanded (string split '/' $flag)

        if test -n "$expanded[1]" && test -n "$expanded[2]"
            set flag_field "-$expanded[1], --$expanded[2]"
        else
            if test -n "$expanded[1]"
                set flag_field "-$expanded[1]"
            else
                set flag_field "--$expanded[2]"
            end
        end

        if test -n "$expanded[3]"
            set arg "<$expanded[3]>"
        else
            set arg ""
        end

        printf "%15s %8s %s" "$flag_field" "$arg" "$expanded[4]" >&2
        echo >&2
    end
end

function main
    set options 'h/help' 'n/name=' 'd/description=' 'f/flag=*' 'a/args=?' 'notes=?'
    argparse $options -- $argv || return 1

    if set -q _flag_help
        main \
            -n (status basename) \
            -d "Print help messages from scripts" \
            --flag="h/help//Print help message" \
            --flag="n/name/name/Name of the program" \
            --flag="d/description/description/Description of the program" \
            --flag="f/flag/flag/Flags of the program, can be used multiple times" \
            --flag="a/args/arguments/String that shows what arguments can be used" \
            --flag="/notes/notes/Additional notes how to use program" \
            --notes="Flags are described using this format: 'short_flag/long_flag/flag_argument/flag_description'"
        return
    end

    echo -e $_flag_description >&2
    echo >&2
    print_usage --name=$_flag_name --flag=$_flag_flag --args=$_flag_args
    echo >&2
    print_options --flag=$_flag_flag

    if set -q _flag_notes
        echo >&2
        echo "Notes: $_flag_notes" >&2
    end
end

main $argv
