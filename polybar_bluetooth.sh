#!/bin/sh

# path:       ~/repos/polybar/polybar_bluetooth.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-03-20T15:46:18+0100

grey() {
    printf "%%{o%s}%%{o-}" "$(xrdb -query | grep Polybar.foreground1: | cut -f2)"
}

red() {
    printf "%%{o%s}%%{o-}" "$(xrdb -query | grep color9: | cut -f2)"
}

case "$1" in
    --status)
        if [ "$(systemctl is-active bluetooth.service)" = "active" ]; then
            red
        else
            grey
        fi
        ;;
    *)
        if [ "$(systemctl is-active bluetooth.service)" = "active" ]; then
            sudo -A systemctl stop bluetooth.service \
                && sudo -A systemctl stop bluetooth.target \
                && grey
        else
            sudo -A systemctl start bluetooth.service \
                && sudo -A systemctl start bluetooth.target \
                && red
        fi
        ;;
esac
