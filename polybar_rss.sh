#!/bin/sh

# path:       /home/klassiker/.local/share/repos/polybar/polybar_rss.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-06-04T12:09:11+0200

timer=rss.timer
icon=
xfg="Polybar.foreground1"

# xresources
xres() {
    printf "%%{o%s}$icon%%{o-}" "$(xrdb -query \
            | grep "$1:" \
            | cut -f2 \
        )"
}

# temporary fix for print-unread with newsboat 2.19 is devide by 4 ($1/4)
xl() {
    unread=$(newsboat -x print-unread \
        | awk '$icon {printf "%d\n", $1/4}' \
    )
    printf "%%{o%s}$icon $unread%%{o-}" "$(xrdb -query \
            | grep color1: \
            | cut -f2 \
        )"
}

status() {
if [ "$(systemctl --user is-active $timer)" = "active" ]; then
    xl
else
    xres "$xfg"
fi
}

case "$1" in
    --status)
        status
        ;;
    --toggle)
        if [ "$(systemctl --user is-active $timer)" = "active" ]; then
            systemctl --user disable $timer --now \
                && xres "$xfg"
        else
            systemctl --user enable $timer --now \
                && xl
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
