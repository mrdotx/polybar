#!/bin/sh

# path:       ~/projects/polybar/polybar_gestures.sh
# user:       klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-01-23T11:38:12+0100

grey=$(xrdb -query | grep Polybar.foreground1: | cut -f2)
red=$(xrdb -query | grep color9: | cut -f2)

case "$1" in
    --status)
        if [ "$(pgrep -f /usr/bin/libinput-gestures)" ]
        then
            echo "%{o$red}%{o-}"
        else
            echo "%{o$grey}%{o-}"
        fi
        ;;
    *)
        if [ "$(pgrep -f /usr/bin/libinput-gestures)" ]
        then
            libinput-gestures-setup stop \
                && echo "%{o$grey}%{o-}"
        else
            libinput-gestures-setup start >/dev/null 2>&1 \
                && echo "%{o$red}%{o-}"
        fi
        ;;
esac
