# Quickshell Animation Enhancements

## Goal

Add staggered content-reveal animations to all quickshell surfaces, the sidebar,
topbar, toasts, and OSD, giving the shell a polished, cohesive feel without
changing the existing morph/Ame/choreography systems.

## Approach: Staggered content reveal

Every surface gets a fade + slide (14–24 px) per content group. Groups appear in
sequence as the surface opens, keyed off the existing `morphCloseness` property
so they track the pill's physical growth rather than a separate timer.

## 1. `shared/Stagger.qml`

A lightweight, reusable QML component.

```
Stagger {
  // bound to parent surface's morphCloseness (0→1)
  property real progress: 1
  // 0-based position in the stagger sequence
  property int order: 0
  // total items sharing this stagger window
  property int total: 1
  // fraction of progress window the whole stagger occupies (0–1)
  property real span: 0.35
  // slide distance in px (0 = pure fade)
  property real slide: 20
  // direction of slide
  property int axis: Qt.YAxis
  // optional multiplier for child transforms
  property real factor: 1
}
```

`effectiveProgress` = `Math.max(0, (progress − span × order / (total−1)) / (1 − span))`

Produces:
- `opacity`: `effectiveProgress`
- `translateOffset`: `slide × (1 − effectiveProgress)`
- Binds to child's `opacity` and `transform`

## 2. Pill surfaces

### Calendar
- Header (month/year) — order 0
- Weekday row — order 1
- Date grid — order 2 (fades in as block via Stagger on the grid)

### Launcher
- Header (検索 + SEARCH) — order 0
- Search field — order 1
- Each app row in repeater — order = 2 + repeater index, total = 2 + count

### Power
- Header — order 0
- 4 tile row — each tile staggered order 1–4 (left→right)

### BatterySurface
- Header + state line — order 0
- Percentage hero — order 1
- Charge bar — order 2
- Stat rows (Rate, Health, Capacity) — orders 3–5

### Wallpaper
- Header + description — order 0
- Thumbnail row — order 1 (thumbs stagger horizontally via order as index)

### Clipboard
- Header — order 0
- History entries — order = 1 + repeater index

### Mixer
- Header row — order 0
- Hairline divider — order 1
- Fader row — order 2 (faders themselves staggered by their VFader index)

### Link
- Header (繋 LINK + unread ember) — order 0
- Netz row — order 1
- BT row — order 2
- Inbox header — order 3
- Notif groups — order = 4 + group index
- Drilled-in subviews (wifi/bt pages) retain their existing opacity crossfade

### Media
- Already has animations. Add stagger to:
  - Title (order 0), artist (order 1), service/time line (order 2), transport buttons (order 3)

## 3. Sidebar

### Sidebar.qml
- Card stack: Header (order 0), QuickStrip (order 1), content column (order 2)
- Stagger tied to `opened` → `_slideX` animation progress (0→1 over 280ms)

### Audio card
- Output SinkRow (0), Volume Slider (1), Divider (2), Input SinkRow (3), Mic Slider (4)

### Media card (sidebar)
- Art column (0), title line (1), artist line (2), controls row (3)

### NotifTab
- DND/Clear pill row (0), each notif group card (1+)

### QuickStrip
- DND pill, Keep Awake pill: add smooth gradient/color transitions on active toggle

## 4. Topbar

### Bar.qml
- Add `Behavior on color { ColorAnimation { duration: Motion.fast } }` to all interactive icon tints
- Workspace dots: smooth hover expansion (already partial, ensure consistency)

## 5. Toasts & OSD

### Toast (pill)
- Wrap in item with `transform: Translate { y: -20 }` on entry, animate to 0
- Existing opacity crossfade remains

### Toast popup (sidebar NotifPopup.qml)
- Same slide-down entry animation

### OSD (Osd.qml)
- Scale animation on flash: 0.95 → 1.0 over 200ms OutBack
- Existing opacity crossfade remains

## Implementation order

1. Create `shared/Stagger.qml`
2. Wire Stagger into `PillSurface.qml` base class (optional convenience binding)
3. Apply to each pill surface: Calendar, Launcher, Power, Battery, Wallpaper, Clipboard, Mixer, Link, Media
4. Sidebar stagger integration
5. Topbar hover transitions
6. Toast/OSD entry animations
