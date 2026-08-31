# NixOS Hyprland Dotfiles

My personal dotfiles and configurations for **NixOS** running **Hyprland**, themed in **Tokyo Night**.

## Features

- **Compositor**: [Hyprland](https://hyprland.org) with rounded corners (`10px`), Tokyo Night gradient borders, window transparency, and custom keybindings.
- **Theme**: Tokyo Night across Hyprland, Waybar, Kitty, Wofi, Dunst, and Ghostty.
- **Status Bar**: [Waybar](https://github.com/Alexays/Waybar) with [HANCORE V1.9c](https://github.com/HANCORE-linux/waybar-themes#v19c) theme, segmented module pills, and transparent background.
- **Application Launcher**: [Wofi](https://hg.sr.ht/~scoopta/wofi) with Tokyo Night stylesheet.
- **Wallpaper Manager**: `hyprpaper` with interactive `wallpaper-picker` (supports Wofi UI, random, next, previous, and directory `~/bilder/wallpapers`).
- **Terminal**: [Kitty](https://sw.kovidgoyal.net/kitty/) with Tokyo Night color scheme.
- **Keyboard Layout**: Swedish (`se` / `sv-latin1`).

## Keybindings

| Keybinding | Action |
|---|---|
| `SUPER + Q` | Launch Kitty terminal |
| `SUPER + Return` | Launch Kitty terminal |
| `SUPER + R` | Launch Wofi application launcher |
| `SUPER + W` | Close active window |
| `SUPER + B` | Open graphical wallpaper picker |
| `SUPER + Shift + W` | Open graphical wallpaper picker |
| `SUPER + E` | Open Dolphin file manager |
| `SUPER + V` | Toggle floating window |
| `SUPER + M` | Exit Hyprland session |
| `SUPER + [1-9, 0]` | Switch workspace |
| `SUPER + Shift + [1-9, 0]` | Move window to workspace |

## Structure

```
├── applications/
│   └── wallpaper-picker.desktop  # Desktop launcher for wallpaper picker
├── dunst/
│   └── dunstrc                   # Tokyo Night notification configuration
├── hypr/
│   ├── hyprland.conf             # Main Hyprland configuration
│   └── hyprpaper.conf            # Hyprpaper wallpaper configuration
├── kitty/
│   └── kitty.conf                # Kitty terminal configuration
├── nixos/
│   └── hyprland.nix              # NixOS module for Hyprland system packages
├── scripts/
│   └── wallpaper-picker.sh       # Wallpaper switcher CLI & Wofi picker
├── waybar/
│   ├── config.jsonc              # Waybar module configuration (V1.9c)
│   ├── scrolling-mpris.py        # MPRIS media status helper
│   └── style.css                 # Waybar V1.9c Tokyo Night styling
├── wofi/
│   ├── config                    # Wofi launcher configuration
│   └── style.css                 # Wofi Tokyo Night styling
└── install.sh                    # Setup script to symlink configs into ~/.config
```

## Installation

Clone the repository to `~/git` and run the install script:

```bash
cd ~/git
./install.sh
```
