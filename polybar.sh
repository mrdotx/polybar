#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-02-16T18:28:58+0100

config="$HOME/.config/X11/modules/polybar"
xresource="$HOME/.config/X11/Xresources"
service="polybar.service"
battery="/sys/class/power_supply/BAT0"

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

# xresources
bar_type=$(xrdb -query \
    | grep Polybar.type: \
    | cut -f2 \
)

# set xresources
set_bar_type() {
    sed -i "/Polybar.type:/c\Polybar.type:           $1" "$config"
    xrdb -merge "$xresource"
}

cycle() {
    [ "$(systemctl --user is-active $service)" = "active" ] \
        && case "$bar_type" in
            single)
                set_bar_type multi
                ;;
            multi)
                set_bar_type stats
                ;;
            stats)
                set_bar_type single
                ;;
            *)
                exit 1
                ;;
        esac \
        && systemctl --user restart $service
}

start() {
    # terminate already running bar instances
    killall -q polybar

    # wait until the processes have been shut down
    while pgrep -x polybar >/dev/null; do
        sleep .1
    done

    primary=$(polybar -m \
        | grep "(primary)" \
        | cut -d ':' -f1 \
    )
    secondary=$(polybar -m \
        | grep -v "(primary)" \
        | head -n1 \
        | cut -d ':' -f1 \
    )

    if [ "$(polybar -m | wc -l)" -ge 2 ]; then
        case $bar_type in
            multi)
                MONITOR=$primary polybar primary &
                if [ -d $battery ]; then
                    MONITOR=$secondary polybar laptop_secondary &
                else
                    MONITOR=$secondary polybar secondary &
                fi
                ;;
            stats)
                MONITOR=$primary polybar primary_stats &
                if [ -d $battery ]; then
                    MONITOR=$secondary polybar laptop_secondary_stats &
                else
                    MONITOR=$secondary polybar secondary_stats &
                fi
                ;;
        esac
    else
        if [ -d $battery ]; then
            MONITOR=$primary polybar laptop_single &
        else
            MONITOR=$primary polybar single &
        fi
    fi
}

case "$1" in
    -h | --help)
        printf "%s\n" "$help"
        ;;
    -k | --kill)
        killall -q polybar
        ;;
    -r | --restart)
        [ "$(systemctl --user is-active $service)" = "active" ] \
            && systemctl --user restart $service
        ;;
    -c | --cycle)
        cycle
        ;;
    *)
        start
        ;;
esac
