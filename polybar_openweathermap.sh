#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_openweathermap.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-06-21T20:34:08+0200

# speed up script by using standard c
LC_ALL=C
LANG=C

# data for openweathermap in gpg file
# api key (needed):     api_key = a2d833bfaa8912dc090fd547e109cf13
# city id (optional):   city_id = 2867714
# without city id the location is determined by geoip.me
gpg_file="$HOME/.local/share/repos/password-store/www/development/openweathermap.gpg"

# https://openweathermap.org/weather-conditions
icon_01d=""    icon_01n=""
icon_02d=""    icon_02n=""
icon_03x=""
icon_04x=""
icon_09d=""    icon_09n=""
icon_10d=""    icon_10n=""
icon_11d=""    icon_11n=""
icon_13d=""    icon_13n=""
icon_50x=""

icon_71x="勤"   icon_72x="免"   icon_73x="勉"
icon_81x="琢"
icon_91x="瀞"   icon_92x="漢"
icon_99x=""

notification() {
    title="Weather Icons"
    table_header="────┬────┬──────────────────┬────"
    message=$(printf "%s\n" \
        "<i>OpenWeather</i>\n$table_header" \
        " $icon_01d  │ $icon_01n  │ clear sky        │ 01" \
        " $icon_02d  │ $icon_02n  │ few clouds       │ 02" \
        " $icon_03x  │ $icon_03x  │ scattered clouds │ 03" \
        " $icon_04x  │ $icon_04x  │ broken clouds    │ 04" \
        " $icon_09d  │ $icon_09n  │ shower rain      │ 09" \
        " $icon_10d  │ $icon_10n  │ rain             │ 10" \
        " $icon_11d  │ $icon_11n  │ thunderstorm     │ 11" \
        " $icon_13d  │ $icon_13n  │ snow             │ 13" \
        " $icon_50x  │ $icon_50x  │ mist             │ 50" \
        "\n<i>Other</i>\n$table_header" \
        " $icon_71x  │ $icon_71x  │ trend up         │ 71" \
        " $icon_72x  │ $icon_72x  │ trend down       │ 72" \
        " $icon_73x  │ $icon_73x  │ trend neutral    │ 73" \
        " $icon_81x  │ $icon_81x  │ precipitation    │ 81" \
        " $icon_91x  │ $icon_91x  │ sunrise          │ 91" \
        " $icon_92x  │ $icon_92x  │ sunset           │ 92" \
        " $icon_99x  │ $icon_99x  │ not available    │   " \
    )

    notify-send \
        -t 0 \
        -u normal \
        "$title" \
        "\n$message" \
        -h string:x-canonical-private-synchronous:"$title"
}

format_icon() {
    case $1 in
        01d) icon="$icon_01d";;
        01n) icon="$icon_01n";;
        02d) icon="$icon_02d";;
        02n) icon="$icon_02n";;
        03*) icon="$icon_03x";;
        04*) icon="$icon_04x";;
        09d) icon="$icon_09d";;
        09n) icon="$icon_09n";;
        10d) icon="$icon_10d";;
        10n) icon="$icon_10n";;
        11d) icon="$icon_11d";;
        11n) icon="$icon_11n";;
        13d) icon="$icon_13d";;
        13n) icon="$icon_13n";;
        50*) icon="$icon_50x";;
        71x) icon="$icon_71x";;
        72x) icon="$icon_72x";;
        73x) icon="$icon_73x";;
        81x) icon="$icon_81x";;
        91x) icon="$icon_91x";;
        92x) icon="$icon_92x";;
        *)   icon="$icon_99x";;
    esac

    printf "%%{T2}%s %%{T-}" "$icon"
}

extract_json() {
    tag="$1"
    shift

    printf "%s\n" "$*" \
        | awk -F "\"$tag\": " '{print $2}' \
        | cut -d"," -f1 \
        | sed '/^$/d'
}

extract_xml() {
    tag="$1"
    value="$2"
    shift 2

    printf "%s\n" "$*" \
        | awk -F "<$tag" '{print $2}' \
        | awk -F "$value=" '{print $2}' \
        | cut -d'"' -f2 \
        | sed '/^$/d'
}

