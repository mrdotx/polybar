#!/bin/sh

# path:       /home/klassiker/.local/share/repos/polybar/polybar.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-09-17T10:29:44+0200

script=$(basename "$0")
help="$script [-h/--help] -- script to start polybar
  Usage:
    $script [-t/-r]

  Settings:
    without given setting re-/start polybar
    -t = toggle between dual- and single bar
    -r = rotate single-/dual bar/disable/enable

  Example:
    $script
    $script -t
    $script -r"

service="polybar.service"

# xresources
dual_bar=$(printf "%s" "$(xrdb -query \
    | grep Polybar.dualbar: \
    | cut -f2)" \
)

# set xresources
set_dual_bar() {
    file="$HOME/.config/xorg/polybar"
    sed -i "/Polybar.dualbar:/c\Polybar.dualbar:        $1" "$file"
    xrdb -merge "$HOME/.config/xorg/Xresources"
}

toggle() {
    if [ "$dual_bar" = true ]; then
        set_dual_bar false
    else
        set_dual_bar true
    fi
        systemctl --user restart $service
}

rotate() {
    if [ "$(systemctl --user is-active $service)" = "active" ] \
        && [ "$dual_bar" = true ]; then
            systemctl --user disable $service --now
            set_dual_bar false
    elif [ "$(systemctl --user is-active $service)" = "active" ] \
        && [ "$dual_bar" = false ]; then
            toggle
    else
        systemctl --user enable $service --now
    fi
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
    -r)
        rotate
        ;;
    *)
        start
        ;;
esac
