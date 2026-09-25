# Quickshell Animation Enhancements — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add staggered content-reveal animations to all quickshell surfaces, sidebar, topbar, toasts, and OSD.

**Architecture:** A shared `Stagger.qml` component drives per-item fade+slide from the parent surface's `morphCloseness`. Each surface wraps its content groups in `Stagger` with increasing `order` values. Sidebar and topbar get analogous treatment.

**Tech Stack:** QML (QtQuick), Quickshell

---

### Task 1: Create `shared/Stagger.qml`

**Files:**
- Create: `~/.config/quickshell/shared/Stagger.qml`
- Modify: `~/.config/quickshell/shared/qmldir`

**Stagger.qml**: A non-visual helper. Wraps a single child item and drives its `opacity` and `transform` (Translate) based on a `progress` input and the item's position in a stagger sequence.

- `progress` (real, default 0): 0..1 from the parent surface's morphCloseness
- `order` (int, default 0): 0-based position in the stagger sequence
- `total` (int, default 1): how many items share this stagger window
- `span` (real, default 0.35): fraction of the progress range the stagger occupies
- `slide` (real, default 20): pixels to slide; negative = reverse direction
- `axis` (int, default Qt.YAxis): Qt.YAxis or Qt.XAxis for slide direction

Internally computes:
```
effectiveProgress = Math.max(0, (progress - span * order / Math.max(1, total - 1)) / (1 - span))
```

Binds child `opacity` to `effectiveProgress` and adds a `Translate` transform with `y` (or `x`) set to `slide * (1 - effectiveProgress)`.

```qml
import QtQuick

Item {
    id: root
    clip: false

    property real progress: 1
    property int order: 0
    property int total: 1
    property real span: 0.35
    property real slide: 20
    property int axis: Qt.YAxis

    readonly property real delay: total <= 1 ? 0 : (span * order / Math.max(1, total - 1))
    readonly property real ep: progress <= 0 ? 0 : (progress <= delay ? 0 : Math.min(1, (progress - delay) / (1 - delay)))

    opacity: root.ep
    transform: Translate {
        y: root.axis === Qt.YAxis ? root.slide * (1 - root.ep) : 0
        x: root.axis === Qt.XAxis ? root.slide * (1 - root.ep) : 0
    }
}
```

**qmldir** — add line:
```
Stagger Stagger.qml
```

- [ ] **Step 1: Create Stagger.qml**
- [ ] **Step 2: Update shared/qmldir**

---

### Task 2: Calendar surface — stagger reveal

**Files:**
- Modify: `~/.config/quickshell/pill/Calendar.qml`

Three stagger groups:
1. Header (月/年 label + nav arrows) — order 0
2. Weekday row — order 1
3. Date grid — order 2

Add `import "../shared"` at top.

Wrap header in Stagger:
```qml
Stagger {
    progress: root.morphCloseness
    order: 0
    total: 3
    slide: 14
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: 24 * root.s

    // existing header Row content
    Row { ... }
}
```

Wrap weekdays row in Stagger (order 1). Wrap the Grid (date grid) in Stagger (order 2, slide 14).

- [ ] **Step 1: Add import and wrap header in Stagger**
- [ ] **Step 2: Wrap weekdays row in Stagger (order 1)**
- [ ] **Step 3: Wrap date grid in Stagger (order 2)**

---

### Task 3: Launcher surface — stagger reveal

**Files:**
- Modify: `~/.config/quickshell/pill/Launcher.qml`

