#!/usr/bin/env fish

function process_config
    set config_path ~/.config/codesync/config.json
    set jq_filter '.[] | [
        (.repoUrl // "UNLISTED_REPO"),
        (.path // error("No path provided")),
        (.remote // "UNLISTED_REMOTE"),
        (.branch // "UNLISTED_BRANCH"),
        (.mode // "fetch"),
        (.gitargs // "")
    ] | @tsv'

    jq -r "$jq_filter" $config_path | while read -l repo_url path remote branch mode gitargs
        set path (expand_tilda $path)
        set gitargs (expand_tilda $gitargs)
        run_git $repo_url $path $remote $branch $mode $gitargs
    end
end

function expand_tilda -a string
    string replace --regex --all '~/' "$HOME/" -- "$string"
end

function run_git -a repo_url path remote branch mode gitargs
    function gitpath --no-scope-shadowing
        if test -n "$gitargs"
            git -C $path (string split ' ' -- $gitargs) $argv
        else
            git -C $path $argv
        end
    end

    if not gitpath rev-parse --is-inside-work-tree > /dev/null
        return 1
    end

    if test "$branch" = "UNLISTED_BRANCH"
        set branch (gitpath config init.defaultBranch)
    end

    if test "$remote" = "UNLISTED_REMOTE"
        set remote (gitpath config branch.$branch.remote)
    end

    if test "$repo_url" = "UNLISTED_REPO"
        set repo_url (gitpath config remote.$remote.url)
    end

    switch $mode
        case "fetch"
            gitpath fetch $remote $branch
        case "push"
            gitpath fetch $remote $branch
            gitpath push $remote $branch
        case '*'
            echo "$mode not supported"
    end

    echo
end

function main
    set options 'h/help'
    argparse $options -- $argv

    if set -q _flag_help
        print_help \
            --name (status basename) \
            --description "Sync git repos"
        return
    end

    dependencies git jq || return 1
    process_config
end

main $argv
