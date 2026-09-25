# Port Ricelin Workspaces Hub + Top-level Wifi/Bt Pill Surfaces — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

Goal: Port two feature subsystems from the Ricelin snapshot (`~/Downloads/Ricelin`) into the user's quickshell fork at `~/.config/quickshell/` plus the Hypr side: (1) a Workspaces / Special-space hub, and (2) standalone top-level Wifi/Bt pill surfaces, trimming Link to inbox-only. Lock/color/Dyn pipeline is explicitly out of scope.

Success criterion: `hyprctl reload` succeeds, pill restarts without QML errors, Settings shows "Workspaces", hub lists Stash/Private/Minimized with the user's real key labels, custom spaces can be added/renamed/rebound, Stash edits `stash-apps.lua`, and wifi/bt open from the pill bar as standalone surfaces.

**Hard rule from the user: do not change anything except the features specified. Copy Ric ports as-is; the only edits are the required wiring, key-label truth, glyph additions, and the Hypr seed files.**

## Source of truth (exact paths)

- Ric surfaces: `~/Downloads/Ricelin/configs/quickshell/pill/{WorkspacesSurface,Stash,SpaceApps,AppPickerList,WifiSurface,BtSurface}.qml`
- Ric singleton: `~/Downloads/Ricelin/configs/quickshell/pill/Singletons/Spaces.qml`
- Ric settings row: `~/Downloads/Ricelin/configs/quickshell/pill/Settings.qml` (lines 143–158 workspacesRow)
- Ric hypr modules: `~/Downloads/Ricelin/configs/hypr/modules/spaces.lua`, `modules/spaces-apply.lua`, `scripts/special-toggle.sh`
- User live files: `~/.config/quickshell/pill/*.qml`, `~/.config/hypr/modules/*.lua`, `~/.config/hypr/hyprland.lua`

---

### Task 1: Copy the six workspace/wifi/bt surface files

**Files:**
- Copy from `~/Downloads/Ricelin/configs/quickshell/pill/` → `~/.config/quickshell/pill/`:
  - `AppPickerList.qml`
  - `Stash.qml`
  - `SpaceApps.qml`
  - `WorkspacesSurface.qml`
  - `WifiSurface.qml`
  - `BtSurface.qml`
- They reference `PillSurface`, `GlyphIcon`, `WifiGlyph`, `WheelScroller`, `LinkToggle`, `Filament`, `SearchField`, `SettingsSurface`, `AppPickerList`, and the `Singletons` qmldir — all already present in the user's fork (verifd). `EditBlock` is a local `component` inside `WorkspacesSurface.qml`.
- No edits to these six files except the key labels on `WorkspacesSurface.qml` (Task 4).

### Task 2: Replace `pill/Singletons/Spaces.qml` with the Ric version

- Copy `~/Downloads/Ricelin/configs/quickshell/pill/Singletons/Spaces.qml` → `~/.config/quickshell/pill/Singletons/Spaces.qml`.
- It's already registered in `pill/Singletons/ql>` (`singleton Spaces Spaces.qml`, line 20), so no qmldir edit.
- This adds `updateSpace`, `updateKey`, `glyph` persistence, `slug`/`clean`/`reserved`, `addApp`/`removeApp`, and `refresh()` brace-walk — nothing else in the user fork consumes `Spaces` today (verifed by grep).

### Task 3: Add the 4 missing glyphs to `pill/GlyphIcon.qml`

- Insert into `glyphs` object (alphabetical positions): `layers`, `trash`, `undo`, `gamepad`, using the exact `d` paths from `~/Downloads/Ricelin/configs/quickshell/pill/GlyphIcon.qml` lines 42/57/76/89 (all `fill: false`).
- Verify no existing glyph names collide.

### Task 4: Patch `WorkspacesSurface` built-in key labels

- In `~/.config/quickshell/pill/WorkspacesSurface.qml` (copied from Ric, lines ~58–60) change the three display strings to the user's real binds:
  - `stash`: `"Super + S"` → `"Super + A"`
  - `private`: `"Super + P"` → `"Super + I"`
  - `minimized`: `"Super + Shift + M"` → `"Super + Shift + H"`
