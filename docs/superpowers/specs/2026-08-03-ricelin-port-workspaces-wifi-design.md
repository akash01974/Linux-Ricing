# Port Ricelin Workspaces hub + top-level Wifi/Bt surfaces

Date: 2026-08-03
Status: Approved design

## Goal

Port two feature subsystems from the downloaded Ricelin snapshot
(`~/Downloads/Ricelin`, commits `7a8ae1c`, `1ce2bfb`) into the live quickshell
fork at `~/.config/quickshell/`:

1. Workspaces / Special-space hub: `WorkspacesSurface`, `Stash`, `SpaceApps`,
   `AppPickerList`, plus the missing `Spaces` singleton support and the Hypr
   side (`spaces.lua`, `spaces-apply.lua`, `special-toggle.sh`).
2. Promote WiFi and Bluetooth from subviews inside `Link.qml` to standalone
   top-level pill surfaces (port of Ric `WifiSurface.qml` / `BtSurface.qml`),
   trimming `Link.qml` back to inbox-only.

Explicitly **out of scope**: the lock process stays as-is; no color/Dyn/wall
pipeline changes.

## Architecture notes (divergence from Ric)

- User's fork instantiates pill surfaces as **inline components** (`Mixer { id: ... }`)
  with `open`/`morphCloseness`, not Ric's `Loader`/`surfaceItem(ldX)` pattern. New
  surfaces must follow the inline pattern.
- User's `Theme.qml` already defines every semantic token the ported Ric
  surfaces reference (`flameCore`, `flameGlow`, `border`, `frameBg`, `iconDim`,
  `tileBg`, `verm`, `vermDim`, `vermLit`, etc.) — no theme work.
- User's `GlyphIcon.qml` is **missing 4 glyphs**: `layers`, `trash`, `undo`,
  `gamepad`. Must be added.
