#!/bin/sh

# path:       ~/repos/polybar/polybar_bluetooth.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-03-19T14:52:36+0100

grey="%{o$(xrdb -query | grep Polybar.foreground1: | cut -f2)}%{o-}"
red="%{o$(xrdb -query | grep color9: | cut -f2)}%{o-}"

case "$1" in
    --status)
        [ "$(systemctl is-active bluetooth.service)" = "active" ] \
            && printf "%s" "$red" \
            || printf "%s" "$grey"
        ;;
    *)
        if [ "$(systemctl is-active bluetooth.service)" != "active" ]; then
            sudo -A systemctl start bluetooth.service \
                && sudo -A systemctl start bluetooth.target \
                && printf "%s" "$red"
        else
            sudo -A systemctl stop bluetooth.service \
                && sudo -A systemctl stop bluetooth.target \
                && printf "%s" "$grey"
        fi
        ;;
esac
