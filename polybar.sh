#!/bin/sh

# path:       /home/klassiker/.local/share/repos/polybar/polybar.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-06-06T09:22:00+0200

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

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    printf "%s\n" "$help"
    exit 0
fi

# xresources
dual_bar=$(printf "%s" "$(xrdb -query \
    | grep Polybar.dualbar: \
    | cut -f2)" \
)

tog() {
    file="$HOME/.config/xorg/polybar"
    if [ "$dual_bar" = true ]; then
        sed -i "/Polybar.dualbar:/c\Polybar.dualbar:        false" "$file"
    else
        sed -i "/Polybar.dualbar:/c\Polybar.dualbar:        true" "$file"
    fi
    xrdb -merge "$HOME/.config/xorg/Xresources" \
        && systemctl --user restart polybar.service
}

st() {
    # terminate already running bar instances
    killall -q polybar

    # wait until the processes have been shut down
    while pgrep -x polybar >/dev/null; do sleep 0.1; done

    # launch polybar
    pri=$(polybar -m \
        | grep "(primary)" \
        | sed -e 's/:.*$//g' \
    )
    sec=$(polybar -m \
        | grep -v "(primary)" \
        | sed q1 \
        | sed -e 's/:.*$//g' \
    )

    if [ "$dual_bar" = true ] && [ "$(polybar -m | wc -l)" -ge 2 ]; then
        MONITOR=$pri polybar i3_2_mon_pri &
        MONITOR=$sec polybar i3_2_mon_sec &
    else
        [ -n "$pri" ] && sec="$pri"
        MONITOR=$sec polybar i3_1_mon &
    fi
}

case "$1" in
    -t)
        tog
        ;;
    *)
        st
        ;;
esac
