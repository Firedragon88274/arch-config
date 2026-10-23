#!/bin/zsh
n() {
  /usr/local/nova/bin/nova "$@"
}
c=$(hyprpicker)
n color -d:0 -c:$c
n color -d:1 -c:$c
n color -d:2 -c:$c