- User's `Singletons/Spaces.qml` is registered but older: it lacks
  `updateSpace()`, `updateKey()`, and glyph persistence. Must be patched (can
  copy Ric's file wholesale since nothing else consumes Spaces today).

## Subsystem 1 — Workspaces hub

### Ported files (from `~/Downloads/Ricelin/configs/quickshell/pill/`)

| File | Destination | Notes |
|---|---|---|
| `AppPickerList.qml` | `~/.config/quickshell/pill/` | fuzzy add-app picker |
| `Stash.qml` | `~/.config/quickshell/pill/` | 蔵 surface, writes `.config/hypr/modules/stash-apps.lua` |
| `SpaceApps.qml` | `~/.config/quickshell/pill/` | per-space app manager |
| `WorkspacesSurface.qml` | `~/.config/quickshell/pill/` | settings page for special spaces |

These depend on `Spaces` singleton, `PillSurface` base, `GlyphIcon`, `lib/fuzzy.js`,
`lib/keychord.js` — all present or added. Copy as-is; no per-file edits unless a
dependency check fails.

### `pill/Singletons/Spaces.qml`
Replace with Ric version (adds `updateSpace`, `updateKey`, `glyph` persist,
`refresh()` brace-walk parse). Nothing else references this singleton, so
wholesale copy is safe.

### `pill/Settings.qml`
- Add `Workspaces` row (icon `layers`, name "Workspaces", sub
  "Special spaces and their keys") under the Shell group, before Idle/Lock.
- Append `{ item: workspacesRow, kind: "nav", surface: "workspaces" }` to `rows[]`.

### `pill/Pill.qml`
- Add props: `workspacesOpen`, `stashOpen`, `spaceappsOpen` (string checks on `surface`).
- Add widths `workspacesW`/`stashW`/`spaceappsW` (392 * s) matching Ric.
- Add `surfaces{}` entries for `workspaces`, `stash`, `spaceapps`.
- Instantiate the three surfaces inline with `open`/`morphCloseness`/`s`/
  `onRequestSurface: (name) => pill.requestSurface(name)` and `onRequestClose`.
  - `Stash`/`SpaceApps` also carry `addOpen`/`closeAdd` used by `surfaceBack()`.
- Extend `surfaceBack()` per Ric ordering:
  - `stash` → if picker open, `closeAdd()`, else → `workspaces`
  - `spaceapps` → same
  - `workspaces` → if `formOpen`, `closeForm()`, else → `settings`
- `PillSurface` base surfaces (`Stash`/`SpaceApps`/`Workspaces`) carry
  `ameForm: "off"` and their own header-back; the pill host routes the stack
  back (spaceapps/stash → workspaces → settings) via `surfaceBack()`.

### Hypr side (all new)
- `~/.config/hypr/modules/spaces.lua` — seed as empty
  `return { { id = "stash", name = "Stash", desc = "", key = "a", glyph = "layers", apps = {} }, ... }`
  matching the three built-in rows (`stash`, `private`, `minimized`), so
  `spaces-apply.lua` has ground truth.
- `~/.config/hypr/modules/spaces-apply.lua` — port from Ric: per-space
  `window_rule` routing + `SUPER+<key>`/`SUPER+SHIFT+<key>` binds via
  `special-toggle.sh`. Guard every field; `pcall(require, "modules.spaces")`.
- `~/.config/hypr/scripts/special-toggle.sh` — port from Ric.
- `~/.config/hypr/hyprland.lua` — add `require("modules.spaces-apply")` after
  `modules.windowrules`.

### Key-label patch (user binds differ from Ric)
Ric `WorkspacesSurface.qml` hardcodes display strings `Super + S` / `Super + P`
/ `Super + Shift + M` for the built-in Stash/Private/Minimized rows (lines
~58-60). The user's real binds in `.config/hypr/modules/binds.lua` are:
`Super + A` stash, `Super + I` private, `Super + Shift + H` minimized.
Patch the three built-in `key` strings to match the user's binds.

Note: the built-in keys are *display-only*; the actual raw bind no longer
lives in `spaces-apply.lua` (the binds come from `binds.lua` special lines).
This is a UI-truthfulness patch, not a rebind.

## Subsystem 2 — Wifi/Bt top-level surfaces

**Ported files:**
- `WifiSurface.qml` (hotspot + saved-profile reveal) → `pill/`
- `BtSurface.qml` (pair-trust-connect) → `pill/`

**Link trim:** `pill/Link.qml` — remove the wifi/bt drill-in; delete imports/
subview state machinery (`subview`, `initialView`, `desiredW` subview
branching, LinkWifi/LinkBt usage), leave the notification inbox + `desiredW`
fixed. Conflicts: keep `pill/LinkWifi.qml`/`LinkBt.qml` files on disk (they
may be referenced elsewhere) but they become unreferenced by `Link.qml`.

**Pill edges:**
- `pill/Pill.qml`: add `wifiOpen`/`btOpen`, widths `wifiW=272*s`/`btW=286*s`,
  `surfaces{}` entries, inline instances.
- Bar icons: wifi click → `requestSurface("wifi")` (instead of
  `linkInitialView="wifi"` + `requestSurface("link")`). Add a **BT icon**
  (from Ric, `GlyphIcon` name `bluetooth`) that opens `requestSurface("bt")`;
  right-click toggles wifi/bt adapter (keep Ric's right-click behavior).
- `surfaceBack()`: wifi/bt → `requestClose()` (standalone root surfaces, Ric
  behavior).

## Migration / ownership

- All targets under `~/.config/quickshell/` and `~/.config/hypr/` are live
  files (not repo symlinks). No git changes needed.
- After edits: restart pill (`pkill -f "qs -c pill"`), `hyprctl reload`, and
  validate surfaces open/morph.

## Success criteria

1. Settings shows a `Workspaces` row opening the workspaces hub.
2. Hub lists Stash/Private/Minimized with correct Super-key labels; can
   create a custom space, rename it, rebind, and add/remove routed apps.
3. Stash surface edits `stash-apps.lua` and reloads Hypr.
4. Wifi and Bt are standalone pill surfaces reachable from the pill bar.
5. Link surface is notification-inbox only.
6. `hyprctl reload` succeeds; no QML load errors.

## Non-goals

- Lock/color/Dyn pipeline.
- Merging topbar/sidebar/shared animation lib (already present in fork).