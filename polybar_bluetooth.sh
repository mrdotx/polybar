#!/bin/sh

# path:       ~/repos/polybar/polybar_bluetooth.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-03-20T22:14:17+0100

service=bluetooth.service
target=bluetooth.target
icon=

grey() {
    printf "%%{o%s}$icon%%{o-}" "$(xrdb -query | grep Polybar.foreground1: | cut -f2)"
}

red() {
    printf "%%{o%s}$icon%%{o-}" "$(xrdb -query | grep color9: | cut -f2)"
}

case "$1" in
    --status)
        if [ "$(systemctl is-active $service)" = "active" ]; then
            red
        else
            grey
        fi
        ;;
    *)
        if [ "$(systemctl is-active $service)" = "active" ]; then
            sudo -A systemctl disable $service --now \
                && sudo -A systemctl stop $target \
                && grey
        else
            sudo -A systemctl enable $service --now \
                && sudo -A systemctl start $target \
                && red
        fi
        ;;
esac
