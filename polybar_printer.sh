#!/bin/sh

# path:       ~/repos/polybar/polybar_printer.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-03-19T14:58:40+0100

grey="%{o$(xrdb -query | grep Polybar.foreground1: | cut -f2)}%{o-}"
red="%{o$(xrdb -query | grep color9: | cut -f2)}%{o-}"

case "$1" in
    --status)
        [ "$(systemctl is-active org.cups.cupsd.service)" = "active" ] \
            && printf "%s" "$red" \
            || printf "%s" "$grey"
        ;;
    *)
        if [ "$(systemctl is-active org.cups.cupsd.service)" != "active" ]; then
            sudo -A systemctl start org.cups.cupsd.service \
                && sudo -A systemctl start avahi-daemon.service \
                && sudo -A systemctl start avahi-daemon.socket \
                && printf "%s" "$red"
        else
            sudo -A systemctl stop org.cups.cupsd.service \
                && sudo -A systemctl stop avahi-daemon.service \
                && sudo -A systemctl stop avahi-daemon.socket \
                && printf "%s" "$grey"
        fi
        ;;
esac
