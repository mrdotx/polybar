#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2023-11-25T11:19:44+0100

config="$HOME/.config/X11/Xresources.d/polybar"
xresource="$HOME/.config/X11/Xresources"
service="polybar.service"

script=$(basename "$0")
help="$script [-h/--help] -- script to start polybar
  Usage:
    $script [--kill/--reload/--monitor1/--monitor2]

  Settings:
    without given settings, re-/start polybar
    [--kill]     = kill single-/multi-/stats bar
    [--reload]   = reload polybar when it is running
    [--monitor1] = cycle bars on primary monitor
    [--monitor2] = cycle bars on secondary monitor

  Example:
    $script
    $script --kill
    $script --reload
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

cycle() {
    systemctl --user -q is-active "$service" \
        && case "$(get_xresource "Polybar.$1")" in
            main)
                set_xresource "Polybar.$1" "main_small"
                ;;
            main_small)
                set_xresource "Polybar.$1" "empty"
                ;;
            empty)
                set_xresource "Polybar.$1" "sys_info"
                ;;
            sys_info)
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
        esac \
        && systemctl --user restart "$service"
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
    --reload)
        polybar-msg cmd restart >/dev/null 2>&1
        ;;
    --monitor1)
        cycle "monitor1"
        ;;
    --monitor2)
        cycle "monitor2"
        ;;
    *)
        start
        ;;
esac
