#!/bin/sh

# path:       /home/klassiker/.local/share/repos/polybar/polybar_gestures.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-05-23T20:25:31+0200

service=gestures.service
icon=
xred="color1"
xgrey="Polybar.foreground1"

# xresources
xres() {
    printf "%%{o%s}$icon%%{o-}" "$(xrdb -query \
            | grep "$1:" \
            | cut -f2 \
        )"
}

case "$1" in
    --status)
        if [ "$(systemctl --user is-active $service)" = "active" ]; then
            xres "$xred"
        else
            xres "$xgrey"
        fi
        ;;
    *)
        if [ "$(systemctl --user is-active $service)" = "active" ]; then
            systemctl --user disable $service --now \
                && xres "$xgrey"
        else
            systemctl --user enable $service --now \
                && xres "$xred"
        fi
        ;;
esac
