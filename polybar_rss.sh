#!/bin/sh

# path:       /home/klassiker/.local/share/repos/polybar/polybar_rss.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2021-01-10T10:48:31+0100

timer="rss.timer"
icon=""
line_color="Polybar.main0"
foreground_color="Polybar.foreground0"
inactive_color="Polybar.foreground1"

xresources() {
    xrdb_query() {
        xrdb -query \
            | grep "$1:" \
            | cut -f2
    }

    [ "$3" = "unread" ] \
        && icon="$icon $(newsboat -x print-unread \
                | cut -d ' ' -f1 \
            )"

    printf "%%{o%s}%%{F%s}$icon%%{F- o-}" \
    "$(xrdb_query "$1")" \
    "$(xrdb_query "$2")"
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
    --update)
        polybar-msg hook module/rss 1 >/dev/null 2>&1
        ;;
    --open)
        pgrep -x newsboat >/dev/null 2>&1 \
            && exit 0

        polybar-msg hook module/rss 3 > /dev/null 2>&1 \
            && newsboat -q \
            && polybar-msg hook module/rss 1 > /dev/null 2>&1
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
        pgrep -x newsboat >/dev/null 2>&1 \
            && exit 0

        if ping -c1 -W1 -q 1.1.1.1 >/dev/null 2>&1; then
            polybar-msg hook module/rss 3 > /dev/null 2>&1 \
                && newsboat -x reload \
                && newsboat -q -X >/dev/null 2>&1 \
                && polybar-msg hook module/rss 1 >/dev/null 2>&1
        else
            status
        fi
        ;;
esac
