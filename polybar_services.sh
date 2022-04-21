#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_services.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-04-21T11:39:00+0200

# speed up script by using posix
LC_ALL=C
LANG=C

service_status() {
    case "$3" in
        user)
            if systemctl --user -q is-active "$1"; then
                if [ -z "$services" ]; then
                    services="$(printf "%s" "$2")"
                else
                    services="$(printf "%s %s" "$services" "$2")"
                fi
            fi
            ;;
        *)
            if systemctl -q is-active "$1"; then
                if [ -z "$services" ]; then
                    services="$(printf "%s" "$2")"
                else
                    services="$(printf "%s %s" "$services" "$2")"
                fi
            fi
            ;;
    esac
}

case "$1" in
    --status)
        service_status "xautolock.service" "" "user"
        service_status "i3_autotiling.service" "" "user"
        service_status "picom.service" "" "user"
        service_status "xbanish.service" "" "user"
        service_status "bluetooth.service" ""
        service_status "cups.service" ""
        service_status "systemd-resolved.service" ""
        service_status "sshd.service" ""
        service_status "systemd-timesyncd.service" ""
        service_status "vpnc@hades.service" ""

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
