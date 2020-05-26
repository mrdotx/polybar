#!/bin/sh

# path:       /home/klassiker/.local/share/repos/polybar/polybar_gestures.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-05-26T20:01:17+0200

service=gestures.service
icon=
xl="Polybar.main1"
xfg="Polybar.foreground1"

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
            xres "$xl"
        else
            xres "$xfg"
        fi
        ;;
    *)
        if [ "$(systemctl --user is-active $service)" = "active" ]; then
            systemctl --user disable $service --now \
                && xres "$xfg"
        else
            systemctl --user enable $service --now \
                && xres "$xl"
        fi
        ;;
esac
