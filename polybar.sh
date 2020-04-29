#!/bin/sh

# path:       /home/klassiker/.local/share/repos/polybar/polybar.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-04-29T22:41:44+0200

# xresources
dual_bar=$(printf "%s" "$(xrdb -query | grep Polybar.dualbar: | cut -f2)")

# terminate already running bar instances
killall -q polybar

# wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 0.1; done

# launch polybar
pri=$(polybar -m | grep "(primary)" | sed -e 's/:.*$//g')
if [ "$dual_bar" = true ] && [ "$(polybar -m | wc -l)" = 2 ]; then
    sec=$(polybar -m | grep -v "(primary)" | sed -e 's/:.*$//g')
    MONITOR=$pri polybar i3_2_mon_pri &
    MONITOR=$sec polybar i3_2_mon_sec &
else
    MONITOR=$pri polybar i3_1_mon &
fi