- These are display-only; the actual bindings already exist in user `binds.lua` (lines 52–54) and are not touched.

---

### Task 5: Wire the pill — `pill/Pill.qml`

**Add props (near the existing `*Open`s, after line ~44):**
```
readonly property bool workspacesOpen: surface === "workspaces"
readonly property bool stashOpen: surface === "stash"
readonly property bool spaceappsOpen: surface === "spaceapps"
readonly property bool wifiOpen: surface === "wifi"
readonly property bool btOpen: surface === "bt"
```

**Add widths (near existing widths):**
```
readonly property real workspacesW: 392 * s
readonly property real stashW: 392 * s
readonly property real spaceappsW: 392 * s
readonly property real wifiW: 272 * s
readonly property real btW: 286 * s
```

**`surfaces` map entries (add after `keybinds`):**
```
workspaces: { size: () => Qt.size(workspacesW, workspaces.implicitHeight + 29 * s), ame: workspaces },
stash:     { size: () => Qt.size(stashW, stash.implicitHeight + 29 * s), ame: stash },
spaceapps: { size: () => Qt.size(spaceappsW, spaceapps.implicitHeight + 29 * s), ame: spaceapps },
wifi:      { size: () => Qt.size(wifiW, wifisurface.implicitHeight + 26 * s), ame: wifisurface },
bt:        { size: () => Qt.size(btW, btsurface.implicitHeight + 26 * s), ame: btsurface },
```

**Inline instances** (follow the existing `Link` inline pattern near line 1377):
```
WorkspacesSurface {
    id: workspaces
    s: pill.s
    open: pill.workspacesOpen
    morphCloseness: pill.morphCloseness
    onRequestClose: pill.requestClose()
    onRequestSurface: (name) => pill.requestSurface(name)
}
Stash {
    id: stash
    s: pill.s
    open: pill.stashOpen
    morphCloseness: pill.morphCloseness
    onRequestClose: pill.requestClose()
    onRequestSurface: (name) => pill.requestSurface(name)
}
SpaceApps {
    id: spaceapps
    s: pill.s
    open: pill.spaceappsOpen
    morphCloseness: pill.morphCloseness
    onRequestClose: pill.requestClose()
    onRequestSurface: (name) => pill.requestSurface(name)
}
WifiSurface { id: wifisurface; s: pill.s; open: pill.wifiOpen; morphCloseness: pill.morphCloseness; onRequestClose: pill.requestClose() }
BtSurface   { id: btsurface;   s: pill.s; open: pill.btOpen;   morphCloseness: pill.morphCloseness; onRequestClose: pill.requestClose() }
```

**`surfaceBack()` ordering** (extend exactly like Ric, after the `fontpicker` branch):
```
if (pill.stashOpen) { if (stash.addOpen) { stash.closeAdd(); return; } pill.requestSurface("workspaces"); return; }
if (pill.spaceappsOpen) { if (spaceapps.addOpen) { spaceapps.closeAdd(); return; } pill.requestSurface("workspaces"); return; }
if (pill.workspacesOpen && workspaces.formOpen) { workspaces.closeForm(); return; }
if (pill.appearanceOpen || ... || pill.workspacesOpen) { pill.requestSurface("settings"); return; }
```
- Replace `journal.open` list `&& ... || pill.workspacesOpen` inside that OR chain.

**Bar icons (interface Row, around line 950–1010):**
- Wifi icon `onClicked`: change `pill.linkInitialView = "wifi"; pill.requestSurface("link");` → `pill.requestSurface("wifi")`.
- Add a Bluetooth icon (before battery) modeled on Ric: `GlyphIcon { name: "bluetooth" }` with visible `pill.btAdapter !== null`, left-click `pill.requestSurface("bt")`, right-click toggles `pill.btAdapter.enabled = !pill.btAdapter.enabled`.
- Update the Row `visible` condition from `(pill.wifiDev !== null && pill.wifiOn) || Battery.present` to add the bt term: `(pill.wifiOn && pill.wifiDev !== null) || (pill.btAdapter !== null) || Battery.present`.
- Add `btAdapter`/`btOn` props to Pill (near `wifiDev`/`wifiOn`, lines ~52–60):
```
readonly property var btAdapter: (typeof Bluetooth !== "undefined" && Bluetooth) ? Bluetooth.defaultAdapter : null
readonly property bool btOn: btAdapter ? btAdapter.enabled === true : false
```

