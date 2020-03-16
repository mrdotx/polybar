#!/bin/sh

# path:       ~/repos/polybar/polybar_vpn_hades.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-03-16T12:36:53+0100

vpn_name=hades
grey="%{o$(xrdb -query | grep Polybar.foreground1: | cut -f2)}%{o-}"
red="%{o$(xrdb -query | grep color9: | cut -f2)}%{o-}"

case "$1" in
    --status)
        if [ "$(nmcli connection show --active $vpn_name)" ]
        then
            printf "%s" "$red"
        else
            printf "%s" "$grey"
        fi
        ;;
    *)
        if [ "$(nmcli connection show --active $vpn_name)" ]
        then
            nmcli con down id $vpn_name \
                && printf "%s" "$grey"
        else
            gpg -o "/tmp/$vpn_name.gpg.txt" "$HOME/cloud/webde/Keys/$vpn_name.gpg" \
                && nmcli con up id $vpn_name passwd-file "/tmp/$vpn_name.gpg.txt" \
                && rm -f "/tmp/$vpn_name.gpg.txt" \
                && printf "%s" "$red"
        fi
        ;;
esac
