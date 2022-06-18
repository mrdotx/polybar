#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_services.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-06-18T14:22:41+0200

# speed up script by using standard c
LC_ALL=C
LANG=C

icon_autolock=""
icon_autotiling="侀"
icon_compositor="頋"
icon_wacom=""
icon_mousepointer=""
icon_resolver=""
icon_timesync="祥"
icon_ssh="撚"
icon_vpn="旅"
icon_printer="朗"
icon_bluetooth=""

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
        service_status "xautolock.service" "$icon_autolock" "user"
        service_status "i3_autotiling.service" "$icon_autotiling" "user"
        service_status "picom.service" "$icon_compositor" "user"
        service_status "wacom.service" "$icon_wacom" "user"
        service_status "xbanish.service" "$icon_mousepointer" "user"
        service_status "systemd-resolved.service" "$icon_resolver"
        service_status "systemd-timesyncd.service" "$icon_timesync"
        service_status "sshd.service" "$icon_ssh"
        service_status "vpnc@hades.service" "$icon_vpn"
        service_status "cups.service" "$icon_printer"
        service_status "bluetooth.service" "$icon_bluetooth"

        polybar_helper_output.sh "%{T2}$services%{T-} "
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
