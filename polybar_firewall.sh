#!/bin/sh

# path:       ~/.local/share/repos/polybar/polybar_firewall.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-04-16T08:41:44+0200

# auth can be something like sudo -A, doas -- or
# nothing, depending on configuration requirements
auth="sudo -A"
service=ufw.service
icon=

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
                && grey
        else
            $auth systemctl enable $service --now \
                && red
        fi
        ;;
esac
