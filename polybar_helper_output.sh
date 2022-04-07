#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_helper_output.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-04-07T19:04:06+0200

# xresource value (default Polybar.main0)
line_color=${2:-Polybar.main0}
# xresource value (default Polybar.foreground0)
foreground_color=${3:-Polybar.foreground0}

xrdb_query() {
    xrdb -query \
        | grep "$1:" \
        | cut -f2
}

printf "%%{o%s}%%{F%s}%s%%{F- o-}\n" \
    "$(xrdb_query "$line_color")" \
    "$(xrdb_query "$foreground_color")" \
    "$1"
