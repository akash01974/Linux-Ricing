# Rofi Configuration

A comprehensive rofi configuration setup with multiple themes, menus, and customization options.

## Overview

This repository contains a fully customized rofi configuration with:
- Multiple theme options
- Custom menu scripts for various applications
- Emoji support
- Terminal app launcher
- File search integration
- Wallpaper management
- Keybinding configuration

## Directory Structure

```
├── data/                    # Data files
│   ├── emoji-list.txt      # List of emojis
│   └── terminal-apps.list  # List of terminal applications
├── generated/              # Generated configuration files
│   └── colors.rasi         # Generated color scheme
├── helpers/                # Helper scripts
│   └── handler-theme-update.sh
├── menus/                  # Menu scripts
│   ├── aiomenu.sh
│   ├── emoji.sh
│   ├── keybinds.sh
│   ├── launcher.sh
│   ├── pkg-install-term.sh
│   ├── search-files.sh
│   ├── terminal-apps.sh
│   └── wallpaper.sh
├── plugins/                # Rofi plugins
│   └── emoji.so
└── themes/                 # Theme configurations
    ├── aiomenu.rasi
    ├── clipboard.rasi
    ├── default.rasi
    ├── keybinds.rasi
    ├── search-files.rasi
    ├── terminal.rasi
    ├── legacy/
    │   └── gruvbox-material.rasi
    └── shared/
        ├── colors.rasi
        └── fonts.rasi
```

## Installation

1. Clone this repository to your rofi config directory:
   ```bash
   git clone https://github.com/akash01974/rofi2.git ~/.config/rofi
   ```

2. Ensure scripts have execute permissions:
   ```bash
   chmod +x menus/*.sh helpers/*.sh
   ```

## Usage

### Launching Rofi

The main launcher menu can be executed via:
```bash
~/.config/rofi/menus/launcher.sh
```

### Available Menus

- **Launcher** - Main application launcher
- **Emoji** - Emoji picker with clipboard integration
- **Terminal Apps** - Quick access to terminal applications
- **File Search** - Search and open files
- **Wallpaper** - Set wallpaper from collection
- **Keybinds** - Display keybinding help
- **Package Install** - Terminal package manager interface

### Theme Selection

Multiple themes are available in the `themes/` directory:
- `default.rasi` - Default theme
- `aiomenu.rasi` - AIO menu theme
- `clipboard.rasi` - Clipboard theme
- `terminal.rasi` - Terminal theme
- `search-files.rasi` - File search theme
- `keybinds.rasi` - Keybindings theme

## Configuration

Edit theme files in `themes/` to customize:
- Colors and fonts (shared files in `themes/shared/`)
- Window size and position
- Font settings
- Color schemes

## Features

- **Multi-theme support** - Switch between different visual themes
- **Plugin support** - Includes emoji plugin
- **Customizable menus** - Easy-to-modify bash scripts
- **Color management** - Centralized color configuration
- **Legacy support** - Includes previous theme configurations

## Requirements

- Rofi
- Bash shell
- Standard Unix utilities (grep, awk, sed, etc.)
- Optional: xclip/xsel for clipboard operations

## License

This configuration is provided as-is for personal and educational use.

## Author

Akash - [GitHub Profile](https://github.com/akash01974)

---

For more information about rofi, visit: https://github.com/davatorium/rofi
