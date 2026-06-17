# Dotfiles

Personal Hyprland dotfiles featuring a Material You / Matugen color scheme.

![Screenshot](screenshots/placeholder.png)

## Overview

| Component | Tool |
|-----------|------|
| **Window Manager** | [Hyprland](https://hyprland.org/) (Lua config via HyprMod) |
| **Bar** | [Waybar](https://github.com/Alexays/Waybar) (Material You styling) |
| **Launcher** | [Rofi](https://github.com/davatorium/rofi) (Wayland) |
| **Notifications** | [SwayNC](https://github.com/ErikReider/SwayNotificationCenter) |
| **Logout Menu** | [Wlogout](https://github.com/ArtsyMacaw/wlogout) |
| **Terminal** | [Kitty](https://sw.kovidgoyal.net/kitty/) |
| **Shell** | Zsh + Powerlevel10k + Oh My Zsh |
| **Lock Screen** | [Hyprlock](https://github.com/hyprwm/hyprlock) |
| **Idle Daemon** | [Hypridle](https://github.com/hyprwm/hypridle) |
| **Theme Generator** | [Matugen](https://github.com/InioX/matugen) |
| **Color Scheme** | Material You (dynamic, wallpaper-derived) |

## Features

- Material You color scheme generated from wallpaper via Matugen
- Smooth animations with custom bezier curves and spring physics
- Unified theme switching (light/dark) via `themesw` script
- Clipboard manager with Rofi-based picker
- Power profile notifications
- Caffeine mode (inhibit sleep)
- Layout switching (Scrolling / Dwindle / Master)
- Workspace-specific window rules and blur effects
- GTK3/GTK4 theme integration

## Directory Structure

```
dotfiles/
├── config/          # Application configurations (~/.config/*)
│   ├── hypr/        # Hyprland WM config (Lua)
│   ├── waybar/      # Waybar bar with layouts
│   ├── kitty/       # Kitty terminal
│   ├── rofi/        # Application launcher & menus
│   ├── swaync/      # Notification center
│   ├── wlogout/     # Logout/power menu
│   ├── gtk-3.0/     # GTK3 settings
│   ├── gtk-4.0/     # GTK4 settings
│   ├── ags/         # AGS (Aylur's GTK Shell) widgets
│   ├── btop/        # System monitor
│   ├── cava/        # Audio visualizer
│   └── ...
├── home/            # Home directory dotfiles (~/.xyz)
│   ├── .bashrc
│   ├── .zshrc
│   ├── .p10k.zsh
│   ├── .gitconfig
│   └── .gtkrc-2.0
├── scripts/         # Utility scripts (~/.local/bin or ~/scripts)
│   ├── caffeine     # Inhibit sleep/suspend
│   ├── mictoggle    # Toggle microphone mute
│   ├── powerprofile # Switch power profiles
│   ├── themesw      # Theme switcher (dark/light)
│   └── ...
├── wallpapers/      # Wallpapers (gitignored, add your own)
├── screenshots/     # Screenshots (add your own)
├── install.sh       # Bootstrap installer
├── .gitignore
└── LICENSE
```

## Installation

### Quick Install

```bash
git clone https://github.com/akash01974/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

### Manual

The install script will:
1. Create backup of existing configs in `~/Backups/dotfiles-$(date)`
2. Symlink all config directories from `config/` to `~/.config/`
3. Symlink home dotfiles from `home/` to `~/`
4. Symlink scripts to `~/.local/bin/`
5. Create the `~/.local/bin/env` PATH helper if missing

### Dependencies

Required packages (Arch Linux):

```bash
# Core
hyprland waybar swaync wlogout rofi-lbonn-wayland kitty

# Utilities
hyprlock hypridle hyprshot matugen awww

# CLI
zsh oh-my-zsh-git powerlevel10k brightnessctl playerctl

# Other
pavucontrol blueman network-manager-applet
```

See each application's config for additional optional dependencies.

## Post-Install

1. Run `p10k configure` to set up Powerlevel10k prompt
2. Install Oh My Zsh: `sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
3. Set Zsh as default shell: `chsh -s $(which zsh)`
4. Generate colors with Matugen: `matugen image ~/wallpaper.jpg`
5. Add your own wallpapers to `~/Pictures/Wallpapers/`

## Secret Scan

Before pushing this repository, the install script performs a scan for common
secrets (API keys, tokens, passwords). If any are found, they must be redacted
before committing.

**Currently redacted:**
- `GEMINI_API_KEY` in `.bashrc` / `.zshrc` — replaced with placeholder

## Acknowledgements

- [Hyprland](https://hyprland.org/) — dynamic tiling Wayland compositor
- [Matugen](https://github.com/InioX/matugen) — Material You color generation
- [adi1090x](https://github.com/adi1090x/rofi) — Rofi theme base
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) — Zsh prompt theme
