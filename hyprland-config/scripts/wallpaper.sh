IMAGE_DIR="$HOME/Pictures/wallpapers"
# Ensure the folder exists
if [ ! -d "$IMAGE_DIR" ]; then
    echo "Directory $IMAGE_DIR does not exist."
    exit 1
fi

SELECTED_LINE=$(find "$IMAGE_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) | \
    awk -v dir="$IMAGE_DIR" '
    {
        # Get just the filename for clean text display
        filename = $0;
        sub(".*/", "", filename); 
        # Output the structural format Wofi expects
        print "img:" $0 ":text:" filename
    }' | \
    wofi --dmenu \
         --allow-images \
         --prompt "Select an image:" \
         --width 600 \
         --height 400 )
if [ -n "$SELECTED_LINE" ]; then
    CLEAN_PATH=$(echo "$SELECTED_LINE" | sed -E 's/^img:(.*):text:.*/\1/')
    cp $CLEAN_PATH ~/.config/hypr/hyprland-config/scripts/wallpaper.jpg
    killall swaybg
    awww img $CLEAN_PATH --transition-type random
fi
