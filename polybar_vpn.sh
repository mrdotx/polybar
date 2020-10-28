#!/bin/sh

# path:       /home/klassiker/.local/share/repos/polybar/polybar_vpn.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-10-28T15:25:44+0100

# auth can be something like sudo -A, doas -- or
# nothing, depending on configuration requirements
auth="doas"
service="vpnc@hades.service"
icon=""
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
            $auth systemctl disable $service --now \
                && xresources "$inactive_color" "$inactive_color"
        else
            $auth systemctl enable $service --now \
                && xresources "$line_color" "$foreground_color"
        fi
        ;;
esac
