#!/usr/bin/env zsh

# Prevent the script from running if spotify is not running
if ! pgrep -x "Spotify" > /dev/null; then
    sketchybar --set $NAME label="Spotify not running" label.drawing=no icon.drawing=no
    exit 0
fi

if [[ -z $INFO ]]; then
    INFO=$(osascript -e '
    try
        tell application "Spotify"
            if it is running then
                set playerState to player state as text
                set trackName to name of current track as text
                set trackArtist to artist of current track as text
                return "{ \"Player State\": \"" & playerState & "\", \"Name\": \"" & trackName & "\", \"Artist\": \"" & trackArtist & "\" }"
            else
                return ""
            end if
        end tell
    on error
        return ""
    end try')
fi

if [[ -z $INFO ]]; then
    sketchybar --set $NAME label="Not playing" label.drawing=yes icon.drawing=yes
    exit 0
fi

PLAYER_STATE=$(echo "$INFO" | jq -r '."Player State"' 2>/dev/null || echo "stopped")
TRACK=$(echo "$INFO" | jq -r '.Name' 2>/dev/null || echo "No track")
ARTIST=$(echo "$INFO" | jq -r '.Artist' 2>/dev/null || echo "No artist")

# Set appropriate icon based on player state
case $PLAYER_STATE in
    "playing")
        ICON=""
        ;;
    "paused")
        ICON=""
        ;;
    *)
        ICON=""
        ;;
esac

# Update the icon and label
sketchybar --set $NAME icon="$ICON" icon.drawing=yes \
                      label="${TRACK} • ${ARTIST}" label.drawing=yes