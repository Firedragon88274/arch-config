n() {
  /usr/local/nova/bin/nova "$@"
}
cb=$(n state -d:0 | grep -oE 'Brightness: [0-9]+')
echo "e$cb"
b=$(echo "" | wofi --dmenu --prompt "$cb")

if [[ "$b"=="0" ]]; then
  n turn -d:0 -t
  n turn -d:1 -t
  n turn -d:2 -t
else
  n brightness -d:0 -b:$b
  n brightness -d:1 -b:$b
  n brightness -d:2 -b:$b
fi
