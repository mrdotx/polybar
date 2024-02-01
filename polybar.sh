#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2024-02-01T07:41:34+0100

service="polybar.service"

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
    $script --restart"

start() {
    # terminate already running bar instances
    polybar-msg cmd quit >/dev/null 2>&1

    # type = main, main_s, blank, sys_info, sys_info_s
    case "$(uname -n)" in
        m75q)
            monitor1="sys_info"
            monitor2="main"
            pin_i3=true
            ;;
        mi)
            monitor1="main"
            monitor2="sys_info"
            pin_i3=true
            ;;
        *)
            monitor1="main_s"
            pin_i3=false
            ;;
    esac

    primary=$(polybar -m \
        | grep "(primary)" \
        | cut -d ':' -f1 \
    )
    secondary=$(polybar -m \
        | grep -v "(primary)" \
        | head -n1 \
        | cut -d ':' -f1 \
    )

    if [ -n "$secondary" ]; then
        [ -n "$monitor1" ] \
            && I3PIN=$pin_i3 MONITOR=$primary polybar "$monitor1" &

        [ -n "$monitor2" ] \
            && I3PIN=$pin_i3 MONITOR=$secondary polybar "$monitor2" &
    elif [ -z "$monitor1" ]; then
        MONITOR=$primary polybar "$monitor2" &
    else
        MONITOR=$primary polybar "$monitor1" &
    fi
}

case "$1" in
    -h | --help)
        printf "%s\n" "$help"
        ;;
    --kill)
        polybar-msg cmd quit >/dev/null 2>&1
        ;;
    --restart)
        systemctl --user restart "$service"
        ;;
    --reload)
        polybar-msg cmd restart >/dev/null 2>&1
        ;;
    --toggle)
        polybar-msg cmd toggle >/dev/null 2>&1
        ;;
    *)
        start
        ;;
esac
