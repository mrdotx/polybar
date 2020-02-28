#!/bin/sh

# path:       ~/repos/polybar/polybar_rss.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-02-28T08:16:53+0100

# exit if newsboat is running
pgrep -x newsboat >/dev/null 2>&1 \
    && polybar-msg hook module/rss 2 >/dev/null 2>&1 \
    && exit

if ping -c1 -W1 -q 1.1.1.1 >/dev/null 2>&1; then
    newsboat -x reload && newsboat -q -X >/dev/null 2>&1 \
        && polybar-msg hook module/rss 3 >/dev/null 2>&1
else
    polybar-msg hook module/rss 3 >/dev/null 2>&1
fi
