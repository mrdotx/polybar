#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_openweather.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2023-11-27T20:47:02+0100

# speed up script by using standard c
LC_ALL=C
LANG=C

# needed api key for openweather in gpg file
# api_key = a2d833bfaa8912dc090fd547e109cf13
gpg_file="$HOME/.local/share/repos/password-store/www/development/openweathermap.gpg"

# file for location cache (if not available, determine with ipinfo.io)
location_file="/tmp/weather.location"

# source polybar helper
. polybar_helper.sh

get_icon_info() {
    # https://openweathermap.org/weather-conditions
    case $1 in
        01d) icon="" icon_name="Clear Sky";;
        01n) icon="" icon_name="Clear Sky";;
        02d) icon="" icon_name="Few Clouds";;
        02n) icon="" icon_name="Few Clouds";;
        03*) icon="" icon_name="Scattered Clouds";;
        04*) icon="" icon_name="Broken Clouds";;
        09d) icon="" icon_name="Shower Rain";;
        09n) icon="" icon_name="Shower Rain";;
        10d) icon="" icon_name="Rain";;
        10n) icon="" icon_name="Rain";;
        11d) icon="" icon_name="Thunderstorm";;
        11n) icon="" icon_name="Thunderstorm";;
        13d) icon="" icon_name="Snow";;
        13n) icon="" icon_name="Snow";;
        50*) icon="" icon_name="Mist";;
        71x) icon="󰔵" icon_name="Trend Up";;
        72x) icon="󰔳" icon_name="Trend Down";;
        73x) icon="󰔴" icon_name="Trend Neutral";;
        81x) icon="󰕋" icon_name="Precipitation";;
        91x) icon="󰖜" icon_name="Sunrise";;
        92x) icon="󰖛" icon_name="Sunset";;
        *)   icon="" icon_name="Not Available";;
    esac

    case $2 in
        icon)
            printf "%s " "$icon"
            ;;
        name)
            printf "%s" "$icon_name"
            ;;
        *)
            printf "%%{T2}%s %%{T-}" "$icon"
            ;;
    esac
}

request() {
    api_key="$( \
        gpg -q -d "$gpg_file" \
            | grep "^api_key =" \
            | awk -F ' = ' '{print $2}' \
    )"

    grep -q -s '[^[:space:]]' $location_file \
        || curl -fsS 'https://ipinfo.io/city' > $location_file

    url_api="https://api.openweathermap.org/data/2.5/$1"
    url_appid="appid=$api_key"
    url_para="mode=xml&units=metric"
    url_city="q=$(sed 's/ /%20/g' "$location_file")"

    curl -sf "$url_api?$url_appid&$url_para&$url_city"
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

add_spacer() {
    output=" $1"
    i=$((16 - ${#1}))

    while [ "$i" -gt 0 ]; do
        output="$output "
        i=$((i - 1))
    done

    printf "%s" "$output"
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

    # forecast
    forecast_temp=$(printf "%.0f" \
        "$(extract_xml "temperature" "value" "$forecast_data")" \
    )
    forecast_icon=$(extract_xml "symbol" "var" "$forecast_data")

    # precipitation
    forecast_precipitation=$(printf "%.0f" \
        "$(printf "%s * 100\n" \
            "$(extract_xml "precipitation" "probability" "$forecast_data")" \
            | bc -l \
        )" \
    )

    # sun
    current_sunrise=$(extract_xml "sun" "rise" "$current_data")
    current_sunset=$(extract_xml "sun" "set" "$current_data")
}

output_data() {
    # current
    current="$(get_icon_info "$current_icon")$current_temp°"

    # forecast
    if [ "$current_icon" = "$forecast_icon" ]; then
        forecast="$forecast_temp°"
    elif [ "$forecast_temp" -eq "$current_temp" ]; then
        forecast="$(get_icon_info "$forecast_icon")"
    else
        forecast="$(get_icon_info "$forecast_icon")$forecast_temp°"
    fi

    # weather
    if [ "$forecast_temp" -gt "$current_temp" ]; then
        weather="$current $(get_icon_info "71x")$forecast"
    elif [ "$current_temp" -gt "$forecast_temp" ]; then
        weather="$current $(get_icon_info "72x")$forecast"
    elif [ "$current_icon" = "$forecast_icon" ]; then
        weather="$current"
    else
        weather="$current $(get_icon_info "73x")$forecast"
    fi

    # precipitation
    [ "$forecast_precipitation" -gt 0 ] \
        && precipitation=" $(get_icon_info "81x")$forecast_precipitation%"

    # daylight
    now=$(date +%s)
    sunrise=$(convert_date "$current_sunrise" "Epoch")
    sunset=$(convert_date "$current_sunset" "Epoch")

    if [ "$sunrise" -ge "$now" ] \
        || [ "$now" -gt "$sunset" ]; then
        daylight=" $(get_icon_info "91x")$(convert_date "$sunrise")"
    else
        daylight=" $(get_icon_info "92x")$(convert_date "$sunset")"
    fi

    # output
    printf "%s%s%s" "$weather" "$precipitation" "$daylight"
}

notification() {
    title="OpenWeather [$(cat "$location_file")]"
    table_header="──────────────────┬───┬───────"
    current_name="$(get_icon_info "$current_icon" "name")"
    current="$(get_icon_info "$current_icon" "icon")"
    forecast_name="$(get_icon_info "$forecast_icon" "name")"
    forecast="$(get_icon_info "$forecast_icon" "icon")"
    precipitation_name="$(get_icon_info "81x" "name")"
    precipitation="$(get_icon_info "81x" "icon")"
    sunrise_name="$(get_icon_info "91x" "name")"
    sunrise_icon="$(get_icon_info "91x" "icon")"
    sunrise="$(convert_date "$(convert_date "$current_sunrise" "Epoch")")"
    sunset_name="$(get_icon_info "92x" "name")"
    sunset_icon="$(get_icon_info "92x" "icon")"
    sunset="$(convert_date "$(convert_date "$current_sunset" "Epoch")")"
    message=$(printf "%s\n" \
        "<i>Current [$(date +"%k:%M %d.%m.%Y")]</i>\n$table_header" \
        "$(add_spacer "$current_name") | $current| $current_temp°" \
        "\n<i>Forecast [3h]</i>\n$table_header" \
        "$(add_spacer "$forecast_name") | $forecast| $forecast_temp°" \
        "$(add_spacer "$precipitation_name") | $precipitation| $forecast_precipitation%" \
        "\n<i>Daylight</i>\n$table_header" \
        "$(add_spacer "$sunrise_name") | $sunrise_icon| $sunrise" \
        "$(add_spacer "$sunset_name") | $sunset_icon| $sunset" \
    )

    notify-send \
        -t 0 \
        -u low \
        "$title" \
        "\n$message" \
        -h string:x-canonical-private-synchronous:"$title"
}

case "$1" in
    --notify)
        ! polybar_net_check "openweathermap.org" \
            && exit 1

        get_data
        notification
        ;;
    --update)
        for id in $(pgrep -f "polybar main"); do
            polybar-msg -p "$id" \
                action "#weather.hook.0" >/dev/null 2>&1 &
        done
        ;;
    *)
        ! polybar_net_check "openweathermap.org" \
            && exit 1

        get_data
        polybar_output "$(output_data)"
        ;;
esac
