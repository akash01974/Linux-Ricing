# Rofi Configuration Structure

## Overview

```
~/.config/rofi/
├── menus/          # Entry-point scripts (one per menu)
├── helpers/        # Internal helper scripts (not launched directly)
├── themes/         # .rasi theme files + shared imports
│   ├── shared/     # Color/font variables imported by all themes
│   └── legacy/     # Unused but preserved themes
├── generated/      # Auto-generated files (matugen output)
├── data/           # Static data files (app lists, databases)
├── plugins/        # Prebuilt rofi plugins (.so files)
└── README-STRUCTURE.md
```

---

## Directory Purposes

### `menus/`
Every file here is a user-facing Rofi menu. Each is bound to a keyboard shortcut
via Hyprland's `binds.lua`. No file in `menus/` should ever be imported by
another menu — they are independent entry points.

Current menus:
| File | Binds | Purpose |
|---|---|---|
| `launcher.sh` | `ALT + Space` | App launcher (rofi -show drun) |
| `aiomenu.sh` | `SUPER + ALT + Space` | Hub menu → sub-menus |
| `terminal-apps.sh` | `SUPER + SHIFT + T` | Launch terminal apps from a list |
| `wallpaper.sh` | `SUPER + W` | Pick wallpaper → triggers theme update |
| `emoji.sh` | (via aiomenu.sh) | Emoji picker (rofi emoji plugin) |
| `powermenu.sh` | (unbound) | Lock/logout/suspend/reboot/shutdown |

Adding a new menu:
1. Create `menus/your-menu.sh`
2. Create `themes/your-menu.rasi` if needed
3. Bind it in `~/.config/hypr/modules/binds.lua`

### `helpers/`
Internal scripts that menus call. Not launched directly by the user.
- `handler-theme-update.sh` — Called by `wallpaper.sh`. Runs matugen, updates
  colors across all apps, caches wallpaper.

### `themes/`
All `.rasi` files that control Rofi appearance. Each menu script references
its theme by path: `$HOME/.config/rofi/themes/<name>.rasi`.

Structure:
- `themes/<name>.rasi` — Individual menu themes
- `themes/shared/` — Common imports (colors, fonts) included by all themes
- `themes/legacy/` — Unused themes preserved for reference

Theme import chain:
```
themes/<menu>.rasi
  ├── @import "shared/colors.rasi"
  │     └── @import "~/.config/rofi/generated/colors.rasi"  (matugen output)
  └── @import "shared/fonts.rasi"
```

### `generated/`
Contains files that are auto-generated and should NOT be edited manually.
- `generated/colors.rasi` — Output of matugen's rofi template. Overwritten
  every time the wallpaper changes.

These files are ideal candidates for `.gitignore`.

### `data/`
Static data files that menus read at runtime.
- `data/terminal-apps.list` — Tab-separated database of terminal applications.
  Format: `icon<TAB>category<TAB>display-name<TAB>command`

### `plugins/`
Prebuilt Rofi plugins (shared objects). Currently:
- `plugins/emoji.so` — Rofi emoji picker plugin

## Menu Flow

```
Keybind
  └── menus/<script>.sh
        ├── reads data/ or external sources
        ├── uses themes/<theme>.rasi for appearance
        ├── (optionally) calls helpers/<helper>.sh
        └── (optionally) spawns another menu
```

## Theme Flow (wallet → screen)

```
User picks wallpaper
  └── menus/wallpaper.sh
        └── helpers/handler-theme-update.sh
              └── matugen image "$WP"
                    ├── (template) matugen/templates/rofi-colors.rasi
                    └── (output) → rofi/generated/colors.rasi
                                      └── referenced by themes/shared/colors.rasi
                                            └── imported by all themes/*.rasi
```

## Dependency Graph

```
menus/launcher.sh → themes/default.rasi → themes/shared/{colors,fonts}.rasi → generated/colors.rasi
menus/aiomenu.sh  → themes/aiomenu.rasi  → themes/shared/{colors,fonts}.rasi → generated/colors.rasi
                  → menus/terminal-apps.sh
                  → menus/wallpaper.sh → helpers/handler-theme-update.sh
                  → hypr/scripts/clipboard-picker.sh [external] → themes/clipboard.rasi
                  → menus/emoji.sh → themes/default.rasi + plugins/emoji.so
menus/wallpaper.sh → themes/default.rasi
                   → helpers/handler-theme-update.sh → matugen → generated/colors.rasi
menus/terminal-apps.sh → themes/terminal.rasi + data/terminal-apps.list
menus/powermenu.sh → themes/default.rasi
```

## Where to Add Future Menus

| Menu Type | Script | Theme | Data | Helper |
|---|---|---|---|---|
| System Monitor | `menus/sysmon.sh` | `themes/sysmon.rasi` | — | — |
| Bluetooth | `menus/bluetooth.sh` | `themes/bluetooth.rasi` | — | `helpers/bt-helper.sh` |
| WiFi | `menus/wifi.sh` | `themes/wifi.rasi` | — | `helpers/wifi-helper.sh` |
| Media | `menus/media.sh` | `themes/media.rasi` | `data/media.list` | — |
| Screenshots | `menus/screenshots.sh` | `themes/screenshots.rasi` | — | — |
| Bookmarks | `menus/bookmarks.sh` | `themes/bookmarks.rasi` | `data/bookmarks.list` | — |
| Projects | `menus/projects.sh` | `themes/projects.rasi` | `data/projects.list` | — |
| Scripts | `menus/scripts.sh` | `themes/scripts.rasi` | — | — |

No structural changes needed — just add files to the existing folders.
