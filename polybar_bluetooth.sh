#!/bin/sh

# path:       ~/projects/polybar/polybar_bluetooth.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-02-03T13:21:32+0100

grey=$(xrdb -query | grep Polybar.foreground1: | cut -f2)
red=$(xrdb -query | grep color9: | cut -f2)

case "$1" in
    --status)
        if [ "$(systemctl is-active bluetooth.service)" = "active" ]
        then
            echo "%{o$red}%{o-}"
        else
            echo "%{o$grey}%{o-}"
        fi
        ;;
    *)
        if [ "$(systemctl is-active bluetooth.service)" != "active" ]
        then
            sudo -A systemctl start bluetooth.service \
                && sudo -A systemctl start bluetooth.target \
                && sudo -A systemctl start ModemManager.service \
                && echo "%{o$red}%{o-}"
        else
            sudo -A systemctl stop bluetooth.service \
                && sudo -A systemctl stop bluetooth.target \
                && sudo -A systemctl stop ModemManager.service \
                && echo "%{o$grey}%{o-}"
        fi
        ;;
esac
