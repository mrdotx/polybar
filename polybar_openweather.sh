#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_openweather.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2023-12-01T13:51:24+0100

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
        | awk -F "<$tag " '{print $2}' \
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

period() {
    printf "%s - %s\n" \
        "$(convert_date "$(convert_date "$1" "Epoch")")" \
        "$(convert_date "$(convert_date "$2" "Epoch")")"
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
    current_like=$(printf "%.0f" \
        "$(extract_xml "feels_like" "value" "$current_data")" \
    )
    current_humidity=$(extract_xml "humidity" "value" "$current_data")
    current_pressure=$(extract_xml "pressure" "value" "$current_data")
    current_visibility=$(printf "%.1f" \
        "$(printf "%s/1000\n" \
            "$(extract_xml "visibility" "value" "$current_data")" \
            | bc -l \
        )" \
    )
    current_number=$(extract_xml "weather" "number" "$current_data")

    # current precipitation
    current_mode=$(extract_xml "precipitation" "mode" "$current_data")
    case $current_mode in
        no)
            current_precipitation="0.0"
            ;;
        *)
            current_precipitation=$(extract_xml "precipitation" \
                "value" "$current_data")
            ;;
    esac

    # current wind
    current_speed=$(printf "%.1f" \
        "$(printf "%s*3.6\n" \
            "$(extract_xml "speed" "value" "$current_data")" \
            | bc -l \
        )" \
    )
    current_direction=$(extract_xml "direction" "code" "$current_data")

    # current daylight
    current_sunrise=$(extract_xml "sun" "rise" "$current_data")
    current_sunset=$(extract_xml "sun" "set" "$current_data")
    daylight_sunrise=$(convert_date "$current_sunrise" "Epoch")
    daylight_sunset=$(convert_date "$current_sunset" "Epoch")
    now=$(date +%s)
    sunrise=$(convert_date "$daylight_sunrise")
    sunset="$(convert_date "$daylight_sunset")"
    if [ "$daylight_sunrise" -ge "$now" ] \
        || [ "$now" -gt "$daylight_sunset" ]; then
        daytime="n"
    else
        daytime="d"
    fi

    # forecast
    forecast_from=$(extract_xml "time" "from" "$forecast_data")
    forecast_to=$(extract_xml "time" "to" "$forecast_data")
    forecast_number=$(extract_xml "symbol" "number" "$forecast_data")
    forecast_temp=$(printf "%.0f" \
        "$(extract_xml "temperature" "value" "$forecast_data")" \
    )
    forecast_like=$(printf "%.0f" \
        "$(extract_xml "feels_like" "value" "$forecast_data")" \
    )
    forecast_pressure=$(extract_xml "pressure" "value" "$forecast_data")
    forecast_humidity=$(extract_xml "humidity" "value" "$forecast_data")
    forecast_visibility=$(printf "%.1f" \
        "$(printf "%s/1000\n" \
            "$(extract_xml "visibility" "value" "$forecast_data")" \
            | bc -l \
        )" \
    )

    # forecast precipitation
    forecast_probability=$(printf "%.0f" \
        "$(printf "%s*100\n" \
            "$(extract_xml "precipitation" "probability" "$forecast_data")" \
            | bc -l \
        )" \
    )
    case $forecast_probability in
        0)
            forecast_precipitation="0.0"
            ;;
        *)
            forecast_precipitation=$(extract_xml "precipitation" \
                "value" "$forecast_data")
            ;;
    esac
    forecast_type=$(extract_xml "precipitation" "type" "$forecast_data")

    # forecast wind
    forecast_speed=$(printf "%.1f" \
        "$(printf "%s*3.6\n" \
            "$(extract_xml "windSpeed" "mps" "$forecast_data")" \
            | bc -l \
        )" \
    )
    forecast_direction=$(extract_xml "windDirection" "code" "$forecast_data")
}

