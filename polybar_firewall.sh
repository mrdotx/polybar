#!/bin/sh

# path:       ~/repos/polybar/polybar_firewall.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-03-20T15:42:57+0100

grey() {
    printf "%%{o%s}%%{o-}" "$(xrdb -query | grep Polybar.foreground1: | cut -f2)"
}

red() {
    printf "%%{o%s}%%{o-}" "$(xrdb -query | grep color9: | cut -f2)"
}

case "$1" in
    --status)
        if [ "$(systemctl is-active ufw.service)" = "active" ]; then
            red
        else
            grey
        fi
        ;;
    *)
        if [ "$(systemctl is-active ufw.service)" = "active" ]; then
            sudo -A systemctl stop ufw.service \
                && grey
        else
            sudo -A systemctl start ufw.service \
                && red
        fi
        ;;
esac
