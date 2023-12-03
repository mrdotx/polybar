#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_services.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2023-12-01T20:31:43+0100

# speed up script by using standard c
LC_ALL=C
LANG=C

# source polybar helper
. polybar_helper.sh

set_output() {
    if [ -z "$services" ]; then
        services="$(printf "%s" "$1")"
    else
        services="$(printf "%s %s" "$services" "$1")"
    fi
}

service_status() {
    case "$3" in
        wireguard)
            [ "$(wireguard_toggle.sh -s "$1")" = "$1 is enabled" ] \
                && set_output "$2"
            ;;
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
        service_status "xautolock.service" "󰌾" "user"
        service_status "i3_autotiling.service" "󰕴" "user"
        service_status "picom.service" "󰗌" "user"
        service_status "wacom.service" "󰏪" "user"
        service_status "xbanish.service" "󰇀" "user"
        service_status "sshd.service" "󰒒"
        service_status "wg0" "󰒄" "wireguard"
        service_status "cups.service" "󰐪"
        service_status "bluetooth.service" "󰂯"

        polybar_output "%{T2}$services%{T-} "
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
