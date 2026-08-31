#!/usr/bin/env bash
# ==============================================================================
# wallpaper-picker — Browse and apply wallpapers with Wofi and Hyprpaper
# ==============================================================================

set -euo pipefail

export PATH="$HOME/.local/bin:/run/current-system/sw/bin:$PATH"

if [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
    HYPR_SIG=$(ls -1 /run/user/"$(id -u)"/hypr 2>/dev/null | head -n 1 || true)
    if [ -n "$HYPR_SIG" ]; then
        export HYPRLAND_INSTANCE_SIGNATURE="$HYPR_SIG"
    fi
fi

if [ -z "${WAYLAND_DISPLAY:-}" ]; then
    export WAYLAND_DISPLAY=$(ls -1 /run/user/"$(id -u)"/wayland-* 2>/dev/null | head -n 1 | xargs -r basename || echo "wayland-1")
fi
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

WALLPAPER_DIR="$HOME/bilder/wallpapers"
if [ ! -d "$WALLPAPER_DIR" ]; then
    WALLPAPER_DIR="$HOME/Bilder/wallpapers"
fi

CONFIG_FILE="$HOME/.config/hypr/hyprpaper.conf"
GIT_CONFIG_FILE="$HOME/git/hypr/hyprpaper.conf"
LOCK_CONFIG="$HOME/.config/hypr/hyprlock.conf"
GIT_LOCK_CONFIG="$HOME/git/hypr/hyprlock.conf"
STATE_FILE="$HOME/.cache/current_wallpaper"

notify() {
    local title="$1"
    local msg="$2"
    local icon="${3:-preferences-desktop-wallpaper}"
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -i "$icon" -a "Hyprpaper" "$title" "$msg"
    fi
}

get_wallpapers() {
    find -L "$WALLPAPER_DIR" -maxdepth 2 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.bmp" \) 2>/dev/null | sort
}

apply_wallpaper() {
    local wp="$1"
    if [ ! -f "$wp" ]; then
        echo "Fel: Filen finns inte: $wp" >&2
        return 1
    fi

    # Ensure hyprpaper daemon is running
    if ! pgrep -x hyprpaper >/dev/null 2>&1; then
        hyprpaper -c "$GIT_CONFIG_FILE" &
        sleep 0.3
    fi

    # Apply wallpaper to all monitors via hyprctl hyprpaper
    if command -v hyprctl >/dev/null 2>&1; then
        local mons
        mons=$(hyprctl monitors 2>/dev/null | grep "^Monitor" | awk '{print $2}' || true)
        if [ -n "$mons" ]; then
            for mon in $mons; do
                hyprctl hyprpaper wallpaper "${mon},${wp}" 2>/dev/null || true
            done
        else
            hyprctl hyprpaper wallpaper "eDP-1,${wp}" 2>/dev/null || true
        fi
    fi

    # Persist hyprpaper config
    local cfg_content="preload = $wp

wallpaper {
    monitor = eDP-1
    path = $wp
}

splash = false
ipc = on"

    echo "$cfg_content" > "$CONFIG_FILE"
    echo "$cfg_content" > "$GIT_CONFIG_FILE"

    # Synchronize hyprlock wallpaper path
    if [ -f "$GIT_LOCK_CONFIG" ]; then
        sed -i "s|path = .*|path = $wp|g" "$GIT_LOCK_CONFIG"
    fi
    if [ -f "$LOCK_CONFIG" ]; then
        sed -i "s|path = .*|path = $wp|g" "$LOCK_CONFIG"
    fi

    # Save state
    mkdir -p "$(dirname "$STATE_FILE")"
    echo "$wp" > "$STATE_FILE"

    local wp_name
    wp_name="$(basename "$wp")"
    echo "✓ Bakgrundsbild satt till: $wp_name"
    notify "Bakgrundsbild ändrad" "$wp_name" "$wp"
}

# 1. Direct file path argument
if [ $# -ge 1 ] && [ -f "$1" ]; then
    apply_wallpaper "$(realpath "$1")"
    exit 0
fi

# Gather wallpapers
mapfile -t WALLPAPERS < <(get_wallpapers)

if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    echo "Inga bakgrundsbilder hittades i $WALLPAPER_DIR" >&2
    notify "Hyprpaper" "Inga bakgrundsbilder hittades i $WALLPAPER_DIR" "dialog-warning"
    exit 1
fi

# 2. Random wallpaper flag
if [ "${1:-}" = "--random" ] || [ "${1:-}" = "-r" ]; then
    RAND_INDEX=$(( RANDOM % ${#WALLPAPERS[@]} ))
    apply_wallpaper "${WALLPAPERS[$RAND_INDEX]}"
    exit 0
fi

# 3. Next wallpaper flag
if [ "${1:-}" = "--next" ] || [ "${1:-}" = "-n" ]; then
    CURRENT=""
    [ -f "$STATE_FILE" ] && CURRENT="$(cat "$STATE_FILE")"
    NEXT_WP="${WALLPAPERS[0]}"
    for i in "${!WALLPAPERS[@]}"; do
        if [ "${WALLPAPERS[$i]}" = "$CURRENT" ]; then
            NEXT_INDEX=$(( (i + 1) % ${#WALLPAPERS[@]} ))
            NEXT_WP="${WALLPAPERS[$NEXT_INDEX]}"
            break
        fi
    done
    apply_wallpaper "$NEXT_WP"
    exit 0
fi

# 4. Previous wallpaper flag
if [ "${1:-}" = "--prev" ] || [ "${1:-}" = "-p" ]; then
    CURRENT=""
    [ -f "$STATE_FILE" ] && CURRENT="$(cat "$STATE_FILE")"
    PREV_WP="${WALLPAPERS[-1]}"
    for i in "${!WALLPAPERS[@]}"; do
        if [ "${WALLPAPERS[$i]}" = "$CURRENT" ]; then
            PREV_INDEX=$(( (i - 1 + ${#WALLPAPERS[@]}) % ${#WALLPAPERS[@]} ))
            PREV_WP="${WALLPAPERS[$PREV_INDEX]}"
            break
        fi
    done
    apply_wallpaper "$PREV_WP"
    exit 0
fi

# 5. Interactive Wofi Menu
WOFI_INPUT=""
for wp in "${WALLPAPERS[@]}"; do
    wp_name="$(basename "$wp")"
    WOFI_INPUT="${WOFI_INPUT}img:${wp}:text:${wp_name}\n"
done

SELECTED=$(echo -e -n "$WOFI_INPUT" | wofi \
    --dmenu \
    --allow-images \
    --prompt "🖼 Välj bakgrundsbild" \
    --insensitive \
    --hide-scroll \
    --width 550 \
    --height 400 \
    --lines 8 \
    --style "$HOME/.config/wofi/style.css" \
    2>/dev/null || true)

if [ -n "$SELECTED" ]; then
    if [[ "$SELECTED" =~ img:(.*):text:(.*) ]]; then
        CHOSEN="${BASH_REMATCH[1]}"
    elif [ -f "$WALLPAPER_DIR/$SELECTED" ]; then
        CHOSEN="$WALLPAPER_DIR/$SELECTED"
    else
        CHOSEN=""
        for wp in "${WALLPAPERS[@]}"; do
            if [ "$(basename "$wp")" = "$SELECTED" ] || [ "$wp" = "$SELECTED" ]; then
                CHOSEN="$wp"
                break
            fi
        done
    fi

    if [ -n "$CHOSEN" ] && [ -f "$CHOSEN" ]; then
        apply_wallpaper "$CHOSEN"
    fi
fi
