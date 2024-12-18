#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/_polybar_helper.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2024-12-18T07:53:02+0100

polybar_add_spacer() {
    polybar_add_spacer_output="$1"
    polybar_add_spacer_i=$(($2 - ${#1}))

    while [ "$polybar_add_spacer_i" -gt 0 ]; do
        polybar_add_spacer_output="$polybar_add_spacer_output "
        polybar_add_spacer_i=$((polybar_add_spacer_i - 1))
    done

    printf "%s" "$polybar_add_spacer_output"
}

polybar_output() {
    # xresource value for foreground color (default Polybar.foreground)
    polybar_output_foreground_color=${2:-Polybar.foreground}

    xrdb_query() {
        xrdb -query \
            | grep "$1:" \
            | cut -f2
    }

    printf "%%{F%s}%s%%{F-}\n" \
        "$(xrdb_query "$polybar_output_foreground_color")" \
        "$1"
}

polybar_net_check() {
    # check ip/address to connect to (default 1.1.1.1)
    polybar_net_check_address=${1:-1.1.1.1}
    # check connection for x tenth of a second (default 50)
    polybar_net_check_interval=${2:-50}

    while ! ping -c1 -W1 -q "$polybar_net_check_address" >/dev/null 2>&1 \
        && [ "$polybar_net_check_interval" -gt 0 ]; do
            sleep .1
            polybar_net_check_interval=$((polybar_net_check_interval - 1))
    done

    case "$polybar_net_check_interval" in
        0)
            exit 1
            ;;
    esac
}
