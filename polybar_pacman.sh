#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_pacman.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-05-03T11:29:19+0200

# use standard c to identify paru ignored updates
LC_ALL=C
LANG=C

icon_pacman=" "
icon_aur=" "

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
        if polybar_helper_net_check.sh "$(get_pacman_mirror)"; then
            updates_pacman=$(checkupdates 2> /dev/null | wc -l)
            updates_aur=$(paru -Qua | grep -c -v "\[ignored\]" 2> /dev/null)

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
