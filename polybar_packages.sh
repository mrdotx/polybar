#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_packages.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-01-09T18:40:29+0100

icon=""
line_color="Polybar.main0"
foreground_color="Polybar.foreground0"

xresources() {
    xrdb_query() {
        xrdb -query \
            | grep "$1:" \
            | cut -f2
    }

    printf "%%{o%s}%%{F%s}%s %d%%{F- o-}" \
        "$(xrdb_query "$1")" \
        "$(xrdb_query "$2")" \
        "$icon" \
        "$3"
}

if ping -c1 -W1 -q 1.1.1.1 >/dev/null 2>&1; then
    updates_pacman=$(checkupdates 2> /dev/null | wc -l ) \
        || updates_pacman=0

    updates_aur=$(paru -Qua 2> /dev/null | wc -l) \
        || updates_aur=0

    updates=$((updates_pacman + updates_aur))
else
    updates=0
fi

if [ $updates -gt 0 ]; then
    xresources "$line_color" "$foreground_color" "$updates"
fi
