larps=("larp" "cmatrix" "pipes.sh" "lavat" "fastfetch" "peaclock" "cmatrix | lolcat")
random_item="${larps[RANDOM % ${#larps[@]}]}"
kitty --hold $random_item
