#!/bin/sh

# path:       ~/projects/polybar/polybar_printer.sh
# user:       klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-01-23T11:39:28+0100

grey=$(xrdb -query | grep Polybar.foreground1: | cut -f2)
red=$(xrdb -query | grep color9: | cut -f2)

case "$1" in
    --status)
        if [ "$(systemctl is-active org.cups.cupsd.service)" = "active" ]
        then
            echo "%{o$red}%{o-}"
        else
            echo "%{o$grey}%{o-}"
        fi
        ;;
    *)
        if [ "$(systemctl is-active org.cups.cupsd.service)" != "active" ]
        then
            sudo -A systemctl start org.cups.cupsd.service \
                && sudo -A systemctl start avahi-daemon.service \
                && sudo -A systemctl start avahi-daemon.socket \
                && echo "%{o$red}%{o-}"
        else
            sudo -A systemctl stop org.cups.cupsd.service \
                && sudo -A systemctl stop avahi-daemon.service \
                && sudo -A systemctl stop avahi-daemon.socket \
                && echo "%{o$grey}%{o-}"
        fi
        ;;
esac