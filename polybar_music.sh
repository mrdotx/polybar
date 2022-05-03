#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_music.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-05-03T11:17:18+0200

play_icon="契"
pause_icon=""
stop_icon="栗"

cmus_data() {
    if info=$(cmus-remote -Q 2> /dev/null); then
        status=$(printf "%s" "$info" \
            | grep '^status ' \
            | sed 's/^status //' \
        )
        stream=$(printf "%s" "$info" \
            | grep '^stream ' \
            | sed 's/^stream //' \
        )
        duration=$(printf "%s" "$info" \
            | grep '^duration ' \
            | sed 's/^duration //' \
        )
        position=$(printf "%s" "$info" \
            | grep '^position ' \
            | sed 's/^position //' \
        )
        file=$(printf "%s" "$info" \
            | grep '^file ' \
            | sed 's/^file //' \
        )
        artist=$(printf "%s" "$info" \
            | grep '^tag artist ' \
            | sed 's/^tag artist //' \
        )
        album=$(printf "%s" "$info" \
            | grep '^tag album ' \
            | sed 's/^tag album //' \
        )
        tracknumber=$(printf "%s" "$info" \
            | grep '^tag tracknumber ' \
            | sed 's/^tag tracknumber //' \
        )
        title=$(printf "%s" "$info" \
            | grep '^tag title ' \
            | sed 's/^tag title //' \
        )
        genre=$(printf "%s" "$info" \
            | grep '^tag genre ' \
            | sed 's/^tag genre //' \
        )
        comment=$(printf "%s" "$info" \
            | grep '^tag comment ' \
            | sed 's/^tag comment //' \
        )
    else
        exit 2
    fi
}

notify() {
    position_min=$(printf "%02d" $((position / 60)))
    position_sec=$(printf "%02d" $((position % 60)))
    if [ "$duration" -eq -1 ]; then
        duration_min="00"
        duration_sec="00"
    else
        duration_min=$(printf "%02d" $((duration / 60)))
        duration_sec=$(printf "%02d" $((duration % 60)))
    fi
    runtime="$position_min:$position_sec/$duration_min:$duration_sec"

    notification() {
        header=$1
        shift

        [ -z "$stream" ] \
            && cover=$(mktemp -t polybar_music_cover.XXXXXX.png) \
            && ffmpeg -y -i "$file" -c:v copy "$cover" >/dev/null 2>&1 \
            && convert "$cover" -resize 100 "$cover" >/dev/null 2>&1

        notify-send \
            -u low  \
            -i "$cover" \
            "C* Music Player | $header" \
            "$@" \
            -h string:x-canonical-private-synchronous:"C* Music Player |"

        rm -f "$cover"
    }

    if [ -z "$artist" ] \
        && [ -z "$title" ]; then
            info="${file##*/}"
    elif [ -z "$stream" ]; then
        info="\nArtist: $artist\nAlbum : $album\nTrack : $tracknumber\nTitle : <b>$title</b>"
    else
        info="\n<b>$stream</b>\n$genre\n$title\n$comment"
    fi

    case $status in
        "playing")
            notification "$play_icon $runtime" "$info"
            ;;
        "paused")
            notification "$pause_icon $runtime" "$info"
            ;;
        "stopped")
            notification "$stop_icon $runtime" "$info"
            ;;
        *)
            notification "$runtime" "$info"
            ;;
    esac
}

status() {
    if [ -z "$stream" ]; then
        info="$artist - $title | $album"
    else
        info="$stream | $genre | $title"
    fi

    if [ -z "$artist" ] \
        && [ -z "$title" ]; then
            info=$(printf "%s\n" "${file##*/}" \
                | cut -c 1-98)
    else
        info=$(printf "%s\n" "$info" \
            | cut -c 1-98)
    fi

    case $status in
        "playing")
            polybar_helper_output.sh "$play_icon $info"
            ;;
        "paused")
            polybar_helper_output.sh "$pause_icon $info" "Polybar.secondary"
            ;;
        "stopped")
            polybar_helper_output.sh "$stop_icon $info" "Polybar.red"
            ;;
        *)
            polybar_helper_output.sh "$info"
            ;;
    esac
}

case "$1" in
    --notify)
        cmus_data
        notify
        ;;
    --status)
        cmus_data
        status
        ;;
    --start)
        cmus \
            && sleep .5 \
            && for id in $(pgrep -f "polybar main"); do
                    polybar-msg -p "$id" \
                        action "#music.hook.0" >/dev/null 2>&1 &
                done
        ;;
    *)
        for id in $(pgrep -f "polybar main"); do
            polybar-msg -p "$id" \
                action "#music.hook.1" >/dev/null 2>&1 &
        done
        ;;
esac
