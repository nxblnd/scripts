#!/usr/bin/env fish

set name $1

if test -z "$name"
    set name "./"
end

goto $name

git init
git commit -m "Initial commit" --allow-empty
