#!/bin/sh

# path:       ~/repos/polybar/polybar_vpn_hades.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-03-19T15:00:49+0100

vpn_name=hades
grey="%{o$(xrdb -query | grep Polybar.foreground1: | cut -f2)}%{o-}"
red="%{o$(xrdb -query | grep color9: | cut -f2)}%{o-}"

case "$1" in
    --status)
        [ "$(pgrep -f "vpnc $vpn_name")" ] \
            && printf "%s" "$red" \
            || printf "%s" "$grey"
        ;;
    *)
        if [ "$(pgrep -f "vpnc $vpn_name")" ]; then
            sudo vpnc-disconnect \
                && printf "%s" "$grey"
        else
            sudo vpnc $vpn_name \
                && printf "%s" "$red"
        fi
        ;;
esac
