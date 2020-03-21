#!/bin/sh

# path:       ~/repos/polybar/polybar.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-03-21T22:13:01+0100

pri=$(polybar -m | grep "(primary)" | sed -e 's/:.*$//g')
sec=$(polybar -m | grep -v "(primary)" | sed -e 's/:.*$//g')

# terminate already running bar instances
killall -q polybar

# wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 0.1; done

# launch polybar
if [ "$(polybar -m | wc -l)" = 2 ]; then
    MONITOR=$pri polybar i3_2_mon_pri &
    MONITOR=$sec polybar i3_2_mon_sec &
else
    MONITOR=$pri polybar i3_1_mon &
fi
