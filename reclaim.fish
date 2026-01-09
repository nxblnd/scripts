#!/usr/bin/env fish

switch (rg "^ID" /etc/os-release)
    case arch
        paccache -rk 1
end

journalctl --vacuum-size=500M

docker volume prune
docker image prune -a
docker buildx prune
docker container prune --filter "until=720h" # remove containers stopped more than 30 days ago
