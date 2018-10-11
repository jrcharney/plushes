#!/bin/bash
# File: rw.sh (Random Wallpaper)
# Info: Pick a file from the Wallpaper directory to be the background.
#       This is designed to be used with i3 and feh. So make sure that both are installed.

wd=~/Pictures/Wallpaper                   # Set the wallpaper directory
files=($wd/*)                             # Produce a list of files
rn=$(echo "${RANDOM}%${#files[@]}" | bc)  # generate a pseudo-random number
wallpaper="${files[$rn]}"

echo "Wallpaper set to '${wallpaper}'"
feh --bg-scale "${wallpaper}"
