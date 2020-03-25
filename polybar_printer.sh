#!/bin/sh

# path:       ~/.local/share/repos/polybar/polybar_printer.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-03-25T23:19:57+0100

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
            sudo -A systemctl disable $service --now \
                && sudo -A systemctl disable $service_a --now \
                && sudo -A systemctl disable $socket_a --now \
                && grey
        else
            sudo -A systemctl enable $service --now \
                && sudo -A systemctl enable $service_a --now \
                && sudo -A systemctl enable $socket_a --now \
                && red
        fi
        ;;
esac
