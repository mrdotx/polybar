#!/bin/sh

# path:       ~/repos/polybar/polybar_polkit.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-03-20T15:36:11+0100

grey() {
    printf "%%{o%s}%%{o-}" "$(xrdb -query | grep Polybar.foreground1: | cut -f2)"
}

red() {
    printf "%%{o%s}%%{o-}" "$(xrdb -query | grep color9: | cut -f2)"
}

case "$1" in
    --status)
        if [ "$(pgrep -f /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1)" ]; then
            red
        else
            grey
        fi
        ;;
    *)
        if [ "$(pgrep -f /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1)" ]; then
            killall /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 \
                && grey
        else
            /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 >/dev/null 2>&1 \
                & red
        fi
        ;;
esac
