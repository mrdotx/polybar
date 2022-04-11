#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_openweathermap.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-04-11T20:33:26+0200

request() {
    city=
    gpg_file="$HOME/.local/share/repos/password-store/www/development/openweathermap.gpg"

    get_location() {
        url_geo="https://location.services.mozilla.com/v1/geolocate?key=geoclue"

        if [ "$1" -gt 0 ]; then
            printf "%s" "id=$1"
        elif [ -n "$1" ]; then
            printf "%s" "q=$*"
        else
            data=$(curl -sf "$url_geo")

            location_lat=$( \
                printf "%s\n" "$data" \
                    | awk -F '"lat": ' '{print $2}' \
                    | cut -d',' -f1 \
            )
            location_lng=$( \
                printf "%s\n" "$data" \
                    | awk -F '"lng": ' '{print $2}' \
                    | cut -d'}' -f1
            )

            printf "lat=%s&lon=%s" "$location_lat" "$location_lng"
        fi
    }

    get_apikey() {
        gpg -q -d "$1" \
            | grep "^api_key =" \
            | awk -F ' = ' '{print $2}'
    }

    url_api="https://api.openweathermap.org/data/2.5"
    url_para="appid=$(get_apikey "$gpg_file")&mode=xml&units=metric"

    curl -sf "$url_api/$1?$url_para&$(get_location "$city")"
}

get_data() {
    get_icon() {
        case  $1 in
            # https://openweathermap.org/weather-conditions
            01d) icon="";;
            01n) icon="";;
            02d) icon="";;
            02n) icon="";;
            03*) icon="";;
            04*) icon="";;
            09d) icon="";;
            09n) icon="";;
            10*) icon="";;
            11*) icon="";;
            13*) icon="";;
            50*) icon="";;
            *)   icon="";;
        esac

        printf "%s" "$icon"
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

    extract_data() {
        tag="$1"
        value="$2"
        shift 2

        printf "%s\n" "$@" \
            | awk -F "<$tag" '{print $2}' \
            | awk -F "$value=" '{print $2}' \
            | cut -d'"' -f2 \
            | sed '/^$/d'
    }

    current=$(request "weather")
    current_temp=$(printf "%.0f" "$(extract_data "temperature" "value" "$current")")
    current_icon=$(extract_data "temperature" "icon" "$current")
    current_sunrise=$(extract_data "sun" "rise" "$current")
    current_sunset=$(extract_data "sun" "set" "$current")

    current_output="$(get_icon "$current_icon") $current_temp°"

    forecast=$(request "forecast")
    forecast_temp=$(printf "%.0f" "$(extract_data "temperature" "value" "$forecast")")
    forecast_icon=$(extract_data "symbol" "var" "$forecast")

    forecast_output="$(get_icon "$forecast_icon") $forecast_temp°"

    if [ "$forecast_temp" -gt "$current_temp" ]; then
        trend=""
    elif [ "$current_temp" -gt "$forecast_temp" ]; then
        trend=""
    else
        trend=""
    fi

    now=$(date +%s)
    sunrise=$(convert_date "$current_sunrise" "Epoch")
    sunset=$(convert_date "$current_sunset" "Epoch")

    if [ "$sunrise" -ge "$now" ] \
        || [ "$now" -gt "$sunset" ]; then
        daytime=" $(convert_date "$sunrise")"
    elif [ "$sunset" -ge "$now" ]; then
        daytime=" $(convert_date "$sunset")"
    fi
}

case "$1" in
    --update)
        for id in $(pgrep -f "polybar main"); do
            polybar-msg -p "$id" \
                action "#weather.hook.0" >/dev/null 2>&1 &
        done
        ;;
    *)
        if polybar_helper_net_check.sh "openweathermap.org"; then
            get_data

            polybar_helper_output.sh \
                "$current_output $trend $forecast_output $daytime"
        fi
        ;;
esac
