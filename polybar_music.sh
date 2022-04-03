#!/bin/sh

# path:   /home/klassiker/.local/share/repos/polybar/polybar_music.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/polybar
# date:   2022-04-03T08:07:33+0200

bar_id=$(pgrep -f "polybar primary")

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
    [ "$duration" -ge 0 ] \
        && position_minutes=$(printf "%02d" $((position / 60))) \
        && position_seconds=$(printf "%02d" $((position % 60))) \
        && duration_minutes=$(printf "%02d" $((duration / 60))) \
        && duration_seconds=$(printf "%02d" $((duration % 60))) \
        && title_status="$position_minutes:$position_seconds / $duration_minutes:$duration_seconds"

    case $status in
        "playing")
            info=" $title_status"
            ;;
        "paused")
            info=" $title_status"
            ;;
        "stopped")
            info=" $title_status"
            ;;
        *)
            info=""
            ;;
    esac

    [ -n "$file" ] \
        && albumart=$(mktemp -t polybar_music.XXXXXX.png) \
        && ffmpeg -y -i "$file" -c:v copy "$albumart" >/dev/null 2>&1

    if [ -z "$stream" ]; then
        info_body="Artist: $artist\nAlbum : $album\nTrack : $tracknumber\nTitle : <b>$title</b>"
    else
        info_body="<b>$stream</b>\n$genre\n$title\n$comment"
    fi

    notification() {
        notify-send \
            -u low  \
            -i "$albumart" \
            "C* Music Player | $info" \
            "$@" \
            -h string:x-canonical-private-synchronous:"C* Music Player |"
    }

    if [ -z "$artist" ] \
        && [ -z "$title" ]; then
            notification "${file##*/}"
    else
        notification "$info_body"
    fi

    rm -f "$albumart"
}

status() {
    xrdb_query() {
        xrdb -query \
            | grep "$1:" \
            | cut -f2
    }

    inactive_color=$(xrdb_query "Polybar.foreground1")
    stop_color=$(xrdb_query "color1")

    case $status in
        "playing")
            info=""
            len=100
            ;;
        "paused")
            info="%{o$inactive_color}"
            len=111
            ;;
        "stopped")
            info="%{o$stop_color}"
            len=111
            ;;
        *)
            info=""
            ;;
    esac

    if [ -z "$stream" ]; then
        info_body="$artist - $title | $album"
    else
        info_body="$stream | $genre | $title"
    fi

    if [ -z "$artist" ] \
        && [ -z "$title" ]; then
            printf "%s %s\n" "$info" "${file##*/}" \
                | cut -c 1-$len
    else
        printf "%s %s\n" "$info" "$info_body" \
            | cut -c 1-$len
    fi
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
            && polybar-msg -p "$bar_id" hook module/music 1
        ;;
    *)
        polybar-msg -p "$bar_id" hook module/music 2 &
        ;;
esac
