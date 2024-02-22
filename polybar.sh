#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2024-02-21T13:15:27+0100

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

get_monitor() {
    polybar -m \
        | sed -n "${1}p" \
        | cut -d ':' -f1
}

quit_bar() {
    polybar-msg cmd quit >/dev/null 2>&1
}

exec_bar() {
    MONITOR="$1" BOTTOM="$2" I3PIN="$3" polybar "$4" &
}

start() {
    quit_bar

    primary=$(get_monitor 1)
    secondary=$(get_monitor 2)

    # type = blank, sys_info_s, sys_info, main_s, main
    case "$secondary" in
        "")
            exec_bar "$primary" "false" "false" "main_s"
            ;;
        *)
            exec_bar "$primary" "false" "true" "main"
            # secondary monitor by hostname
            case "$(uname -n)" in
                m75q)
                    exec_bar "$secondary" "true" "true" "sys_info"
                    ;;
                *)
                    exec_bar "$secondary" "false" "true" "sys_info"
                    ;;
            esac
            ;;
    esac
}

case "$1" in
    -h | --help)
        printf "%s\n" "$help"
        ;;
    --kill)
        quit_bar
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
