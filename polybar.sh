#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-04-08T17:43:33+0200

config="$HOME/.config/X11/modules/polybar"
xresource="$HOME/.config/X11/Xresources"
service="polybar.service"

script=$(basename "$0")
help="$script [-h/--help] -- script to start polybar
  Usage:
    $script [-k/--kill/-r/--restart/-c/--cycle]

  Settings:
    without given settings, re-/start polybar
    [-k/--kill]    = kill single-/multi-/stats bar
    [-r/--restart] = restart polybar when it is running
    [-c/--cycle]   = cycle single-/multi- and stats bar

  Example:
    $script
    $script -k
    $script --kill
    $script -r
    $script --restart
    $script -c
    $script --cycle"

get_xresource() {
    xrdb -query \
        | grep "$1:" \
        | cut -f2
}

set_xresource() {
    sed -i "/$1:/c\\$1:        $2" "$config"
    xrdb -merge "$xresource"
}

cycle() {
    [ "$(systemctl --user is-active $service)" = "active" ] \
        && case "$(get_xresource "Polybar.type")" in
            single)
                set_xresource "Polybar.type" "multi"
                ;;
            multi)
                set_xresource "Polybar.type" "stats"
                ;;
            *)
                set_xresource "Polybar.type" "single"
                ;;
        esac \
        && systemctl --user restart $service
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

    if [ -n "$secondary" ]; then
        case "$(get_xresource "Polybar.type")" in
            multi)
                MONITOR=$primary polybar primary &
                MONITOR=$secondary polybar secondary &
                ;;
            stats)
                MONITOR=$primary polybar primary_stats &
                MONITOR=$secondary polybar secondary_stats &
                ;;
            *)
                MONITOR=$primary polybar primary_single &
                ;;
        esac
    else
        MONITOR=$primary polybar primary_single &
    fi
}

case "$1" in
    -h | --help)
        printf "%s\n" "$help"
        ;;
    -k | --kill)
        polybar-msg cmd quit >/dev/null 2>&1
        ;;
    -r | --restart)
        polybar-msg cmd restart >/dev/null 2>&1
        ;;
    -c | --cycle)
        cycle
        ;;
    *)
        start
        ;;
esac
