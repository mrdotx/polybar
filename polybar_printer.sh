#!/bin/sh

# path:       /home/klassiker/.local/share/repos/polybar/polybar_printer.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-04-29T11:12:11+0200

# auth can be something like sudo -A, doas -- or
# nothing, depending on configuration requirements
auth="doas --"
service=org.cups.cupsd.service
service_a=avahi-daemon.service
socket_a=avahi-daemon.socket
icon=

grey() {
    printf "%%{o%s}$icon%%{o-}" "$(xrdb -query | grep Polybar.foreground1: | cut -f2)"
}

red() {
    printf "%%{o%s}$icon%%{o-}" "$(xrdb -query | grep color9: | cut -f2)"
}

case "$1" in
    --status)
        if [ "$(systemctl is-active $service)" = "active" ]; then
            red
        else
            grey
        fi
        ;;
    *)
        if [ "$(systemctl is-active $service)" = "active" ]; then
            $auth systemctl disable $service --now \
                && $auth systemctl disable $service_a --now \
                && $auth systemctl disable $socket_a --now \
                && grey
        else
            $auth systemctl enable $service --now \
                && $auth systemctl enable $service_a --now \
                && $auth systemctl enable $socket_a --now \
                && red
        fi
        ;;
esac