get_weather() {
    # https://openweathermap.org/weather-conditions
    case $1 in
        200) code="11" condition="thunderstorm with light rain";;
        201) code="11" condition="thunderstorm with rain";;
        202) code="11" condition="thunderstorm with heavy rain";;
        210) code="11" condition="light thunderstorm";;
        211) code="11" condition="thunderstorm";;
        212) code="11" condition="heavy thunderstorm";;
        221) code="11" condition="ragged thunderstorm";;
        230) code="11" condition="thunderstorm with light drizzle";;
        231) code="11" condition="thunderstorm with drizzle";;
        232) code="11" condition="thunderstorm with heavy drizzle";;
        300) code="09" condition="light intensity drizzle";;
        301) code="09" condition="drizzle";;
        302) code="09" condition="heavy intensity drizzle";;
        310) code="09" condition="light intensity drizzle rain";;
        311) code="09" condition="drizzle rain";;
        312) code="09" condition="heavy intensity drizzle rain";;
        313) code="09" condition="shower rain and drizzle";;
        314) code="09" condition="heavy shower rain and drizzle";;
        321) code="09" condition="shower drizzle";;
        500) code="10" condition="light rain";;
        501) code="10" condition="moderate rain";;
        502) code="10" condition="heavy intensity rain";;
        503) code="10" condition="very heavy rain";;
        504) code="10" condition="extreme rain";;
        511) code="13" condition="freezing rain";;
        520) code="09" condition="light intensity shower rain";;
        521) code="09" condition="shower rain";;
        522) code="09" condition="heavy intensity shower rain";;
        531) code="09" condition="ragged shower rain";;
        600) code="13" condition="light snow";;
        601) code="13" condition="snow";;
        602) code="13" condition="heavy snow";;
        611) code="13" condition="sleet";;
        612) code="13" condition="light shower sleet";;
        613) code="13" condition="shower sleet";;
        615) code="13" condition="light rain and snow";;
        616) code="13" condition="rain and snow";;
        620) code="13" condition="light shower snow";;
        621) code="13" condition="shower snow";;
        622) code="13" condition="heavy shower snow";;
        701) code="50" condition="mist";;
        711) code="50" condition="smoke";;
        721) code="50" condition="haze";;
        731) code="50" condition="sand/dust whirls";;
        741) code="50" condition="fog";;
        751) code="50" condition="sand";;
        761) code="50" condition="dust";;
        762) code="50" condition="volcanic ash";;
        771) code="50" condition="squalls";;
        781) code="50" condition="tornado";;
        800) code="01" condition="clear sky";;
        801) code="02" condition="few clouds: 11-25%";;
        802) code="03" condition="scattered clouds: 25-50%";;
        803) code="04" condition="broken clouds: 51-84%";;
        804) code="04" condition="overcast clouds: 85-100%";;
        N)   icon=""  condition="north";;
        NNE) icon=""  condition="north-northeast";;
        NE)  icon=""  condition="northeast";;
        ENE) icon=""  condition="east-northeast";;
        E)   icon=""  condition="east";;
        ESE) icon=""  condition="east-southeast";;
        SE)  icon=""  condition="southeast";;
        SSE) icon=""  condition="south-southeast";;
        S)   icon=""  condition="south";;
        SSW) icon=""  condition="south-southwest";;
        SW)  icon=""  condition="south-west";;
        WSW) icon=""  condition="west-southwest";;
        W)   icon=""  condition="west";;
        WNW) icon=""  condition="west-northwest";;
        NW)  icon=""  condition="northwest";;
        NNW) icon=""  condition="north-northwest";;
        x71) icon="󰔵"  condition="trend up";;
        x72) icon="󰔳"  condition="trend down";;
        x73) icon="󰔴"  condition="trend neutral";;
        x81) icon=""  condition="precipitation";;
        x91) icon=""  condition="sunrise";;
        x92) icon=""  condition="sunset";;
        *)   icon=""  condition="not available"
    esac

    case $code in
        01)
            case $daytime in
                d) icon="";; # clear sky day
                n) icon="";; # clear sky night
            esac;;
        02)
            case $daytime in
                d) icon="";; # few clouds day
                n) icon="";; # few clouds night
            esac;;
        03)
            case $daytime in
                d) icon="";; # scattered clouds day
                n) icon="";; # scatteres clouds night
            esac;;
        04)
            case $daytime in
                d) icon="";; # broken clouds day
                n) icon="";; # broken clouds night
            esac;;
        09)
            case $daytime in
                d) icon="";; # shower rain day
                n) icon="";; # shower rain night
            esac;;
        10)
            case $daytime in
                d) icon="";; # rain day
                n) icon="";; # rain night
            esac;;
        11)
            case $daytime in
                d) icon="";; # thunderstorm day
                n) icon="";; # thunderstorm night
            esac;;
        13)
            case $daytime in
                d) icon="";; # snow day
                n) icon="";; # snow night
            esac;;
        50)
            case $daytime in
                d) icon="";; # mist day
                n) icon="";; # mist night
            esac;;
    esac

    case $2 in
        condition)
            printf "%s\n" "$condition"
            ;;
        icon)
            printf "%s " "$icon"
            ;;
        *)
            printf "%%{T2}%s %%{T-}" "$icon"
            ;;
    esac
}