**Link plumbing cleanup (subsystem 2):**
- Remove/replace `linkInitialView` usage: keep the prop (harmless) but the inbox Link no longer exposes `initialView`. After the Link trim (Task 8), drop the `initialView:`/`onLinkOpenChanged` references in Pill (lines 1381/1386) or they'll warn; simplest: remove both.

### Task 6: Settings row — `pill/Settings.qml`

- Add row `workspacesRow` under Shell group mirroring Ric (Settings.qml lines 143–158), before `idleRow`:
```
SettingsRow { id: workspacesRow; surface: root; captionOnFocus: true; icon: "layers"; name: "Workspaces"; sub: "Special spaces and their keys" ...
```
- Append `{ item: workspacesRow, kind: "nav", surface: "workspaces" }` to the `rows:` array (after the keybinds entry).

### Task 7: Hypr side — spaces modules + script

- Create `~/.config/hypr/modules/spaces.lua` seeded with the three built-ins matching the user's binds (keys are for future custom rebinds only; per spec):
```
return {
    { id = "stash",     name = "Stash",     desc = "", key = "a", glyph = "layers",       apps = {} },
    { id = "private",   name = "Private",   desc = "", key = "i", glyph = "lock",         apps = {} },
    { id = "minimized", name = "Minimized", desc = "", key = "h", glyph = "chevron-down", apps = {} },
}
```
- Copy `modules/spaces-apply.lua` from Ric → `~/.config/hypr/modules/spaces-apply.lua` (guards keys, `pcall(require,"modules.spaces")`, per-app window_rule + `SUPER+key`/`SUPER+SHIFT+key` via special-toggle.sh). **Note:** the bind it emits for `stash`/`private`/`minimized` must not double-bind the user's own keys — strip the `hl.bind(...)` lines for those three IDs (the user already binds them in `binds.lua`).

  Simplest safe approach: edit the copied `spaces-apply.lua` to skip the three built-in ids (`stash`, `private`, `minimized`) — their toggles/`SHIFT+H` lives in `binds.lua` lines 48–54; only user-created custom spaces get auto-binds.
- Copy `scripts/special-toggle.sh` from Ricc → `~/.config/hypr/scripts/special-toggle.sh` (already executable) with `chmod +x`.
- `~/.config/hypr/hyprland.lua`: add `require("modules.spaces-apply")` after `require("modules.windowrules")`.

### Task 8: Trim `pill/Link.qml` to inbox-only

- Replace the whole user `Link.qml` with Ric's `/inbox-only Link.qml` (610 lines, only `import QtQuick`, `"Singletons"`). It exposes `desiredW` (330), is self-contained (Ember/NotifRow local components, `WheelScroller`, `GlyphIcon` "close"/"trash" already in GlyphIcon). No `subview`/`initialView`/`back()`/netDevices/Bluetooth — those all go away.
- Leave `pill/LinkWifi.qml` and `pill/LinkBt.qml` on disk, now unreferenced (per spec they stay).

### Task 9 — Verify

1. `hyprctl reload` (should succeed; watch for binding conflicts from spaces-apply).
2. `pkill -f "qs -c pill"` (auto-restarts) and check the pill's stdout for QML load errors.
3. Manual: Settings → Workspaces row opens hub; Stash/Private/Minimized show Super+A / Super+I / Super+Shift+H; create+rename+rebind a custom space; add/remove routed apps; open Stash surface and confirm `stash-apps.lua`.
4. `super+g` sanity: pill still renders in rest/hover/game modes (surfaces map untouched for others).
5. `grep` the QML error stream for `Workspaces`, `WifiSurface`, `BtSurface`, `Spaces`.