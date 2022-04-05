#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_inoreader.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-04-05T09:01:48+0200

icon_rss=""
icon_star=""
line_color="Polybar.main0"
foreground_color="Polybar.foreground0"

net_check() {
    # check connection x tenth of a second
    check=$1

    while ! ping -c1 -W1 -q "$2" >/dev/null 2>&1 \
        && [ "$check" -gt 0 ]; do
            sleep .1
            check=$((check - 1))
    done

    if [ $check -eq 0 ]; then
        return 1
    else
        return 0
    fi
}

request() {
    url_login="https://www.inoreader.com/accounts/ClientLogin"
    url_request="https://www.inoreader.com/reader/api/0/unread-count"
    user="klassiker"
    gpg_file="$HOME/.local/share/repos/password-store/www/social/inoreader.gpg"
    app_id="999999505"
    app_key="EQsZICxpsbFczwbXrsrkRbXUUw8DdfwO"

    get_pass() {
        gpg -q -d "$gpg_file" \
            | head -n1
    }

    curl --silent -H "Authorization: GoogleLogin $( \
        curl --silent -s "$url_login?Email=$user&Passwd=$(get_pass)" \
            | grep 'Auth=' \
            | sed 's/Auth/auth/' \
        )" \
        "$url_request?AppId=$app_id&AppKey=$app_key"
}

extract_data() {
    printf "%s" "$1" \
        | awk -F "$2" '{print $2}' \
        | cut -d ',' -f1 \
        | sed 's/"count"://' \
        | tr -d "\""
}

output() {
    # get xresources
    xrdb_query() {
        xrdb -query \
            | grep "$1:" \
            | cut -f2
    }

    printf "%%{o%s}%%{F%s}%s%%{F- o-}\n" \
        "$(xrdb_query "$line_color")" \
        "$(xrdb_query "$foreground_color")" \
        "$1"
}

case "$1" in
    --update)
        polybar-msg -p "$(pgrep -f "polybar primary")" \
            action "#inoreader.hook.0" >/dev/null 2>&1 &
        ;;
    *)
        if net_check 50 "1.1.1.1"; then
            data=$(request)
            unreaded=$(extract_data "$data" 'reading-list",')
            starred=$(extract_data "$data" 'starred",')

            if [ "$unreaded" -gt 0 ] \
                && [ "$starred" -gt 0 ]; then \
                    output "$icon_rss $unreaded $icon_star $starred"
            else
                [ "$unreaded" -gt 0 ] \
                    && output "$icon_rss $unreaded"

                [ "$starred" -gt 0 ] \
                    && output "$icon_star $starred"
            fi
        fi
        ;;
esac
