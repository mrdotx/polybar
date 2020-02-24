#!/bin/sh

# path:       ~/projects/polybar/polybar_vpn_hades.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-02-24T09:02:48+0100

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
            gpg -o "/tmp/$vpn_name.txt" "$HOME/cloud/webde/Keys/$vpn_name.txt.gpg" \
                && nmcli con up id $vpn_name passwd-file "/tmp/$vpn_name.txt" \
                && rm -f "/tmp/$vpn_name.txt" \
                && printf "%s" "$red"
        fi
        ;;
esac
