#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_pacman.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-04-05T09:03:21+0200

icon_pacman=""
icon_aur=""
line_color="Polybar.main0"
foreground_color="Polybar.foreground0"

net_check() {
    # check connection x tenth of a second
    check=$1

    while ! ping -c1 -W1 -q "$2" >/dev/null 2>&1 \
        && [ "$check" -gt 0 ]; do
            sleep .1
            check=$((check - 1))
    done

    if [ $check -eq 0 ]; then
        return 1
    else
        return 0
    fi
}

output() {
    # get xresources
    xrdb_query() {
        xrdb -query \
            | grep "$1:" \
            | cut -f2
    }

    printf "%%{o%s}%%{F%s}%s%%{F- o-}\n" \
        "$(xrdb_query "$line_color")" \
        "$(xrdb_query "$foreground_color")" \
        "$1"
}

case "$1" in
    --update)
        polybar-msg -p "$(pgrep -f "polybar primary")" \
            action "#pacman.hook.0" >/dev/null 2>&1 &
        ;;
    *)
        if net_check 50 "1.1.1.1"; then
            updates_pacman=$(checkupdates 2> /dev/null | wc -l)
            updates_aur=$(paru -Qua 2> /dev/null | wc -l)

            if [ "$updates_pacman" -gt 0 ] \
                && [ "$updates_aur" -gt 0 ]; then \
                    output "$icon_pacman $updates_pacman $icon_aur $updates_aur"
            else
                [ "$updates_pacman" -gt 0 ] \
                    && output "$icon_pacman $updates_pacman"

                [ "$updates_aur" -gt 0 ] \
                    && output "$icon_aur $updates_aur"
            fi
        fi
        ;;
esac
