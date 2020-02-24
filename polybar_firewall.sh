#!/bin/sh

# path:       ~/projects/polybar/polybar_firewall.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-02-24T08:50:46+0100

grey="%{o$(xrdb -query | grep Polybar.foreground1: | cut -f2)}%{o-}"
red="%{o$(xrdb -query | grep color9: | cut -f2)}%{o-}"

case "$1" in
    --status)
        if [ "$(systemctl is-active ufw.service)" = "active" ]
        then
            printf "%s" "$red"
        else
            printf "%s" "$grey"
        fi
        ;;
    *)
        if [ "$(systemctl is-active ufw.service)" != "active" ]
        then
            sudo -A systemctl start ufw.service \
                && printf "%s" "$red"
        else
            sudo -A systemctl stop ufw.service \
                && printf "%s" "$grey"
        fi
        ;;
esac
