#!/bin/sh

# path:       ~/repos/polybar/polybar_gestures.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-03-19T14:55:52+0100

grey="%{o$(xrdb -query | grep Polybar.foreground1: | cut -f2)}%{o-}"
red="%{o$(xrdb -query | grep color9: | cut -f2)}%{o-}"

case "$1" in
    --status)
        [ "$(pgrep -f /usr/bin/libinput-gestures)" ] \
            && printf "%s" "$red" \
            || printf "%s" "$grey"
        ;;
    *)
        if [ "$(pgrep -f /usr/bin/libinput-gestures)" ]; then
            libinput-gestures-setup stop \
                && printf "%s" "$grey"
        else
            libinput-gestures-setup start >/dev/null 2>&1 \
                && printf "%s" "$red"
        fi
        ;;
esac
