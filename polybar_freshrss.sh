#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_freshrss.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-11-28T11:05:38+0100

# speed up script by using standard c
LC_ALL=C
LANG=C

# config
user="klassiker"
gpg_file="$HOME/.local/share/repos/password-store/www/development/freshrss.gpg"
url_login="http://pi/freshrss/api/greader.php/accounts/ClientLogin"
url_request="http://pi/freshrss/api/greader.php/reader/api/0"
url_parameter="?output=json"

request() {
    get_pass() {
        gpg -q -d "$gpg_file" \
            | head -n1
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
        | sed "s/$2/##FILTER##\n/g" \
        | grep -c "##FILTER##"
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

        ! "$path"helper/polybar_net_check.sh "pi" \
            && exit 1

        unreaded=$(request "unread-count")
        unreaded=$(get_count "$unreaded" 'reading-list",')
        starred=$(request "stream/contents/user/-/state/com.google/starred")
        starred=$(count_string "$starred" '{"id":"tag')

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
