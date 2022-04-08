#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-04-08T09:08:27+0200

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

# get xresources
get_bar_type() {
    xrdb -query \
        | grep "Polybar.type:" \
        | cut -f2
}

# set xresources
set_bar_type() {
    sed -i "/Polybar.type:/c\Polybar.type:        $1" "$config"
    xrdb -merge "$xresource"
}

cycle() {
    [ "$(systemctl --user is-active $service)" = "active" ] \
        && case "$(get_bar_type)" in
            single)
                set_bar_type multi
                ;;
            multi)
                set_bar_type stats
                ;;
            *)
                set_bar_type single
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
        case "$(get_bar_type)" in
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
