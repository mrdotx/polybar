#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_helper_net_check.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-04-10T17:57:16+0200

# check ip/address to connect to (default 1.1.1.1)
net=${1:-1.1.1.1}
# check connection for x tenth of a second (default 50)
check=${2:-50}

while ! ping -c1 -W1 -q "$net" >/dev/null 2>&1 \
    && [ "$check" -gt 0 ]; do
        sleep .1
        check=$((check - 1))
done

if [ $check -eq 0 ]; then
    return 1
else
    return 0
fi
