#!/bin/sh

# path:       ~/repos/polybar/polybar_gestures.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-03-20T15:39:41+0100

grey() {
    printf "%%{o%s}%%{o-}" "$(xrdb -query | grep Polybar.foreground1: | cut -f2)"
}

red() {
    printf "%%{o%s}%%{o-}" "$(xrdb -query | grep color9: | cut -f2)"
}

case "$1" in
    --status)
        if [ "$(pgrep -f /usr/bin/libinput-gestures)" ]; then
            red
        else
            grey
        fi
        ;;
    *)
        if [ "$(pgrep -f /usr/bin/libinput-gestures)" ]; then
            libinput-gestures-setup stop \
                && grey
        else
            libinput-gestures-setup start >/dev/null 2>&1 \
                && red
        fi
        ;;
esac
