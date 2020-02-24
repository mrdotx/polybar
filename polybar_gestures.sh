#!/bin/sh

# path:       ~/projects/polybar/polybar_gestures.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-02-24T08:54:48+0100

grey="%{o$(xrdb -query | grep Polybar.foreground1: | cut -f2)}%{o-}"
red="%{o$(xrdb -query | grep color9: | cut -f2)}%{o-}"

case "$1" in
    --status)
        if [ "$(pgrep -f /usr/bin/libinput-gestures)" ]
        then
            printf "%s" "$red"
        else
            printf "%s" "$grey"
        fi
        ;;
    *)
        if [ "$(pgrep -f /usr/bin/libinput-gestures)" ]
        then
            libinput-gestures-setup stop \
                && printf "%s" "$grey"
        else
            libinput-gestures-setup start >/dev/null 2>&1 \
                && printf "%s" "$red"
        fi
        ;;
esac
