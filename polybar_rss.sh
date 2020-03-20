#!/bin/sh

# path:       ~/repos/polybar/polybar_rss.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-03-20T15:28:59+0100

grey() {
    printf "%%{o%s}%%{o-}" "$(xrdb -query | grep Polybar.foreground1: | cut -f2)"
}

red() {
    unread=$(newsboat -x print-unread | awk '{printf " %d\n",$1}')
    printf "%%{o%s}$unread%%{o-}" "$(xrdb -query | grep color9: | cut -f2)"
}

status() {
if [ "$(systemctl --user is-active rss.timer)" = "active" ]; then
    red
else
    grey
fi
}

case "$1" in
    --status)
        status
        ;;
    --toggle)
        if [ "$(systemctl --user is-active rss.timer)" = "active" ]; then
            systemctl --user stop rss.timer \
                && systemctl --user disable rss.timer \
                && grey
        else
            systemctl --user enable rss.timer \
                && systemctl --user start rss.timer \
                && red
        fi
        ;;
    *)
        # exit if newsboat is running
        pgrep -x newsboat >/dev/null 2>&1 \
            && exit

        if ping -c1 -W1 -q 1.1.1.1 >/dev/null 2>&1; then
            newsboat -x reload && newsboat -q -X >/dev/null 2>&1 \
                && polybar-msg hook module/rss 1 >/dev/null 2>&1
        else
            status
        fi
        ;;
esac
