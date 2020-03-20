#!/bin/sh

# path:       ~/repos/polybar/polybar_printer.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-03-20T15:32:29+0100

grey() {
    printf "%%{o%s}%%{o-}" "$(xrdb -query | grep Polybar.foreground1: | cut -f2)"
}

red() {
    printf "%%{o%s}%%{o-}" "$(xrdb -query | grep color9: | cut -f2)"
}

case "$1" in
    --status)
        if [ "$(systemctl is-active org.cups.cupsd.service)" = "active" ]; then
            red
        else
            grey
        fi
        ;;
    *)
        if [ "$(systemctl is-active org.cups.cupsd.service)" = "active" ]; then
            sudo -A systemctl stop org.cups.cupsd.service \
                && sudo -A systemctl stop avahi-daemon.service \
                && sudo -A systemctl stop avahi-daemon.socket \
                && grey
        else
            sudo -A systemctl start org.cups.cupsd.service \
                && sudo -A systemctl start avahi-daemon.service \
                && sudo -A systemctl start avahi-daemon.socket \
                && red
        fi
        ;;
esac