polybar_data() {
    current_icon="$(get_weather "$current_number")"
    forecast_icon="$(get_weather "$forecast_number")"
    trend_up_icon="$(get_weather "x71")"
    trend_down_icon="$(get_weather "x72")"
    trend_neutral_icon="$(get_weather "x72")"
    precipitation_icon="$(get_weather "x81")"
    sunrise_icon="$(get_weather "x91")"
    sunset_icon="$(get_weather "x92")"

    # current
    current="$(get_weather "$current_number")$current_temp°"

    # forecast
    if [ "$current_icon" = "$forecast_icon" ]; then
        forecast="$forecast_temp°"
    elif [ "$forecast_temp" -eq "$current_temp" ]; then
        forecast="$forecast_icon"
    else
        forecast="$forecast_icon$forecast_temp°"
    fi

    # weather
    if [ "$forecast_temp" -gt "$current_temp" ]; then
        weather="$current $trend_up_icon$forecast"
    elif [ "$current_temp" -gt "$forecast_temp" ]; then
        weather="$current $trend_down_icon$forecast"
    elif [ "$current_icon" = "$forecast_icon" ]; then
        weather="$current"
    else
        weather="$current $trend_neutral_icon$forecast"
    fi

    # precipitation
    [ "$forecast_probability" -gt 0 ] \
        && precipitation=" $precipitation_icon$forecast_probability%"

    # daylight
    case $daytime in
        d)
            daylight=" $sunset_icon$sunset"
            ;;
        n)
            daylight=" $sunrise_icon$sunrise"
            ;;
    esac

    # output
    printf "%s%s%s" "$weather" "$precipitation" "$daylight"
}

output_data() {
    table_header="─────────────────────────────────┬───┬─────────"
    table_divider="─────────────────────────────────┼───┼─────────"

    row() {
        width=31
        divider="│"

        printf " %s %s %s%s %s\n" \
            "$(polybar_add_spacer "$1" $width)" \
            "$divider" \
            "${2:-"  "}" \
            "$divider" \
            "$3"
    }

    current_condition="$(get_weather "$current_number" "condition")"
    current_icon="$(get_weather "$current_number" "icon")"
    current_wind_icon="$(get_weather "$current_direction" "icon")"
    sunrise_icon="$(get_weather "x91" "icon")"
    sunset_icon="$(get_weather "x92" "icon")"
    forecast_condition="$(get_weather "$forecast_number" "condition")"
    forecast_icon="$(get_weather "$forecast_number" "icon")"
    forecast_wind="$(get_weather "$forecast_direction" "icon")"
    precipitation_icon="$(get_weather "x81" "icon")"

    printf "%s\n" \
        "<i>Current [$(date +"%H:%M %d.%m.%Y")]</i>" \
        "$table_header" \
        "$(row "$current_condition" \
            "$current_icon" "$current_temp°C")" \
        "$(row "feels like" \
            "" "$current_like°C")" \
        "$(row "$current_mode precipitation" \
            "$precipitation_icon" "${current_precipitation}mm")" \
        "$(row "wind: ${current_speed}km/h" \
            "$current_wind_icon" "$current_direction")" \
        "$(row "pressure" \
            "" "${current_pressure}hPa")" \
        "$(row "humidity" \
            "" "$current_humidity%")" \
        "$(row "visibility" \
            "" "${current_visibility}km")" \
        "$table_divider" \
        "$(row "sunrise" \
            "$sunrise_icon" "$sunrise")" \
        "$(row "sunset" \
            "$sunset_icon" "$sunset")" \
        "" \
        "<i>Forecast [$(period "$forecast_from" "$forecast_to")]</i>" \
        "$table_header" \
        "$(row "$forecast_condition" \
            "$forecast_icon" "$forecast_temp°C")" \
        "$(row "feels like" \
            "" "$forecast_like°C")" \
        "$(row "${forecast_type:-"no"} precipitation: $forecast_probability%" \
            "$precipitation_icon" "${forecast_precipitation}mm")" \
        "$(row "wind: ${forecast_speed}km/h" \
            "$forecast_wind" "$forecast_direction")" \
        "$(row "pressure" \
            "" "${forecast_pressure}hPa")" \
        "$(row "humidity" \
            "" "$forecast_humidity%")" \
        "$(row "visibility" \
            "" "${forecast_visibility}km")"
}

case "$1" in
    --notify)
        polybar_net_check "openweathermap.org" \
            || exit 1

        get_data
        title="OpenWeather [$(cat "$location_file")]"
        notify-send \
            -t 0 \
            -u low \
            "$title" \
            "\n$(output_data)" \
            -h string:x-canonical-private-synchronous:"$title"
        ;;
    --terminal)
        polybar_net_check "openweathermap.org" \
            || exit 1

        get_data
        output_data \
            | sed 's/\(<i>\|<\/i>\)//g'
        ;;
    --update)
        for id in $(pgrep -f "polybar main"); do
            polybar-msg -p "$id" \
                action "#weather.hook.0" >/dev/null 2>&1 &
        done
        ;;
    *)
        polybar_net_check "openweathermap.org" \
            || exit 1

        get_data
        polybar_output "$(polybar_data)"
        ;;
esac
