#!/bin/sh

# path:       ~/repos/polybar/polybar_bluetooth.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-02-28T08:15:47+0100

grey="%{o$(xrdb -query | grep Polybar.foreground1: | cut -f2)}%{o-}"
red="%{o$(xrdb -query | grep color9: | cut -f2)}%{o-}"

case "$1" in
    --status)
        if [ "$(systemctl is-active bluetooth.service)" = "active" ]
        then
            printf "%s" "$red"
        else
            printf "%s" "$grey"
        fi
        ;;
    *)
        if [ "$(systemctl is-active bluetooth.service)" != "active" ]
        then
            sudo -A systemctl start bluetooth.service \
                && sudo -A systemctl start bluetooth.target \
                && sudo -A systemctl start ModemManager.service \
                && printf "%s" "$red"
        else
            sudo -A systemctl stop bluetooth.service \
                && sudo -A systemctl stop bluetooth.target \
                && sudo -A systemctl stop ModemManager.service \
                && printf "%s" "$grey"
        fi
        ;;
esac
