#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_trash-cli.sh
# author: klassiker [mrdotx]
# url:    https://github.com/mrdotx/polybar
# date:   2025-12-04T06:15:53+0100

# speed up script by using standard c
LC_ALL=C
LANG=C

# source polybar helper
. _polybar_helper.sh

# auth can be something like sudo -A, doas -- or nothing,
# depending on configuration requirements
auth="${EXEC_AS_USER:-sudo}"

case "$1" in
    --update)
        for id in $(pgrep -fx "polybar (weather.*|xwindow.*)"); do
            polybar-msg -p "$id" \
                action "#trash.hook.0" >/dev/null 2>&1 &
        done
        ;;
    *)
        trash=$($auth trash-list 2> /dev/null | wc -l)

        [ "$trash" -gt 0 ] \
            && polybar_output "%{T2}󰩺 %{T-}$trash"
        ;;
esac
