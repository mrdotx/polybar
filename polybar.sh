#!/bin/sh

# path:       /home/klassiker/.local/share/repos/polybar/polybar.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-09-13T11:09:04+0200

script=$(basename "$0")
help="$script [-h/--help] -- script to start polybar
  Usage:
    $script [settings]

  Settings:
    without given setting re-/start polybar
    -t = toggle between dual- and single bar

  Example:
    $script
    $script -t"

# xresources
dual_bar=$(printf "%s" "$(xrdb -query \
    | grep Polybar.dualbar: \
    | cut -f2)" \
)

toggle() {
    file="$HOME/.config/xorg/polybar"
    if [ "$dual_bar" = true ]; then
        sed -i "/Polybar.dualbar:/c\Polybar.dualbar:        false" "$file"
    else
        sed -i "/Polybar.dualbar:/c\Polybar.dualbar:        true" "$file"
    fi
    xrdb -merge "$HOME/.config/xorg/Xresources" \
        && systemctl --user restart polybar.service
}

start() {
    # terminate already running bar instances
    killall -q /usr/bin/polybar

    # wait until the processes have been shut down
    while pgrep -x /usr/bin/polybar >/dev/null; do
        sleep 0.1
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

    if [ "$dual_bar" = true ] && [ "$(polybar -m | wc -l)" -ge 2 ]; then
        MONITOR=$primary /usr/bin/polybar i3_dual_bar_primary &
        MONITOR=$secondary /usr/bin/polybar i3_dual_bar_secondary &
    else
        [ -n "$primary" ] && secondary="$primary"
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
    *)
        start
        ;;
esac
