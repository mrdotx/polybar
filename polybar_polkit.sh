#!/bin/sh

# path:       ~/projects/polybar/polybar_polkit.sh
# user:       klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-01-23T11:39:04+0100

grey=$(xrdb -query | grep Polybar.foreground1: | cut -f2)
red=$(xrdb -query | grep color9: | cut -f2)

case "$1" in
    --status)
        if [ "$(pgrep -f /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1)" ]
        then
            echo "%{o$red}%{o-}"
        else
            echo "%{o$grey}%{o-}"
        fi
        ;;
    *)
        if [ "$(pgrep -f /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1)" ]
        then
            killall /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 \
                && echo "%{o$grey}%{o-}"
        else
            /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 >/dev/null 2>&1 \
                & echo "%{o$red}%{o-}"
        fi
        ;;
esac
