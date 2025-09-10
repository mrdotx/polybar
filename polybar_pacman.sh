#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_pacman.sh
# author: klassiker [mrdotx]
# url:    https://github.com/mrdotx/polybar
# date:   2025-09-10T04:36:08+0200

# use standard c to identify paru ignored updates
LC_ALL=C
LANG=C

# source polybar helper
. _polybar_helper.sh

get_pacman_mirror() {
    grep '^Server' /etc/pacman.d/mirrorlist \
        | head -n1 \
        | cut -d'/' -f3
}

case "$1" in
    --update)
        for id in $(pgrep -f "polybar main"); do
            polybar-msg -p "$id" \
                action "#packages.hook.0" >/dev/null 2>&1 &
        done
        ;;
    *)
        polybar_net_check "$(get_pacman_mirror)" \
            || exit 1

        updates_pacman=$(checkupdates --nocolor 2> /dev/null | wc -l)
        updates_aur=$(paru -Qua 2> /dev/null | grep -c -v "\[ignored\]")

        icon_pacman="%{T2}󰏗 %{T-}"
        icon_aur="%{T2}󰏖 %{T-}"

        if [ "$updates_pacman" -gt 0 ] \
            && [ "$updates_aur" -gt 0 ]; then \
                polybar_output \
                    "$icon_pacman$updates_pacman $icon_aur$updates_aur"
        else
            [ "$updates_pacman" -gt 0 ] \
                && polybar_output \
                    "$icon_pacman$updates_pacman"

            [ "$updates_aur" -gt 0 ] \
                && polybar_output \
                    "$icon_aur$updates_aur"
        fi
        ;;
esac
