#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_inoreader.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2024-12-18T07:53:12+0100

# speed up script by using standard c
LC_ALL=C
LANG=C

# config (password can be plain text or a gpg file path)
user="klassiker"
password="$HOME/.local/share/repos/password-store/www/social/inoreader.gpg"
app_id="999999505"
app_key="EQsZICxpsbFczwbXrsrkRbXUUw8DdfwO"
url_login="https://www.inoreader.com/accounts/ClientLogin"
url_request="https://www.inoreader.com/reader/api/0"
url_parameter="?AppId=$app_id&AppKey=$app_key"

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

    curl -fsS -H "Authorization: GoogleLogin $(get_auth)" \
        "$url_request/$1$url_parameter"
}

get_count() {
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
        polybar_net_check "inoreader.com" \
            || exit 1

        data=$(request "unread-count")
        unreaded=$(get_count "$data" 'reading-list",')
        starred=$(get_count "$data" 'starred",')

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
