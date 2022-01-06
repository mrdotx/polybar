#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_services.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-01-06T11:58:26+0100

line_color="Polybar.main0"
foreground_color="Polybar.foreground0"

# xresources
xresources() {
    xrdb_query() {
        xrdb -query \
            | grep "$1:" \
            | cut -f2
    }

    printf "%%{o%s}%%{F%s}%s%%{F- o-}" \
        "$(xrdb_query "$1")" \
        "$(xrdb_query "$2")" \
        "$message"
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
        service_status "i3_autotiling.service" "" "user"
        service_status "picom.service" "" "user"
        service_status "xbanish.service" "" "user"
        service_status "bluetooth.service" ""
        service_status "cups.service" ""
        service_status "systemd-resolved.service" ""
        service_status "sshd.service" ""
        service_status "systemd-timesyncd.service" ""
        service_status "vpnc@hades.service" ""

        xresources "$line_color" "$foreground_color"
        ;;
    --update)
        polybar-msg hook module/services 1 >/dev/null 2>&1
        ;;
    *)
        i3_services.sh
        ;;
esac
