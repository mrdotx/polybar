#!/bin/sh

# path:       ~/repos/polybar/polybar_resolver.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-03-19T14:59:41+0100

grey="%{o$(xrdb -query | grep Polybar.foreground1: | cut -f2)}%{o-}"
red="%{o$(xrdb -query | grep color9: | cut -f2)}%{o-}"

case "$1" in
    --status)
        [ "$(systemctl is-active systemd-resolved.service)" = "active" ] \
            && printf "%s" "$red" \
            || printf "%s" "$grey"
        ;;
    *)
        if [ "$(systemctl is-active systemd-resolved.service)" != "active" ]; then
            sudo -A systemctl start systemd-resolved.service \
                && printf "%s" "$red"
        else
            sudo -A systemctl stop systemd-resolved.service \
                && printf "%s" "$grey"
        fi
        ;;
esac