convert_date() {
    case $2 in
        Epoch)
            TZ=UTC date -d "$1" +%s
            ;;
        *)
            date -d "@$1" +%H:%M
            ;;
    esac
}

get_gpg_data() {
    gpg -q -d "$1" \
        | grep "^$2 =" \
        | awk -F ' = ' '{print $2}'
}

get_location() {
    if [ "$1" -gt 0 ]; then
        printf "%s" "id=$1"
    elif [ -n "$1" ]; then
        printf "%s" "q=$*"
    else
        data=$(curl -fsS -H 'Accept: */json' "https://geoip.me")

        location_lat=$(extract_json "latitude" "$data")
        location_lng=$(extract_json "longitude" "$data")

        printf "lat=%s&lon=%s" "$location_lat" "$location_lng"
    fi
}

request() {
    url_api="https://api.openweathermap.org/data/2.5/$1"
    url_appid="appid=$(get_gpg_data "$gpg_file" "api_key")"
    url_para="mode=xml&units=metric"

    city=$(get_gpg_data "$gpg_file" "city_id")

    curl -sf "$url_api?$url_appid&$url_para&$(get_location "$city")"
}

get_data() {
    # request data
    # https://openweathermap.org/current
    current_data=$(request "weather")
    # https://openweathermap.org/forecast5
    forecast_data=$(request "forecast")

    # current
    current_temp=$(printf "%.0f" \
        "$(extract_xml "temperature" "value" "$current_data")" \
    )
    current_icon=$(extract_xml "temperature" "icon" "$current_data")
    current="$(format_icon "$current_icon") $current_temp°"

    # forecast
    forecast_temp=$(printf "%.0f" \
        "$(extract_xml "temperature" "value" "$forecast_data")" \
    )
    forecast_icon=$(extract_xml "symbol" "var" "$forecast_data")
    if [ "$current_icon" = "$forecast_icon" ]; then
        forecast="$forecast_temp°"
    elif [ "$forecast_temp" -eq "$current_temp" ]; then
        forecast="$(format_icon "$forecast_icon") "
    else
        forecast="$(format_icon "$forecast_icon") $forecast_temp°"
    fi

    # weather
    if [ "$forecast_temp" -gt "$current_temp" ]; then
        weather="$current $(format_icon "71x")$forecast"
    elif [ "$current_temp" -gt "$forecast_temp" ]; then
        weather="$current $(format_icon "72x")$forecast"
    elif [ "$current_icon" = "$forecast_icon" ]; then
        weather="$current"
    else
        weather="$current $(format_icon "73x")$forecast"
    fi

    # precipitation
    forecast_precipitation=$(printf "%.0f" \
        "$(printf "%s * 100\n" \
            "$(extract_xml "precipitation" "probability" "$forecast_data")" \
            | bc -l \
        )" \
    )
    [ "$forecast_precipitation" -gt 0 ] \
        && precipitation=" $(format_icon "81x")$forecast_precipitation%"

    # sun
    current_sunrise=$(extract_xml "sun" "rise" "$current_data")
    current_sunset=$(extract_xml "sun" "set" "$current_data")

    now=$(date +%s)
    sunrise=$(convert_date "$current_sunrise" "Epoch")
    sunset=$(convert_date "$current_sunset" "Epoch")

    if [ "$sunrise" -ge "$now" ] \
        || [ "$now" -gt "$sunset" ]; then
        sun=" $(format_icon "91x")$(convert_date "$sunrise")"
    else
        sun=" $(format_icon "92x")$(convert_date "$sunset")"
    fi
}

case "$1" in
    --notify)
        notification
        ;;
    --update)
        for id in $(pgrep -f "polybar main"); do
            polybar-msg -p "$id" \
                action "#weather.hook.0" >/dev/null 2>&1 &
        done
        ;;
    *)
        basename=${0##*/}
        path=${0%"$basename"}

        ! "$path"helper/polybar_net_check.sh "openweathermap.org" \
            && exit 1

        get_data
        "$path"helper/polybar_output.sh "$weather$precipitation$sun"
        ;;
esac
