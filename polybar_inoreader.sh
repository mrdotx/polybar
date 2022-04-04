#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_inoreader.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-04-04T08:33:29+0200

icon_rss=""
icon_star=""
line_color="Polybar.main0"
foreground_color="Polybar.foreground0"

url_login="https://www.inoreader.com/accounts/ClientLogin"
url_request="https://www.inoreader.com/reader/api/0/unread-count"
app_id="999999505"
app_key="EQsZICxpsbFczwbXrsrkRbXUUw8DdfwO"
user="klassiker"
pass=$( \
    gpg -q -d ~/.local/share/repos/password-store/www/social/inoreader.gpg \
        | head -n1 \
)

output() {
    # get xresources
    xrdb_query() {
        xrdb -query \
            | grep "$1:" \
            | cut -f2
    }

    printf "%%{o%s}%%{F%s}%s %s%%{F- o-}\n" \
        "$(xrdb_query "$1")" \
        "$(xrdb_query "$2")" \
        "$3" \
        "$4"
}

extract_data() {
    printf "%s" "$request" \
        | awk -F "$1" '{print $2}' \
        | cut -d ',' -f1 \
        | sed 's/"count"://' \
        | tr -d "\""
}

if sleep 1 && ping -c1 -W1 -q 1.1.1.1 >/dev/null 2>&1; then
    auth=$(curl --silent -s "$url_login?Email=$user&Passwd=$pass" \
        | grep 'Auth=' \
        | sed 's/Auth/auth/' \
    )

    request=$(curl --silent -H "Authorization: GoogleLogin $auth" \
        "$url_request?AppId=$app_id&AppKey=$app_key" \
    )

    output \
        "$line_color" \
        "$foreground_color" \
        "$icon_rss $(extract_data 'reading-list",')" \
        "$icon_star $(extract_data 'starred",')"
else
    output \
        "$line_color" \
        "$foreground_color" \
        "$icon_rss"
fi
