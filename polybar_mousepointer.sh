#!/bin/sh

# path:       /home/klassiker/.local/share/repos/polybar/polybar_mousepointer.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-10-28T15:24:07+0100

service="xbanish.service"
icon=""
line_color="Polybar.linecolor0"
foreground_color="Polybar.foreground0"
inactive_color="Polybar.foreground1"

# xresources
xresources() {
    printf "%%{o%s}%%{F%s}$icon%%{F- o-}" "$(xrdb -query \
        | grep "$1:" \
        | cut -f2 \
    )" \
    "$(xrdb -query \
        | grep "$2:" \
        | cut -f2 \
    )"
}

case "$1" in
    --status)
        if [ "$(systemctl --user is-active $service)" = "active" ]; then
            xresources "$line_color" "$foreground_color"
        else
            xresources "$inactive_color" "$inactive_color"
        fi
        ;;
    *)
        if [ "$(systemctl --user is-active $service)" = "active" ]; then
            systemctl --user disable $service --now \
                && xresources "$inactive_color" "$inactive_color"
        else
            systemctl --user enable $service --now \
                && xresources "$line_color" "$foreground_color"
        fi
        ;;
esac