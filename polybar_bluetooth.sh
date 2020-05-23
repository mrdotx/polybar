#!/bin/sh

# path:       /home/klassiker/.local/share/repos/polybar/polybar_bluetooth.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-05-23T20:24:31+0200

# auth can be something like sudo -A, doas -- or
# nothing, depending on configuration requirements
auth="doas --"
service=bluetooth.service
target=bluetooth.target
icon=
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
        if [ "$(systemctl is-active $service)" = "active" ]; then
            xres "$xred"
        else
            xres "$xgrey"
        fi
        ;;
    *)
        if [ "$(systemctl is-active $service)" = "active" ]; then
            $auth systemctl disable $service --now \
                && $auth systemctl stop $target \
                && xres "$xgrey"
        else
            $auth systemctl enable $service --now \
                && $auth systemctl start $target \
                && xres "$xred"
        fi
        ;;
esac
