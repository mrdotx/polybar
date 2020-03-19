#!/bin/sh

# path:       ~/repos/polybar/polybar_polkit.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-03-19T14:57:31+0100

grey="%{o$(xrdb -query | grep Polybar.foreground1: | cut -f2)}%{o-}"
red="%{o$(xrdb -query | grep color9: | cut -f2)}%{o-}"

case "$1" in
    --status)
        [ "$(pgrep -f /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1)" ] \
            && printf "%s" "$red" \
            || printf "%s" "$grey"
        ;;
    *)
        if [ "$(pgrep -f /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1)" ]; then
            killall /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 \
                && printf "%s" "$grey"
        else
            /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 >/dev/null 2>&1 \
                & printf "%s" "$red"
        fi
        ;;
esac
