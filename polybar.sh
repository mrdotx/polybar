#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar.sh
# author: klassiker [mrdotx]
# url:    https://github.com/mrdotx/polybar
# date:   2025-12-18T06:23:43+0100

script=$(basename "$0")
help="$script [-h/--help] -- script to start polybar
  Usage:
    $script [--kill/--reload/--restart/--toggle]

  Settings:
    without given settings, re-/start polybar
    [--kill]     = terminate already running polybar instances
    [--reload]   = reload polybar modules
    [--restart]  = restart polybar
    [--toggle]   = toggle polybar visibility

  Example:
    $script
    $script --kill
    $script --reload
    $script --restart
    $script --toggle"

get_monitor() {
    polybar -m \
        | sed -n "${1}p" \
        | cut -d ':' -f1
}

quit_bar() {
    polybar-msg cmd quit >/dev/null 2>&1
}

case "$1" in
    -h | --help)
        printf "%s\n" "$help"
        ;;
    --kill)
        quit_bar
        ;;
    --restart)
        systemctl --user restart "polybar.service"
        ;;
    --reload)
        polybar-msg cmd restart >/dev/null 2>&1
        ;;
    --toggle)
        polybar-msg cmd toggle >/dev/null 2>&1
        ;;
    *)
        quit_bar

        primary=$(get_monitor 1)
        secondary=$(get_monitor 2)

        # bars: xwindow(_s), weather(_s), sys_info, blank
        case "$secondary" in
            "")
                MONITOR="$primary" BOTTOM="false" I3PIN="false" \
                    polybar "xwindow_s" &
                ;;
            *)
                MONITOR="$primary" BOTTOM="false" I3PIN="true" \
                    polybar "sys_info" &
                MONITOR="$secondary" BOTTOM="false" I3PIN="true" \
                    polybar "xwindow" &
                ;;
        esac
        ;;
esac
