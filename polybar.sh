#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2021-05-01T22:48:05+0200

service="polybar.service"

script=$(basename "$0")
help="$script [-h/--help] -- script to start polybar
  Usage:
    $script [-t/-r]

  Settings:
    without given settings, re-/start polybar
    -t = toggle between dual- and single bar
    -r = rotate single-/dual bar/disable/enable

  Example:
    $script
    $script -t
    $script -r"

# xresources
dual_bar=$(xrdb -query \
    | grep Polybar.dualbar: \
    | cut -f2 \
)

# set xresources
set_dual_bar() {
    file="$HOME/.config/xorg/polybar"
    sed -i "/Polybar.dualbar:/c\Polybar.dualbar:        $1" "$file"
    xrdb -merge "$HOME/.config/xorg/Xresources"
}

toggle() {
    case "$dual_bar" in
        true)
            set_dual_bar false
            ;;
        false)
            set_dual_bar true
            ;;
        *)
            exit 1
            ;;
    esac
    systemctl --user restart $service
}

rotate() {
    if [ "$(systemctl --user is-active $service)" = "active" ]; then
        case "$dual_bar" in
            true)
                systemctl --user disable $service --now
                set_dual_bar false
                ;;
            false)
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
    killall -q /usr/bin/polybar

    # wait until the processes have been shut down
    while pgrep -x /usr/bin/polybar >/dev/null; do
        sleep .1
    done

    # launch polybar
    primary=$(/usr/bin/polybar -m \
        | grep "(primary)" \
        | sed -e 's/:.*$//g' \
    )
    secondary=$(/usr/bin/polybar -m \
        | grep -v "(primary)" \
        | sed q1 \
        | sed -e 's/:.*$//g' \
    )

    if [ "$dual_bar" = true ] \
        && [ "$(polybar -m | wc -l)" -ge 2 ]; then
            MONITOR=$primary /usr/bin/polybar i3_primary_bar &
            MONITOR=$secondary /usr/bin/polybar i3_secondary_bar &
    else
        [ -n "$primary" ] \
            && secondary="$primary"
                MONITOR=$secondary /usr/bin/polybar i3_single_bar &
    fi
}

case "$1" in
    -h | --help)
        printf "%s\n" "$help"
        ;;
    -t)
        toggle
        ;;
    -r)
        rotate
        ;;
    *)
        sleep .1
        start
        ;;
esac
