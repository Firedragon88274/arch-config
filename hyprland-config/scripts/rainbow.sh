#!/usr/bin/env bash
# /* ---- 💫 https://github.com 💫 ---- */  ##
# Smooth border cycling effect using Wallust palette or full rainbow

# Possible values: "wallust_random", "rainbow", "gradient_flow"
EFFECT_TYPE="gradient_flow"

WALLUST_COLORS_SOURCE="$HOME/.config/hypr/wallust/wallust-hyprland.conf"

# Ensure Hyprland is fully initialized before sending hyprctl commands
while [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; do
    sleep 0.5
done

WALLUST_COLORS=()

# ---------- LOAD WALLUST COLORS ----------
if [[ "$EFFECT_TYPE" == "wallust_random" || "$EFFECT_TYPE" == "gradient_flow" ]]; then
    if [[ -f "$WALLUST_COLORS_SOURCE" ]]; then
        mapfile -t WALLUST_COLORS < <(
            grep -E '^\$color[0-9]+' "$WALLUST_COLORS_SOURCE" | awk '
            function hex2(s){ return (length(s)==6 ? "0xff"s : ""); }
            function rgb2(r,g,b){ return sprintf("0xff%02x%02x%02x", r, g, b); }
            {
                if (match($0, /0x([0-9a-fA-F]{8})/, m)) { print "0x" m[1]; next }
                if (match($0, /#([0-9a-fA-F]{6})/, m))  { print hex2(m[1]); next }
                if (match($0, /rgb\(([0-9]+),[ ]*([0-9]+),[ ]*([0-9]+)\)/, m)) {
                    print rgb2(m[1], m[2], m[3]); next
                }
            }'
        )
    fi

    # Universal Fallback: If Wallust config is missing or parsing yielded 0 colors
    if (( ${#WALLUST_COLORS[@]} == 0 )); then
        EFFECT_TYPE="rainbow"
    fi
fi

# ---------- RANDOM WALLUST COLORS ----------
function wallust_random() {
    echo "${WALLUST_COLORS[RANDOM % ${#WALLUST_COLORS[@]}]}"
}

# ---------- RAINBOW COLORS ----------
function random_hex() {
    echo "0xff$(openssl rand -hex 3)"
}

# ---------- FLOW MODE SAFE ALLOCATION ----------
COLOR_COUNT=${#WALLUST_COLORS[@]}
# Prevent division by zero if array is empty
if (( COLOR_COUNT == 0 )); then COLOR_COUNT=1; fi

BASE_COLOR="${WALLUST_COLORS[10 % COLOR_COUNT]:-0xffffffff}"
GRAD1_COLOR="${WALLUST_COLORS[14 % COLOR_COUNT]:-0xffffffff}"
GRAD2_COLOR="${WALLUST_COLORS[13 % COLOR_COUNT]:-0xffffffff}"
GLOW_COLOR="${WALLUST_COLORS[15 % COLOR_COUNT]:-0xffffffff}"

MAX_POS=10
GLOW_POS=0

function gradient_flow_color() {
    local pos=$1
    local d=$(( pos - GLOW_POS ))

    # wrap distance (-9..9)
    if (( d >  MAX_POS/2 )); then d=$((d - MAX_POS)); fi
    if (( d < -MAX_POS/2 )); then d=$((d + MAX_POS)); fi

    case "${d#-}" in
        0) echo "$GLOW_COLOR" ;;
        1) echo "$GRAD1_COLOR" ;;
        2) echo "$GRAD2_COLOR" ;;
        *) echo "$BASE_COLOR" ;;
    esac

    if (( pos == MAX_POS - 1 )); then
        GLOW_POS=$(( (GLOW_POS + 1) % MAX_POS ))
    fi
}

# ---------- Main Logic Engine ---------- 

function get_color() {
    if [[ "$EFFECT_TYPE" == "wallust_random" && ${#WALLUST_COLORS[@]} -gt 0 ]]; then
        wallust_random
    elif [[ "$EFFECT_TYPE" == "gradient_flow" && ${#WALLUST_COLORS[@]} -gt 0 ]]; then
        gradient_flow_color "$1"
    else
        random_hex
    fi
}

# Continuous Execution Loop 
TICK=0
while true; do
    # 1. Update Active Border String
    ACTIVE_BORDER_STR=$(for i in {0..9}; do get_color "$i"; done)
    hyprctl keyword general:col.active_border ${ACTIVE_BORDER_STR} 270deg
    
    # 2. Update Inactive Border String at HALF speed (Every 2 ticks)
    if (( TICK % 2 == 0 )); then
        INACTIVE_BORDER_STR=$(for i in {0..9}; do get_color "$i"; done)
        hyprctl keyword general:col.inactive_border ${INACTIVE_BORDER_STR} 270deg
    fi
    
    # Speed throttle: Changed from 0.05s to 0.15s to make it less frantic
    sleep 0.15
    
    TICK=$(( (TICK + 1) % 100 ))
done


