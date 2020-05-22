#!/bin/sh

# path:       /home/klassiker/.local/share/repos/polybar/polybar_printer.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-05-22T17:27:24+0200

# auth can be something like sudo -A, doas -- or
# nothing, depending on configuration requirements
auth="doas --"
service=org.cups.cupsd.service
service_a=avahi-daemon.service
socket_a=avahi-daemon.socket
icon=
xred="color1"
xgrey="Polybar.foreground1"

# xresources
xres() {
    printf "%%{o%s}$icon%%{o-}" "$(xrdb -query | grep "$1:" | cut -f2)"
}

case "$1" in
    --status)
        if [ "$(systemctl is-active $service)" = "active" ]; then
            xres "$xred"
        else
            xres "$xgrey"
        fi
        ;;
    *)
        if [ "$(systemctl is-active $service)" = "active" ]; then
            $auth systemctl disable $service --now \
                && $auth systemctl disable $service_a --now \
                && $auth systemctl disable $socket_a --now \
                && xres "$xgrey"
        else
            $auth systemctl enable $service --now \
                && $auth systemctl enable $service_a --now \
                && $auth systemctl enable $socket_a --now \
                && xres "$xred"
        fi
        ;;
esac
