q=$(echo -E "Firefox Search" | wofi --dmenu)
firefox "https://duckduckgo.com/?t=ffab&q=$q&ia=web"
