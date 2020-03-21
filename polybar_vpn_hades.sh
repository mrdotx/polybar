#!/bin/sh

# path:       ~/repos/polybar/polybar_vpn_hades.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-03-21T01:15:56+0100

service=vpnc@hades.service
icon=

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
            sudo -A systemctl stop $service \
                && grey
        else
            sudo -A systemctl start $service \
                && red
        fi
        ;;
esac
