#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2021-11-22T18:00:34+0100

config="$HOME/.config/X11/modules/polybar"
xresource="$HOME/.config/X11/Xresources"
service="polybar.service"

script=$(basename "$0")
help="$script [-h/--help] -- script to start polybar
  Usage:
    $script [-k/-r/-t]

  Settings:
    without given settings, re-/start polybar
    -k = kill single-/multi-/stats bar
    -r = rotate single-/multi-/stats bar disable/enable
    -t = toggle between single-/multi- and stats bar

  Example:
    $script
    $script -k
    $script -r
    $script -t"

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

toggle() {
    case "$bar_type" in
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
    esac
    systemctl --user restart $service
}

rotate() {
    if [ "$(systemctl --user is-active $service)" = "active" ]; then
        case "$bar_type" in
            stats)
                systemctl --user disable $service --now
                set_bar_type single
                ;;
            multi)
                toggle
                ;;
            single)
                toggle
                ;;
            *)
                exit 1
                ;;
        esac
    else
        systemctl --user enable $service --now
    fi
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
                MONITOR=$secondary polybar secondary &
                ;;
            stats)
                MONITOR=$primary polybar primary_stats &
                MONITOR=$secondary polybar secondary_stats &
                ;;
            *)
                MONITOR=$primary polybar single &
                ;;
        esac
    else
        MONITOR=$primary polybar single &
    fi
}

case "$1" in
    -h | --help)
        printf "%s\n" "$help"
        ;;
    -k)
        killall -q polybar
        ;;
    -r)
        rotate
        ;;
    -t)
        toggle
        ;;
    *)
        start
        ;;
esac
