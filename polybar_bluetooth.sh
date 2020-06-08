#!/bin/sh

# path:       /home/klassiker/.local/share/repos/polybar/polybar_bluetooth.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-06-08T11:30:24+0200

# auth can be something like sudo -A, doas -- or
# nothing, depending on configuration requirements
auth="doas --"
service=bluetooth.service
target=bluetooth.target
icon=
active_color="color1"
inactive_color="Polybar.foreground1"

# xresources
xresources() {
    printf "%%{o%s}$icon%%{o-}" "$(xrdb -query \
            | grep "$1:" \
            | cut -f2 \
        )"
}

case "$1" in
    --status)
        if [ "$(systemctl is-active $service)" = "active" ]; then
            xresources "$active_color"
        else
            xresources "$inactive_color"
        fi
        ;;
    *)
        if [ "$(systemctl is-active $service)" = "active" ]; then
            $auth systemctl stop $target \
                && $auth systemctl disable $service --now \
                && xresources "$inactive_color"
        else
            $auth systemctl enable $service --now \
                && $auth systemctl start $target \
                && xresources "$active_color"
        fi
        ;;
esac
