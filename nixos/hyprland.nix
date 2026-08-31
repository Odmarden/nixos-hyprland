# hyprland.nix — NixOS module for Hyprland + Wofi
# Add this to your configuration.nix imports list:
#   imports = [ ./hyprland.nix ];

{ config, pkgs, lib, ... }:

{
  # Enable Hyprland as the Wayland compositor
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;   # XWayland compatibility for X11 apps
  };

  # Required system packages
  environment.systemPackages = with pkgs; [
    # Wayland essentials
    wofi               # App launcher (SUPER+R)
    waybar             # Status bar
    hyprpaper          # Wallpaper daemon
    hypridle           # Idle management
    hyprlock           # Screen locker
    
    # Notifications
    dunst
    libnotify

    # Terminal (adjust to your preferred terminal)
    kitty

    # Clipboard
    wl-clipboard
    cliphist

    # Audio
    pipewire
    wireplumber
    pavucontrol
    playerctl

    # Brightness (for laptops)
    brightnessctl

    # Screenshot
    grim
    slurp

    # File manager
    xdg-utils
    git

    # Icon theme (needed for Wofi app icons)
    papirus-icon-theme
    hicolor-icon-theme
  ];

  # Pipewire (modern audio subsystem, replaces PulseAudio)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # XDG portal (needed for screen sharing, file pickers, etc.)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Set Swedish locale and keyboard
  i18n.defaultLocale = "sv_SE.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT    = "sv_SE.UTF-8";
    LC_MONETARY       = "sv_SE.UTF-8";
    LC_NAME           = "sv_SE.UTF-8";
    LC_NUMERIC        = "sv_SE.UTF-8";
    LC_PAPER          = "sv_SE.UTF-8";
    LC_TELEPHONE      = "sv_SE.UTF-8";
    LC_TIME           = "sv_SE.UTF-8";
  };

  # Console keyboard layout
  console.keyMap = "sv-latin1";

  # X11 keyboard (also applies to Wayland sessions via libinput)
  services.xserver.xkb = {
    layout  = "se";
    variant = "";
  };

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
  ];

  # GTK icon theme (ensures Wofi can find and show app icons)
  programs.dconf.enable = true;
}
