dir="/home/eric/.config/hypr/hyprland-config/scripts"
source $dir/venv/bin/activate

query=$(python $dir/queuelauncher/main.py queue 10 | wofi --height 400 --width 600 --allow-images --show dmenu)

song=$(python $dir/queuelauncher/main.py search "$query" 5 | wofi --height 400 --width 600 --allow-images --show dmenu)
#echo $song
python $dir/queuelauncher/main.py add "$song"
