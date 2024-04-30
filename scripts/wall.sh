#!/bin/sh

# Check if required packages are installed
command -v swww >/dev/null 2>&1 || { echo "swww is not installed. Please install it first." >&2; exit 1; }
command -v convert >/dev/null 2>&1 || { echo "ImageMagick is not installed. Please install it first." >&2; exit 1; }

# Set variables
wall_dir="$HOME/wallpaper/"
cache_dir="$HOME/.cache/wallpaper/"
rofi_command="rofi -dmenu -theme ~/scripts/select.rasi"

# Create cache directory if it doesn't exist
mkdir -p "${cache_dir}"

# Convert images and save to cache directory
for image in "${wall_dir}"/*.{jpg,jpeg,png,webp}; do
    if [ -f "${image}" ]; then
        filename=$(basename "${image}")
        cache_file="${cache_dir}/${filename}"
        if [ ! -f "${cache_file}" ]; then
            convert -strip "${image}" -thumbnail 500x500^ -gravity center -extent 500x500 "${cache_file}"
        fi
    fi
done

# Launch rofi and get the selected wallpaper
wall_selection=$(find "${wall_dir}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -exec basename {} \; | sort | while read -r A; do echo -en "$A\x00icon\x1f${cache_dir}/$A\n"; done | $rofi_command)

# Set the selected wallpaper using swww
if [ -n "${wall_selection}" ]; then
    swww img "${wall_dir}/${wall_selection}" --transition-fps 60 --transition-type random
fi