Three stagger groups:
1. Search field — order 0
2. Divider — order 1
3. ListView — order 2 (list items don't stagger individually, just the list appears)

Add `import "../shared"`.

- [ ] **Step 1: Wrap search field in Stagger (order 0)**
- [ ] **Step 2: Wrap divider + list in Stagger (order 1, order 2)**

---

### Task 4: Power surface — stagger reveal

**Files:**
- Modify: `~/.config/quickshell/pill/Power.qml`

Two stagger groups:
1. Header — order 0
2. Tiles row + label — order 1 (tiles appear together)

Add `import "../shared"`.

- [ ] **Step 1: Wrap header in Stagger (order 0)**
- [ ] **Step 2: Wrap tiles + label in Stagger (order 1)**

---

### Task 5: Battery surface — stagger reveal

**Files:**
- Modify: `~/.config/quickshell/pill/BatterySurface.qml`

Six stagger groups (slide 14, axis Y):
1. Header row (蓄 + BATTERY + state) — order 0
2. Percentage hero — order 1
3. Charge bar — order 2
4. Stat rows (Rate, Health, Capacity) — each order 3, 4, 5

Add `import "../shared"`. Wrap each section.

- [ ] **Step 1: Wrap header in Stagger (order 0)**
- [ ] **Step 2: Wrap percentage hero in Stagger (order 1)**
- [ ] **Step 3: Wrap charge bar in Stagger (order 2)**
- [ ] **Step 4: Wrap each StatRow in Stagger (orders 3–5)**

---

### Task 6: Wallpaper surface — stagger reveal

**Files:**
- Modify: `~/.config/quickshell/pill/Wallpaper.qml`

Three stagger groups:
1. Search bar (when visible) — order 0
2. "壁" watermark — order 0 (same as header)
3. Thumbnail strip Repeater — order 1

Add `import "../shared"`.

- [ ] **Step 1: Wrap header/search in Stagger (order 0)**
- [ ] **Step 2: Wrap thumbnail area in Stagger (order 1)**

---

### Task 7: Clipboard surface — stagger reveal

**Files:**
- Modify: `~/.config/quickshell/pill/Clipboard.qml`

Three stagger groups:
1. Search field — order 0
2. Divider — order 1
3. ListView entries — order 2

Add `import "../shared"`.

- [ ] **Step 1: Wrap search in Stagger (order 0)**
- [ ] **Step 2: Wrap divider + list in Stagger (order 1, order 2)**

---

### Task 8: Mixer surface — stagger reveal

**Files:**
- Modify: `~/.config/quickshell/pill/Mixer.qml`

Three stagger groups:
1. Header (調 + MIXER + icon chips) — order 0
2. Hairline divider — order 1
3. Fader row — order 2

Add `import "../shared"`.

- [ ] **Step 1: Wrap header in Stagger (order 0)**
- [ ] **Step 2: Wrap divider in Stagger (order 1)**
- [ ] **Step 3: Wrap faderRow in Stagger (order 2)**

---

### Task 9: Link surface — stagger reveal

**Files:**
- Modify: `~/.config/quickshell/pill/Link.qml`

Five stagger groups (slide 14):
1. Header (繋 LINK + unread ember) — order 0
2. Netz row — order 1
3. BT row — order 2
4. Inbox header (報 + INBOX + clear) — order 3
5. Notification flickable or empty state — order 4

Add `import "../shared"`. Wrap each group in the mainView Column.

- [ ] **Step 1: Wrap header in Stagger (order 0)**
- [ ] **Step 2: Wrap Netz row in Stagger (order 1)**
- [ ] **Step 3: Wrap BT row in Stagger (order 2)**
- [ ] **Step 4: Wrap inbox header in Stagger (order 3)**
- [ ] **Step 5: Wrap notif list in Stagger (order 4)**

---

### Task 10: Media surface (pill) — stagger reveal

**Files:**
- Modify: `~/.config/quickshell/pill/Media.qml`

Four stagger groups (slide 14):
1. Title (Marquee) — order 0
2. Artist (Marquee) — order 1
3. Service/time line — order 2
4. Transport buttons (前, seal, 次) — order 3

Add `import "../shared"`. The existing cover art and background remain unchanged (they're behind the text).

- [ ] **Step 1: Wrap title in Stagger (order 0)**
- [ ] **Step 2: Wrap artist in Stagger (order 1)**
- [ ] **Step 3: Wrap time line in Stagger (order 2)**
- [ ] **Step 4: Wrap transport row in Stagger (order 3)**

---

### Task 11: Sidebar — stagger content reveal

**Files:**
- Modify: `~/.config/quickshell/sidebar/Sidebar.qml`
- Modify: `~/.config/quickshell/sidebar/Audio.qml`
- Modify: `~/.config/quickshell/sidebar/Media.qml`
- Modify: `~/.config/quickshell/sidebar/NotifTab.qml`
- Modify: `~/.config/quickshell/sidebar/QuickStrip.qml`

No Stagger component needed here — use the existing `_slideX` animation progress. Compute a proxy: the sidebar slides over 280ms, so approximate progress as `1 - _slideX / (panelWidth + 24*s)`.

Add a `readonly property real _openProgress: 1 - Math.min(1, _slideX / (panelWidth + 24 * s))` to Sidebar.qml.

Pass `_openProgress` down to children as a `openProgress` property, or use it inline.

**Sidebar.qml** — stagger the 3 main sections:
1. Header (order 0)
2. QuickStrip or network/media content (order 1) 
3. NotifTab or audio/bluetooth/display column (order 2)

Use a simple approach: set `Behavior on opacity` with different `PauseAnimation` durations.

Actually simpler: instead of Stagger, use a property `openProgress` that child items bind to with delayed opacity. Each Card gets:
```
opacity: Math.max(0, Math.min(1, (openProgress - delay) / (1 - delay)))
```
where delay increases per card.

**Audio.qml**: Add stagger to rows (SinkRow, VolRow, divider, SinkRow, VolRow). Pass openProgress from parent.

**Media.qml**: Add stagger to art, title, artist, controls.

**NotifTab.qml**: Add stagger to DND/Clear pills, then each group card.

**QuickStrip.qml**: Add `Behavior on color` and `Behavior on border.color` to toggle pills for smooth transitions.

- [ ] **Step 1: Add `_openProgress` property to Sidebar.qml**
- [ ] **Step 2: Stagger cards in Sidebar.qml content**
- [ ] **Step 3: Add stagger rows in Audio.qml**
- [ ] **Step 4: Add stagger rows in sidebar Media.qml**
- [ ] **Step 5: Add stagger groups in NotifTab.qml**
- [ ] **Step 6: Add color transitions in QuickStrip.qml**

---

### Task 12: Topbar hover transitions

**Files:**
- Modify: `~/.config/quickshell/topbar/Bar.qml`

Add `Behavior on color { ColorAnimation { duration: Motion.fast } }` to all interactive elements:
- Workspace dots (already handled in Workspaces.qml, verify)
- Tray icons in Tray.qml
- Minimized.qml
- Power.qml (topbar version)
- SidebarButton.qml

Also ensure workspace dots have smooth hover expansion (check Workspaces.qml in topbar).

- [ ] **Step 1: Add color transitions to Bar.qml interactive items**

---

### Task 13: Toast/OSD entry animations

**Files:**
- Modify: `~/.config/quickshell/pill/Toast.qml`
- Modify: `~/.config/quickshell/pill/Osd.qml`
- Modify: `~/.config/quickshell/sidebar/NotifPopup.qml`

**Toast.qml (pill)**: On appear, slide down from above.
- Wrap root content in Item with `transform: Translate { y: -20 * s }` and `opacity: 0` initially
- When notification becomes active, animate `opacity` to 1 and `transform.translation.y` to 0
- Use `Behavior` on both with `Motion.standard`

**Osd.qml**: On flash, add a brief scale bounce.
- Wrap root Item and add `scale: 1`
- When `flashing` becomes true, momentarily scale to 1.05 then back
- Use `SequentialAnimation` or `Behavior on scale`

**NotifPopup.qml (sidebar)**: Add slide-down entry.
- Wrap root Rectangle, add translate + opacity entry animation triggered when notification appears

- [ ] **Step 1: Add slide-down entry to pill Toast.qml**
- [ ] **Step 2: Add scale bounce to Osd.qml**
- [ ] **Step 3: Add slide-down entry to sidebar NotifPopup.qml**

---

### Task 14: Verify and restart

**Files:**
- All modified files

- [ ] **Step 1: Restart quickshell pill**
      `pkill -f "qs -c pill" && nohup qs -c pill -d >/dev/null 2>&1 &`
- [ ] **Step 2: Restart quickshell sidebar**
- [ ] **Step 3: Restart quickshell topbar**
- [ ] **Step 4: Visual check** — open each surface, verify stagger animations play smoothly
