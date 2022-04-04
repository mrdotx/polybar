#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_pacman.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-04-04T15:32:25+0200

icon_pacman=""
icon_aur=""
line_color="Polybar.main0"
foreground_color="Polybar.foreground0"

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

if sleep 3 && ping -c1 -W1 -q 1.1.1.1 >/dev/null 2>&1; then
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
