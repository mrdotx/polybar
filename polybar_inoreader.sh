#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_inoreader.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-11-26T15:07:35+0100

# speed up script by using standard c
LC_ALL=C
LANG=C

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

    get_auth() {
        curl -fsS "$url_login?Email=$user&Passwd=$(get_pass)" \
            | grep 'Auth=' \
            | sed 's/Auth/auth/'
    }

    curl -fsS -H "Authorization: GoogleLogin $(get_auth)" \
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
                action "#rss.hook.0" >/dev/null 2>&1 &
        done
        ;;
    *)
        basename=${0##*/}
        path=${0%"$basename"}

        ! "$path"helper/polybar_net_check.sh "inoreader.com" \
            && exit 1

        data=$(request)
        unreaded=$(extract_data "$data" 'reading-list",')
        starred=$(extract_data "$data" 'starred",')

        icon_rss="%{T2}參 %{T-}"
        icon_star="%{T2}留 %{T-}"

        if [ "$unreaded" -gt 0 ] \
            && [ "$starred" -gt 0 ]; then \
                "$path"helper/polybar_output.sh \
                    "$icon_rss$unreaded $icon_star$starred"
        else
            [ "$unreaded" -gt 0 ] \
                && "$path"helper/polybar_output.sh \
                    "$icon_rss$unreaded"

            [ "$starred" -gt 0 ] \
                && "$path"helper/polybar_output.sh \
                    "$icon_star$starred"
        fi
        ;;
esac
