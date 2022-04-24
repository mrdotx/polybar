#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_openweathermap.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-04-24T08:02:49+0200

# speed up script by using standard c
LC_ALL=C
LANG=C

request() {
    # needed/optional data from openweathermap in gpg file
    # needed api key: api_key = a2d...
    # optional city id (eg munich): city_id = 2867714
    # without city id the location is determined by mozilla service
    gpg_file="$HOME/.local/share/repos/password-store/www/development/openweathermap.gpg"

    get_gpg_data() {
        gpg -q -d "$1" \
            | grep "^$2 =" \
            | awk -F ' = ' '{print $2}'
    }

    get_location() {
        extract_json() {
            tag="$1"
            shift

            printf "%s\n" "$*" \
                | awk -F "\"$tag\": " '{print $2}' \
                | cut -d"," -f1 \
                | sed '/^$/d'
        }

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

    url_api="https://api.openweathermap.org/data/2.5/$1"
    url_appid="appid=$(get_gpg_data "$gpg_file" "api_key")"
    url_para="mode=xml&units=metric"

    city=$(get_gpg_data "$gpg_file" "city_id")

    curl -sf "$url_api?$url_appid&$url_para&$(get_location "$city")"
}

get_data() {
    get_icon() {
        case $1 in
            # https://openweathermap.org/weather-conditions
            01d) icon="";; # clear sky day
            01n) icon="";; # clear sky night
            02d) icon="";; # few cloud day
            02n) icon="";; # few cloud night
            03*) icon="";; # scattered clouds
            04*) icon="";; # broken clouds
            09*) icon="";; # shower rain
            10d) icon="";; # rain day
            10n) icon="";; # rain night
            11*) icon="";; # thunderstorm
            13*) icon="";; # snow
            50*) icon="";; # mist
            *)   icon="";; # unknown
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
    current="$(get_icon "$current_icon") $current_temp°"

    # forecast
    forecast_temp=$(printf "%.0f" \
        "$(extract_xml "temperature" "value" "$forecast_data")" \
    )
    forecast_icon=$(extract_xml "symbol" "var" "$forecast_data")
    forecast="$(get_icon "$forecast_icon") $forecast_temp°"

    # weather
    if [ "$forecast_temp" -gt "$current_temp" ]; then
        weather="$current  $forecast"
    elif [ "$current_temp" -gt "$forecast_temp" ]; then
        weather="$current  $forecast"
    elif [ "$current_icon" = "$forecast_icon" ]; then
        weather="$current"
    else
        weather="$current  $forecast"
    fi

    # precipitation
    forecast_precipitation=$(printf "%.0f" \
        "$(printf "%s * 100\n" \
            "$(extract_xml "precipitation" "probability" "$forecast_data")" \
            | bc -l \
        )" \
    )
    [ "$forecast_precipitation" -gt 0 ] \
        && precipitation="  $forecast_precipitation%"

    # sun
    current_sunrise=$(extract_xml "sun" "rise" "$current_data")
    current_sunset=$(extract_xml "sun" "set" "$current_data")

    now=$(date +%s)
    sunrise=$(convert_date "$current_sunrise" "Epoch")
    sunset=$(convert_date "$current_sunset" "Epoch")

    if [ "$sunrise" -ge "$now" ] \
        || [ "$now" -gt "$sunset" ]; then
        sun="  $(convert_date "$sunrise")"
    elif [ "$sunset" -ge "$now" ]; then
        sun="  $(convert_date "$sunset")"
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
        polybar_helper_net_check.sh "openweathermap.org" \
            && get_data \
            && polybar_helper_output.sh \
                "$weather$precipitation$sun"
        ;;
esac
