#!/bin/sh

# path:       /home/klassiker/.local/share/repos/polybar/polybar_printer.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-06-07T16:01:19+0200

# auth can be something like sudo -A, doas -- or
# nothing, depending on configuration requirements
auth="doas --"
service=org.cups.cupsd.service
service_a=avahi-daemon.service
socket_a=avahi-daemon.socket
icon=
xl="color1"
xfg="Polybar.foreground1"

# xresources
xres() {
    printf "%%{o%s}$icon%%{o-}" "$(xrdb -query \
            | grep "$1:" \
            | cut -f2 \
        )"
}

case "$1" in
    --status)
        if [ "$(systemctl is-active $service)" = "active" ]; then
            xres "$xl"
        else
            xres "$xfg"
        fi
        ;;
    *)
        if [ "$(systemctl is-active $service)" = "active" ]; then
            $auth systemctl disable $socket_a --now \
                && $auth systemctl disable $service_a --now \
                && $auth systemctl disable $service --now \
                && xres "$xfg"
        else
            $auth systemctl enable $service --now \
                && $auth systemctl enable $service_a --now \
                && $auth systemctl enable $socket_a --now \
                && xres "$xl"
        fi
        ;;
esac
