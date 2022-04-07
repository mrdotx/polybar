#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_pacman.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-04-07T19:37:59+0200

icon_pacman=""
icon_aur=""

case "$1" in
    --update)
        polybar-msg -p "$(pgrep -f "polybar primary")" \
            action "#pacman.hook.0" >/dev/null 2>&1 &
        ;;
    *)
        if polybar_helper_net_check.sh; then
            updates_pacman=$(checkupdates 2> /dev/null | wc -l)
            updates_aur=$(paru -Qua 2> /dev/null | wc -l)

            if [ "$updates_pacman" -gt 0 ] \
                && [ "$updates_aur" -gt 0 ]; then \
                    polybar_helper_output.sh \
                        "$icon_pacman $updates_pacman $icon_aur $updates_aur"
            else
                [ "$updates_pacman" -gt 0 ] \
                    && polybar_helper_output.sh \
                        "$icon_pacman $updates_pacman"

                [ "$updates_aur" -gt 0 ] \
                    && polybar_helper_output.sh \
                        "$icon_aur $updates_aur"
            fi
        fi
        ;;
esac
