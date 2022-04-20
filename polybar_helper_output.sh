#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_helper_output.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-04-20T07:56:20+0200

# xresource value for line color (default Polybar.primary)
line_color=${2:-Polybar.primary}
# xresource value for foreground color (default Polybar.foreground)
foreground_color=${3:-Polybar.foreground}

xrdb_query() {
    xrdb -query \
        | grep "$1:" \
        | cut -f2
}

printf "%%{o%s}%%{F%s}%s%%{F- o-}\n" \
    "$(xrdb_query "$line_color")" \
    "$(xrdb_query "$foreground_color")" \
    "$1"
