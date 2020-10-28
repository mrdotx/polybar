#!/bin/sh

# path:       /home/klassiker/.local/share/repos/polybar/polybar_music.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/polybar
# date:       2020-10-28T15:35:45+0100

notify() {
    if [ "$duration" -ge 0 ]; then
        position_minutes=$(printf "%02d" $((position / 60)))
        position_seconds=$(printf "%02d" $((position % 60)))
        duration_minutes=$(printf "%02d" $((duration / 60)))
        duration_seconds=$(printf "%02d" $((duration % 60)))
        title_status="$position_minutes:$position_seconds / $duration_minutes:$duration_seconds"
    fi

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

    if [ -n "$file" ]; then
        albumart=$(mktemp "/tmp/cmus_notify.XXXXXX.png")
        ffmpeg -y -i "$file" -c:v copy "$albumart" >/dev/null 2>&1
    fi

    if [ -z "$stream" ]; then
        info_body="Artist: $artist\nAlbum : $album\nTrack : $tracknumber\nTitle : <b>$title</b>"
    else
        info_body="<b>$stream</b>\n$genre\n$title\n$comment"
    fi

    if [ -z "$artist" ] \
        && [ -z "$title" ]; then
            notify-send -i "$albumart" "C* Music Player | $info" "${file##*/}"
    else
        notify-send -i "$albumart" "C* Music Player | $info" "$info_body"
    fi

    rm -f "$albumart"
}

bar() {
    inactive_color=$(xrdb -query \
        | grep Polybar.foreground1: \
        | cut -f2 \
    )
    stop_color=$(xrdb -query \
        | grep color1: \
        | cut -f2 \
    )

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
        info_body="$artist | $title | $album"
    else
        info_body="$stream | $genre | $title"
    fi

    if [ -z "$artist" ] \
        && [ -z "$title" ]; then
            printf "%s %s" "$info" "${file##*/}" \
                | cut -c 1-$len
    else
        printf "%s %s" "$info" "$info_body" \
            | cut -c 1-$len
    fi
}

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

case "$1" in
    --notify-send)
        notify
        ;;
    --polybar)
        bar
        ;;
    *)
        polybar-msg hook module/music 2
        ;;
esac
