#!/bin/sh

# path:       ~/.local/share/repos/polybar/polybar_resolver.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-04-02T13:45:08+0200

# authorization can be something like sudo -A, doas -- or
# nothing, depending on service configuration
authorization="sudo -A"
service=systemd-resolved.service
icon=

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
                && grey
        else
            $authorization systemctl enable $service --now \
                && red
        fi
        ;;
esac
