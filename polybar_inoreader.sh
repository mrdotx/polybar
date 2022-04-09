#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_inoreader.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-04-09T08:48:20+0200

icon_rss=""
icon_star=""

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

case "$1" in
    --update)
        for id in $(pgrep -f "polybar main"); do
            polybar-msg -p "$id" \
                action "#inoreader.hook.0" >/dev/null 2>&1 &
        done
        ;;
    *)
        if polybar_helper_net_check.sh; then
            data=$(request)
            unreaded=$(extract_data "$data" 'reading-list",')
            starred=$(extract_data "$data" 'starred",')

            if [ "$unreaded" -gt 0 ] \
                && [ "$starred" -gt 0 ]; then \
                    polybar_helper_output.sh \
                        "$icon_rss $unreaded $icon_star $starred"
            else
                [ "$unreaded" -gt 0 ] \
                    && polybar_helper_output.sh \
                        "$icon_rss $unreaded"

                [ "$starred" -gt 0 ] \
                    && polybar_helper_output.sh \
                        "$icon_star $starred"
            fi
        fi
        ;;
esac
