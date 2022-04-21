#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_trash-cli.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-04-21T11:39:07+0200

# speed up script by using posix
LC_ALL=C
LANG=C

icon_trash=""

case "$1" in
    --update)
        for id in $(pgrep -f "polybar main"); do
            polybar-msg -p "$id" \
                action "#trash.hook.0" >/dev/null 2>&1 &
        done
        ;;
    *)
        trash=$($EXEC_AS_USER trash-list 2> /dev/null | wc -l)

        [ "$trash" -gt 0 ] \
            && polybar_helper_output.sh \
                "$icon_trash $trash"
        ;;
esac
