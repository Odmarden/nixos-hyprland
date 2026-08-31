#!/usr/bin/env bash
# install.sh — Setup Tokyo Night theme, Hyprland, Waybar (V1.9c), Zsh, Hyprlock, and Wallpaper Picker

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Setting up Hyprland & Lockscreen configs..."
mkdir -p "$HOME/.config/hypr"
if [ -f "$HOME/.config/hypr/hyprland.lua" ]; then
    mv "$HOME/.config/hypr/hyprland.lua" "$HOME/.config/hypr/hyprland.lua.bak"
    echo "    ✓ Backed up ~/.config/hypr/hyprland.lua to hyprland.lua.bak"
fi

rm -f "$HOME/.config/hypr/hyprland.conf"
cat << CONF > "$HOME/.config/hypr/hyprland.conf"
# Source the actual git config so inotify watches it for live reloads
source = $SCRIPT_DIR/hypr/hyprland.conf
CONF
echo "    ✓ ~/.config/hypr/hyprland.conf (sources $SCRIPT_DIR/hypr/hyprland.conf)"

ln -sfn "$SCRIPT_DIR/hypr/hyprpaper.conf" "$HOME/.config/hypr/hyprpaper.conf"
ln -sfn "$SCRIPT_DIR/hypr/hypridle.conf"  "$HOME/.config/hypr/hypridle.conf"
ln -sfn "$SCRIPT_DIR/hypr/hyprlock.conf"  "$HOME/.config/hypr/hyprlock.conf"
echo "    ✓ ~/.config/hypr/hyprpaper.conf -> $SCRIPT_DIR/hypr/hyprpaper.conf"
echo "    ✓ ~/.config/hypr/hypridle.conf  -> $SCRIPT_DIR/hypr/hypridle.conf"
echo "    ✓ ~/.config/hypr/hyprlock.conf  -> $SCRIPT_DIR/hypr/hyprlock.conf"

echo "==> Setting up Waybar (V1.9c)..."
rm -rf "$HOME/.config/waybar"
ln -sfn "$SCRIPT_DIR/waybar" "$HOME/.config/waybar"
echo "    ✓ ~/.config/waybar -> $SCRIPT_DIR/waybar"

echo "==> Setting up Zsh (Tokyo Night + Autosuggestions)..."
mkdir -p "$SCRIPT_DIR/zsh"
ln -sfn "$SCRIPT_DIR/zsh/.zshrc" "$HOME/.zshrc"
echo "    ✓ ~/.zshrc -> $SCRIPT_DIR/zsh/.zshrc"

echo "==> Setting up Kitty (Tokyo Night)..."
mkdir -p "$HOME/.config/kitty"
ln -sfn "$SCRIPT_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
echo "    ✓ ~/.config/kitty/kitty.conf -> $SCRIPT_DIR/kitty/kitty.conf"

echo "==> Setting up Wofi (Tokyo Night)..."
mkdir -p "$HOME/.config/wofi"
ln -sfn "$SCRIPT_DIR/wofi/config"    "$HOME/.config/wofi/config"
ln -sfn "$SCRIPT_DIR/wofi/style.css" "$HOME/.config/wofi/style.css"
echo "    ✓ ~/.config/wofi/config -> $SCRIPT_DIR/wofi/config"
echo "    ✓ ~/.config/wofi/style.css -> $SCRIPT_DIR/wofi/style.css"

echo "==> Setting up Dunst notifications (Tokyo Night)..."
mkdir -p "$HOME/.config/dunst"
ln -sfn "$SCRIPT_DIR/dunst/dunstrc" "$HOME/.config/dunst/dunstrc"
echo "    ✓ ~/.config/dunst/dunstrc -> $SCRIPT_DIR/dunst/dunstrc"

echo "==> Setting up Wallpaper Picker..."
mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications"
chmod +x "$SCRIPT_DIR/scripts/wallpaper-picker.sh"
ln -sfn "$SCRIPT_DIR/scripts/wallpaper-picker.sh" "$HOME/.local/bin/wallpaper-picker"
ln -sfn "$SCRIPT_DIR/applications/wallpaper-picker.desktop" "$HOME/.local/share/applications/wallpaper-picker.desktop"
echo "    ✓ ~/.local/bin/wallpaper-picker -> $SCRIPT_DIR/scripts/wallpaper-picker.sh"
echo "    ✓ ~/.local/share/applications/wallpaper-picker.desktop"

echo "==> Setting up Wallpaper directory..."
mkdir -p "$HOME/Bilder/wallpapers"
ln -sfn "$HOME/Bilder" "$HOME/bilder"
echo "    ✓ ~/bilder -> ~/Bilder (~/bilder/wallpapers ready)"

echo ""
echo "Done! All configs, theme settings, and scripts are linked and active."
