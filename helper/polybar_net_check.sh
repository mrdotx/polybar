#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/helper/polybar_net_check.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-06-20T17:48:05+0200

# check ip/address to connect to (default 1.1.1.1)
net=${1:-1.1.1.1}
# check connection for x tenth of a second (default 50)
check=${2:-50}

while ! ping -c1 -W1 -q "$net" >/dev/null 2>&1 \
    && [ "$check" -gt 0 ]; do
        sleep .1
        check=$((check - 1))
done

case "$check" in
    0)
        exit 1
        ;;
esac
