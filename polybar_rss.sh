#!/bin/sh

# path:       /home/klassiker/.local/share/repos/polybar/polybar_rss.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-06-17T01:39:11+0200

timer=rss.timer
icon=
line_color="color1"
foreground_color="Polybar.foreground0"
inactive_color="Polybar.foreground1"

# xresources
xresources() {
    unread=$(newsboat -x print-unread \
        | awk '$icon {printf "%d\n", $1/4}' \
    )
    if [ "$3" = "unread" ]; then
        printf "%%{o%s}%%{F%s}$icon $unread%%{F- o-}" "$(xrdb -query \
            | grep "$1:" \
            | cut -f2 \
        )" \
        "$(xrdb -query \
            | grep "$2:" \
            | cut -f2 \
        )"
    else
        printf "%%{o%s}%%{F%s}$icon%%{F- o-}" "$(xrdb -query \
            | grep "$1:" \
            | cut -f2 \
        )" \
        "$(xrdb -query \
            | grep "$2:" \
            | cut -f2 \
        )"
    fi
}

status() {
if [ "$(systemctl --user is-active $timer)" = "active" ]; then
    xresources "$line_color" "$foreground_color" "unread"
else
    xresources "$inactive_color" "$inactive_color"
fi
}

case "$1" in
    --status)
        status
        ;;
    --toggle)
        if [ "$(systemctl --user is-active $timer)" = "active" ]; then
            systemctl --user disable $timer --now \
                && xresources "$inactive_color" "$inactive_color"
        else
            systemctl --user enable $timer --now \
                && xresources "$line_color" "$foreground_color" "unread"
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
