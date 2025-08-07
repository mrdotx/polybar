#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_freshrss.sh
# author: klassiker [mrdotx]
# url:    https://github.com/mrdotx/polybar
# date:   2025-08-07T05:34:03+0200

# speed up script by using standard c
LC_ALL=C
LANG=C

# config (password can be plain text or a gpg file path)
user="klassiker"
password="$HOME/.local/share/repos/password-store/www/development/freshrss_api.gpg"
url_login="http://m625q/freshrss/api/greader.php/accounts/ClientLogin"
url_request="http://m625q/freshrss/api/greader.php/reader/api/0"
url_parameter="?output=json"

# source polybar helper
. _polybar_helper.sh

request() {
    get_pass() {
        if [ -e "$password" ]; then
            gpg -q -d "$password" \
                | head -n1
        else
            printf "%s" "$password"
        fi
    }

    get_auth() {
        curl -fsS "$url_login?Email=$user&Passwd=$(get_pass)" \
            | grep 'Auth=' \
            | sed 's/Auth/auth/'
    }

    curl -fsS -H "Authorization:GoogleLogin $(get_auth)" \
        "$url_request/$1$url_parameter"
}

get_count() {
    printf "%s" "$1" \
        | awk -F "$2" '{print $2}' \
        | cut -d ',' -f1 \
        | sed 's/"count"://' \
        | tr -d "\""
}

count_string() {
    printf "%s" "$1" \
        | sed "s/$2/$2\n/g" \
        | grep -c "$2"
}

case "$1" in
    --update)
        for id in $(pgrep -f "polybar main"); do
            polybar-msg -p "$id" \
                action "#rss.hook.0" >/dev/null 2>&1 &
        done
        ;;
    *)
        polybar_net_check "m625q" \
            || exit 1

        unreaded=$(request "unread-count")
        unreaded=$(get_count "$unreaded" 'reading-list",')
        starred=$(request "stream/contents/user/-/state/com.google/starred")
        starred=$(count_string "$starred" '{"id":"tag')

        icon_rss="%{T2}󰑬 %{T-}"
        icon_star="%{T2}󰓎 %{T-}"

        if [ "$unreaded" -gt 0 ] \
            && [ "$starred" -gt 0 ]; then \
                polybar_output "$icon_rss$unreaded $icon_star$starred"
        else
            [ "$unreaded" -gt 0 ] \
                && polybar_output "$icon_rss$unreaded"

            [ "$starred" -gt 0 ] \
                && polybar_output "$icon_star$starred"
        fi
        ;;
esac
