#!/usr/bin/env fish

umask 077

set keyname "$argv[1]"

if test -z "$keyname"
    echo "No keyname given"
    exit 1
end

wg genkey | tee "$keyname" | wg pubkey > "$keyname.pub"
