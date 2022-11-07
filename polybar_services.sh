#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_services.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-11-07T09:39:45+0100

# speed up script by using standard c
LC_ALL=C
LANG=C

set_output() {
    if [ -z "$services" ]; then
        services="$(printf "%s" "$1")"
    else
        services="$(printf "%s %s" "$services" "$1")"
    fi
}

service_status() {
    case "$3" in
        user)
            systemctl --user -q is-active "$1" \
                && set_output "$2"
            ;;
        *)
            systemctl -q is-active "$1" \
                && set_output "$2"
            ;;
    esac
}

case "$1" in
    --status)
        service_status "xautolock.service" "" "user"
        service_status "i3_autotiling.service" "侀" "user"
        service_status "picom.service" "頋" "user"
        service_status "wacom.service" "" "user"
        service_status "xbanish.service" "" "user"
        service_status "systemd-resolved.service" ""
        service_status "systemd-timesyncd.service" "ﮮ"
        service_status "sshd.service" "撚"
        service_status "cups.service" "朗"
        service_status "bluetooth.service" ""

        basename=${0##*/}
        path=${0%"$basename"}

        "$path"helper/polybar_output.sh "%{T2}$services%{T-} "
        ;;
    --update)
        for id in $(pgrep -f "polybar main"); do
            polybar-msg -p "$id" \
                action "#services.hook.0" >/dev/null 2>&1 &
        done
        ;;
    *)
        i3_services.sh
        ;;
esac
