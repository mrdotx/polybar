#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2024-02-21T07:30:13+0100

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

    primary=$(polybar -m \
        | grep "(primary)" \
        | cut -d ':' -f1 \
    )
    secondary=$(polybar -m \
        | grep -v "(primary)" \
        | head -n1 \
        | cut -d ':' -f1 \
    )

    # type = blank, sys_info_s, sys_info, main_s, main
    case "$secondary" in
        "")
            primary_bar="main_s"
            primary_bottom="false"
            pin_i3=false

            I3PIN=$pin_i3 MONITOR=$primary BOTTOM=$primary_bottom \
                polybar "$primary_bar" &
            ;;
        *)
            primary_bar="main"
            primary_bottom="false"
            secondary_bar="sys_info"
            secondary_bottom="false"
            pin_i3=true

            # exceptions by hostname
            [ "$(uname -n)" = "m75q" ] \
                && secondary_bottom="true"

            I3PIN=$pin_i3 MONITOR=$primary BOTTOM=$primary_bottom \
                polybar "$primary_bar" &
            I3PIN=$pin_i3 MONITOR=$secondary BOTTOM=$secondary_bottom \
                polybar "$secondary_bar" &
            ;;
    esac
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
