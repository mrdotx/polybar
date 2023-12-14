#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2023-12-14T08:25:28+0100

config="$HOME/.config/X11/Xresources.d/polybar"
xresource="$HOME/.config/X11/Xresources"
service="polybar.service"

script=$(basename "$0")
help="$script [-h/--help] -- script to start polybar
  Usage:
    $script [--kill/--reload/--restart/--toggle/--monitor1/--monitor2]

  Settings:
    without given settings, re-/start polybar
    [--kill]     = terminate already running polybar instances
    [--reload]   = reload polybar modules
    [--restart]  = restart polybar
    [--toggle]   = toggle polybar visibility
    [--monitor1] = change bar on primary monitor
    [--monitor2] = change bar on secondary monitor

  Example:
    $script
    $script --kill
    $script --reload
    $script --restart
    $script --monitor1
    $script --monitor2"

get_xresource() {
    xrdb -query \
        | grep "$1:" \
        | cut -f2
}

set_xresource() {
    sed -i "/$1:/c\\$1:   $2" "$config"
    xrdb -merge "$xresource"
}

bars() {
    systemctl --user -q is-active "$service" \
        && case "$(get_xresource "Polybar.$1")" in
            main)
                set_xresource "Polybar.$1" "main_s"
                ;;
            main_s)
                set_xresource "Polybar.$1" "blank"
                ;;
            blank)
                set_xresource "Polybar.$1" "sys_info"
                ;;
            sys_info)
                set_xresource "Polybar.$1" "sys_info_s"
                ;;
            sys_info_s)
                monitor1="$(get_xresource "Polybar.monitor1")"
                monitor2="$(get_xresource "Polybar.monitor2")"

                if [ "$monitor1" = "disabled" ] \
                    || [ "$monitor2" = "disabled" ]; then
                        set_xresource "Polybar.$1" "main"
                else
                    set_xresource "Polybar.$1" "disabled"
                fi
                ;;
            *)
                set_xresource "Polybar.$1" "main"
                ;;
        esac
}

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

    monitor1="$(get_xresource "Polybar.monitor1")"
    monitor2="$(get_xresource "Polybar.monitor2")"

    if [ "$monitor1" = "disabled" ] \
        || [ "$monitor2" = "disabled" ]; then
            pin_i3=false
    else
        pin_i3=true
    fi

    if [ -n "$secondary" ]; then
        [ ! "$monitor1" = "disabled" ] \
            && I3PIN=$pin_i3 MONITOR=$primary polybar "$monitor1" &

        [ ! "$monitor2" = "disabled" ] \
            && I3PIN=$pin_i3 MONITOR=$secondary polybar "$monitor2" &
    elif [ "$monitor1" = "disabled" ]; then
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
    --monitor1 | --monitor2)
        bars "${1##*--}"
        ;;
    *)
        start
        ;;
esac
