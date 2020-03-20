#!/bin/sh

# path:       ~/repos/polybar/polybar_vpn_hades.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-03-20T16:15:32+0100

vpn_name=hades

grey() {
    printf "%%{o%s}%%{o-}" "$(xrdb -query | grep Polybar.foreground1: | cut -f2)"
}

red() {
    printf "%%{o%s}%%{o-}" "$(xrdb -query | grep color9: | cut -f2)"
}

case "$1" in
    --status)
        if [ "$(pgrep -f "vpnc $vpn_name")" ]; then
            red
        else
            grey
        fi
        ;;
    *)
        if [ "$(pgrep -f "vpnc $vpn_name")" ]; then
            sudo -A vpnc-disconnect \
                && grey
        else
            sudo -A vpnc $vpn_name \
                && red
        fi
        ;;
esac
