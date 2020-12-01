#!/bin/sh

# path:       /home/klassiker/.local/share/repos/polybar/polybar_services.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-12-01T21:32:48+0100

line_color="Polybar.linecolor0"
foreground_color="Polybar.foreground0"

# xresources
xresources() {
    printf "%%{o%s}%%{F%s}$message%%{F- o-}" "$(xrdb -query \
        | grep "$1:" \
        | cut -f2 \
    )" \
    "$(xrdb -query \
        | grep "$2:" \
        | cut -f2 \
    )"
}

service_status() {
    case "$3" in
        user)
            if [ "$(systemctl --user is-active "$1")" = "active" ]; then
                if [ -z "$message" ]; then
                    message="$(printf "%s" "$2")"
                else
                    message="$(printf "%s %s" "$message" "$2")"
                fi
            fi
            ;;
        *)
            if [ "$(systemctl is-active "$1")" = "active" ]; then
                if [ -z "$message" ]; then
                    message="$(printf "%s" "$2")"
                else
                    message="$(printf "%s %s" "$message" "$2")"
                fi
            fi
            ;;
    esac
}

case "$1" in
    --status)
        service_status "xautolock.service" "" "user"
        service_status "bluetooth.service" ""
        service_status "picom.service" "" "user"
        service_status "ufw.service" ""
        service_status "gestures.service" "" "user"
        service_status "xbanish.service" "" "user"
        service_status "systemd-resolved.service" ""
        service_status "cups.service" ""
        service_status "i3_tiling.service" "" "user"
        service_status "vpnc@hades.service" ""
        service_status "systemd-timesyncd.service" ""

        xresources "$line_color" "$foreground_color"
        ;;
    --update)
        polybar-msg hook module/services 1 >/dev/null 2>&1
        ;;
    *)
        i3_services.sh
        ;;
esac
