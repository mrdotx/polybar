#!/bin/sh

# path:       /home/klassiker/.local/share/repos/polybar/polybar_printer.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-10-28T15:24:17+0100

# auth can be something like sudo -A, doas -- or
# nothing, depending on configuration requirements
auth="doas"
service="org.cups.cupsd.service"
avahi_service="avahi-daemon.service"
avahi_socket="avahi-daemon.socket"
icon=""
line_color="Polybar.linecolor0"
foreground_color="Polybar.foreground0"
inactive_color="Polybar.foreground1"

# xresources
xresources() {
    printf "%%{o%s}%%{F%s}$icon%%{F- o-}" "$(xrdb -query \
        | grep "$1:" \
        | cut -f2 \
    )" \
    "$(xrdb -query \
        | grep "$2:" \
        | cut -f2 \
    )"
}

case "$1" in
    --status)
        if [ "$(systemctl is-active $service)" = "active" ]; then
            xresources "$line_color" "$foreground_color"
        else
            xresources "$inactive_color" "$inactive_color"
        fi
        ;;
    *)
        if [ "$(systemctl is-active $service)" = "active" ]; then
            $auth systemctl disable $avahi_socket --now \
                && $auth systemctl disable $avahi_service --now \
                && $auth systemctl disable $service --now \
                && xresources "$inactive_color" "$inactive_color"
        else
            $auth systemctl enable $service --now \
                && $auth systemctl enable $avahi_service --now \
                && $auth systemctl enable $avahi_socket --now \
                && xresources "$line_color" "$foreground_color"
        fi
        ;;
esac
