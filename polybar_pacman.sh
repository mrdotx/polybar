#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_pacman.sh
# author: klassiker [mrdotx]
# url:    https://github.com/mrdotx/polybar
# date:   2026-03-08T05:19:20+0100

# use standard c to identify paru ignored updates
LC_ALL=C
LANG=C

# source polybar helper
. _polybar_helper.sh

get_pacman_updates() {
    pacman_mirror=$(grep '^Server' /etc/pacman.d/mirrorlist \
        | head -n1 \
        | cut -d'/' -f3
    )

    polybar_net_check "$pacman_mirror" \
        && updates_pacman=$(checkupdates --nocolor 2> /dev/null | wc -l)
}

get_aur_updates() {
    polybar_net_check "aur.archlinux.org" \
        && updates_aur=$(paru -Qua 2> /dev/null | grep -c -v "\[ignored\]")
}

output_data() {
    icon_pacman="%{T2}󰏗 %{T-}"
    icon_aur="%{T2}󰏖 %{T-}"

    if [ "${updates_pacman:-0}" -gt 0 ] && [ "${updates_aur:-0}" -gt 0 ]; then \
        polybar_output "$icon_pacman$updates_pacman $icon_aur$updates_aur"
    else
        [ "${updates_pacman:-0}" -gt 0 ] \
            && polybar_output "$icon_pacman$updates_pacman"

        [ "${updates_aur:-0}" -gt 0 ] \
            && polybar_output "$icon_aur$updates_aur"
    fi
}

case "$1" in
    --update)
        for id in $(pgrep -fx "polybar (weather.*|xwindow.*)"); do
            polybar-msg -p "$id" \
                action "#packages.hook.0" >/dev/null 2>&1 &
        done
        ;;
    --pacman)
        get_pacman_updates
        output_data
        ;;
    --aur)
        get_aur_updates
        output_data
        ;;
    *)
        get_pacman_updates
        get_aur_updates
        output_data
        ;;
esac
