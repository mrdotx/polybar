#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_trash-cli.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-06-12T19:15:32+0200

# speed up script by using standard c
LC_ALL=C
LANG=C

# auth can be something like sudo -A, doas -- or nothing,
# depending on configuration requirements
auth="${EXEC_AS_USER:-sudo}"

icon_trash="%{T2} %{T-}"

case "$1" in
    --update)
        for id in $(pgrep -f "polybar main"); do
            polybar-msg -p "$id" \
                action "#trash.hook.0" >/dev/null 2>&1 &
        done
        ;;
    *)
        trash=$($auth trash-list 2> /dev/null | wc -l)

        [ "$trash" -gt 0 ] \
            && polybar_helper_output.sh \
                "$icon_trash$trash"
        ;;
esac
