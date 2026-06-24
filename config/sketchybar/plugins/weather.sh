#!/bin/bash

# Weather Icons Map (without -A flag for better compatibility)
declare weather_icons
weather_icons=(
    ["Clear"]="󰖙" 
    ["Sunny"]="󰖙"
    ["Partlycloudy"]="󰖕"
    ["Partly_cloudy"]="󰖕"
    ["Cloudy"]="󰖐"
    ["Overcast"]="󰖐"
    ["Mist"]="󰖑"
    ["Fog"]="󰖑"
    ["Lightrain"]="󰖗"
    ["Light_rain"]="󰖗"
    ["Moderaterain"]="󰖖"
    ["Moderate_rain"]="󰖖"
    ["Heavyrain"]="󰖖"
    ["Heavy_rain"]="󰖖"
    ["Lightsnow"]="󰖘"
    ["Light_snow"]="󰖘"
    ["Moderatesnow"]="󰖘"
    ["Moderate_snow"]="󰖘"
    ["Heavysnow"]="󰖘"
    ["Heavy_snow"]="󰖘"
    ["Thunder"]="󰖓"
    ["Thunderstorm"]="󰖓"
)

# Cache file location
CACHE_FILE="$HOME/.cache/sketchybar/weather.cache"
CACHE_TIMEOUT=900 # 15 minutes in seconds

# Create cache directory if it doesn't exist
mkdir -p "$(dirname "$CACHE_FILE")"

# Function to fetch weather
fetch_weather() {
    # Get weather data
    CITY="92655"
    weather_data=$(curl -s --max-time 10 "wttr.in/$CITY?format=%t\|%C&u")
    
    if [ -n "$weather_data" ] && [ "$weather_data" != "|" ]; then
        echo "$weather_data:$(date +%s)" > "$CACHE_FILE"
        echo "$weather_data"
    else
        return 1
    fi
}

# Check if cache exists and is recent
if [ -f "$CACHE_FILE" ]; then
    cache_data=$(cat "$CACHE_FILE")
    cache_timestamp=$(echo "$cache_data" | cut -d':' -f2)
    current_timestamp=$(date +%s)
    
    if [ $((current_timestamp - cache_timestamp)) -lt "$CACHE_TIMEOUT" ]; then
        weather_data=$(echo "$cache_data" | cut -d':' -f1)
    else
        weather_data=$(fetch_weather)
    fi
else
    weather_data=$(fetch_weather)
fi

# Parse weather data
if [ -n "$weather_data" ] && [ "$weather_data" != "|" ]; then
    temperature=$(echo "$weather_data" | cut -d'|' -f1 | xargs)
    condition=$(echo "$weather_data" | cut -d'|' -f2 | xargs | tr ' ' '_')
    
    # Get weather icon
    weather_icon=${weather_icons[$condition]:-"󰖐"}
    
    # Only update sketchybar if NAME is set
    if [ -n "$NAME" ]; then
        sketchybar --set "$NAME" icon="$weather_icon" label="$temperature"
    else
        echo "Weather: $weather_icon $temperature"
    fi
else
    # Error state
    if [ -n "$NAME" ]; then
        sketchybar --set "$NAME" icon="󰖐" label="N/A"
    else
        echo "Weather: N/A"
    fi
fi