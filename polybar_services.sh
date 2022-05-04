#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_services.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-05-04T10:32:31+0200

# speed up script by using standard c
LC_ALL=C
LANG=C

icon_spacer="  "
icon_autolock="%{T2}ﱱ%{T-}"
icon_autotiling="%{T2}﬿%{T-}"
icon_compositor="%{T2}%{T-}"
icon_mousepointer="%{T2}%{T-}"
icon_resolver="%{T2}%{T-}"
icon_timesync="%{T2}%{T-}"
icon_ssh="%{T2}%{T-}"
icon_vpn="%{T2}旅%{T-}"
icon_printer="%{T2}朗%{T-}"
icon_bluetooth="%{T2}%{T-}"

service_status() {
    case "$3" in
        user)
            if systemctl --user -q is-active "$1"; then
                if [ -z "$services" ]; then
                    services="$(printf "%s" "$2")"
                else
                    services="$(printf "%s%s%s" "$services" "$icon_spacer" "$2")"
                fi
            fi
            ;;
        *)
            if systemctl -q is-active "$1"; then
                if [ -z "$services" ]; then
                    services="$(printf "%s" "$2")"
                else
                    services="$(printf "%s%s%s" "$services" "$icon_spacer" "$2")"
                fi
            fi
            ;;
    esac
}

case "$1" in
    --status)
        service_status "xautolock.service" "$icon_autolock" "user"
        service_status "i3_autotiling.service" "$icon_autotiling" "user"
        service_status "picom.service" "$icon_compositor" "user"
        service_status "xbanish.service" "$icon_mousepointer" "user"
        service_status "systemd-resolved.service" "$icon_resolver"
        service_status "systemd-timesyncd.service" "$icon_timesync"
        service_status "sshd.service" "$icon_ssh"
        service_status "vpnc@hades.service" "$icon_vpn"
        service_status "cups.service" "$icon_printer"
        service_status "bluetooth.service" "$icon_bluetooth"

        polybar_helper_output.sh "$services"
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
