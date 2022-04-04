#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_services.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-04-04T17:51:12+0200

line_color="Polybar.main0"
foreground_color="Polybar.foreground0"

output() {
    # get xresources
    xrdb_query() {
        xrdb -query \
            | grep "$1:" \
            | cut -f2
    }

    printf "%%{o%s}%%{F%s}%s%%{F- o-}\n" \
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

        output "$line_color" "$foreground_color"
        ;;
    --update)
        bar_id=$(pgrep -f "polybar primary")
        polybar-msg -p "$bar_id" action "#services.hook.0" >/dev/null 2>&1 &
        ;;
    *)
        i3_services.sh
        ;;
esac
