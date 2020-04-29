#!/bin/sh

# path:       /home/klassiker/.local/share/repos/polybar/polybar_rss.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-04-29T22:39:16+0200

timer=rss.timer
icon=

# xresources
grey() {
    printf "%%{o%s}$icon%%{o-}" "$(xrdb -query | grep Polybar.foreground1: | cut -f2)"
}
# temporary fix for print-unread with newsboat 2.19 is devide by 4 ($1/4)
red() {
    unread=$(newsboat -x print-unread | awk '$icon {printf "%d\n", $1/4}')
    printf "%%{o%s}$icon $unread%%{o-}" "$(xrdb -query | grep color9: | cut -f2)"
}

status() {
if [ "$(systemctl --user is-active $timer)" = "active" ]; then
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
        if [ "$(systemctl --user is-active $timer)" = "active" ]; then
            systemctl --user disable $timer --now \
                && grey
        else
            systemctl --user enable $timer --now \
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
