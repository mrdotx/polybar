#!/bin/sh

# path:       ~/.local/share/repos/polybar/polybar_printer.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-04-02T13:44:55+0200

# authorization can be something like sudo -A, doas -- or
# nothing, depending on service configuration
authorization="sudo -a"
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
            $authorization systemctl disable $service --now \
                && $authorization systemctl disable $service_a --now \
                && $authorization systemctl disable $socket_a --now \
                && grey
        else
            $authorization systemctl enable $service --now \
                && $authorization systemctl enable $service_a --now \
                && $authorization systemctl enable $socket_a --now \
                && red
        fi
        ;;
esac
