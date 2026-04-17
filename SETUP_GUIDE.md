# G-Hook: Defold Editor Step-by-Step Guide

This guide walks you through opening, verifying, building, and iterating on the project in Defold Editor. The source files are already generated — this is about making them work.

---

## Phase 1: First Launch

### 1.1 Open the Project
1. Launch Defold Editor
2. **File > Open Project** (not "New Project")
3. Navigate to the `g-hook/` folder and select `game.project`
4. The editor will load and show the project in the Asset Browser (left panel)

### 1.2 Fetch Built-in Libraries
1. **Project > Fetch Libraries**
2. Wait for it to complete — this downloads `builtins/` (materials, fonts, render scripts)
3. You should now see a `builtins/` folder in the Asset Browser

### 1.3 Verify File Structure
Confirm these exist in the Asset Browser:
```
game.project
input/game.input_binding
render/game.render
render/game.render_script
main/main.collection
main/player/player.script
main/player/player.atlas
main/camera/camera.script
main/level/level.script
main/level/checkpoint.script
main/level/anchor.atlas
main/level/level.atlas
main/hud/hud.gui
main/hud/hud.gui_script
main/util/screen_to_world.lua
assets/images/*.png
```

---

## Phase 2: First Build Attempt

### 2.1 Try Building
1. **Project > Build** (Cmd+B / Ctrl+B)
2. Watch the Console panel at the bottom for errors

### 2.2 If It Builds Successfully
You should see:
- A cyan square (player) near the top-left at ~(150, 300) world coords
- Yellow rectangular anchor strips along the corridor walls
- Green squares (checkpoints 1–4) along the S-shaped route
- A red square (finish line) near bottom-right
- A world-space timer near the finish (displays when first cable fires)
- HUD overlays at the top (speed, chain, cable count)

Controls: **Q** to fire hook, **E** to release, **WASD** for light steering, **right-click drag** to pan, **scroll** to zoom, **R** to restart.

### 2.3 If the Collection Fails to Parse
The `main.collection` file uses hand-written protobuf text which may have format issues. If the editor shows errors:

**Option A — Recreate in editor (recommended if many errors):**
Skip to [Phase 3: Manual Collection Setup](#phase-3-manual-collection-setup-if-parse-fails)

**Option B — Fix specific errors:**
The Console will show line numbers. Common issues:
- Missing quotes or escape characters in embedded data strings
- Wrong field names
- Open the file in a text editor and fix the specific line

---

## Phase 3: Manual Collection Setup (If Parse Fails)

If `main.collection` doesn't parse, recreate the game world manually in the editor.

### 3.1 Create a Fresh Collection
1. Right-click `main/` in Asset Browser > **New > Collection**
2. Name it `main` (overwrite the existing file when prompted)

### 3.2 Add the Player
1. In the Outline panel, right-click **Collection** > **Add Game Object**
2. Set **Id** to `player`
3. Set **Position** to `X: 150, Y: 300, Z: 0`
4. Right-click `player` > **Add Component From File** > select `main/player/player.script`
5. Right-click `player` > **Add Component (Embedded)** > **Sprite**
   - Set **Image** to `/main/player/player.atlas`
   - Set **Default Animation** to `idle`
   - Set **Material** to `/builtins/materials/sprite.material`
   - Set sprite **Z position** to `0.1`
6. Right-click `player` > **Add Component (Embedded)** > **Collision Object**
   - Type: `Dynamic`, Mass: `1.0`, Friction: `0.1`, Restitution: `0.3`
   - Linear Damping: `0.6`, Angular Damping: `1.0`
   - Locked Rotation: `true`
   - Group: `player`, Mask: `wall, anchor, checkpoint`
   - Add Shape > **Sphere** > radius `16`

### 3.3 Add the Camera
1. Right-click **Collection** > **Add Game Object**
2. Set **Id** to `camera`
3. Set **Position** to `X: 150, Y: 300, Z: 0` (match player start)
4. Right-click `camera` > **Add Component From File** > `main/camera/camera.script`
   - Set the `target` property to `/player`
5. Right-click `camera` > **Add Component (Embedded)** > **Camera**
   - Orthographic Projection: checked
   - Orthographic Zoom: `1.0`
   - Near Z: `-1.0`, Far Z: `1.0`
   - **Do not** call `acquire_camera_focus` — the render script uses `set_camera_pos` messaging instead

### 3.4 Add the Level Controller
1. Right-click **Collection** > **Add Game Object**, Id: `level`, Position: `0, 0, 0`
2. Right-click `level` > **Add Component From File** > `main/level/level.script`
   - Script Id must be `level_script` (the player messages `/level#level_script`)

### 3.5 Add the HUD
1. Right-click **Collection** > **Add Game Object**, Id: `hud`, Position: `0, 0, 0`
2. Right-click `hud` > **Add Component From File** > `main/hud/hud.gui`
   - Script Id must be `hud`

### 3.6 Add Arena Walls (Boundary)

For each wall, create a game object with an embedded **Collision Object**:
- Type: `Static`, Group: `wall`, Mask: `player`
- Add Shape > **Box**

| Wall Id | Position (X, Y) | Box Half-extents (W, H) |
|---------|-----------------|--------------------------|
| `wall_bottom` | 1500, 0 | 1500, 8 |
| `wall_top` | 1500, 2000 | 1500, 8 |
| `wall_left` | 0, 1000 | 8, 1000 |
| `wall_right` | 3000, 1000 | 8, 1000 |

**Note:** Box shape dimensions in Defold are **half-extents** (half the total size).

### 3.7 Add Internal Corridor Walls

The level uses a hallway layout. These walls create the S-shaped corridor:

| Wall Id | Position (X, Y) | Half-extents (W, H) | Purpose |
|---------|-----------------|----------------------|---------|
| `wall_mid_1` | 550, 450 | 450, 8 | Seg1 top |
| `wall_mid_2` | 550, 150 | 450, 8 | Seg1 bottom |
| `wall_mid_3` | 900, 600 | 8, 150 | Turn1 left |
| `wall_mid_4` | 1050, 600 | 8, 150 | Turn1 right |
| `wall_mid_5` | 1600, 1050 | 550, 8 | Seg2 top |
| `wall_mid_6` | 1600, 750 | 550, 8 | Seg2 bottom |
| `wall_mid_7` | 2150, 1200 | 8, 150 | Turn2 |

### 3.8 Add Anchor Points

For each anchor:
- **Sprite**: Image = `/main/level/anchor.atlas`, Animation = `idle`
- **Collision Object**: Type = `Static`, Group = `anchor`, Mask = `player`
  - Shape = **Box**, half-extents `24, 8, 1` (matches 48×16 sprite at scale 1×)
- **Scale**: `2, 2, 1` (scales sprite and collision to 96×32)

Place anchors along the corridor route so at least 2–3 are reachable from any position:

| Anchor Id | Position (X, Y) | Orientation |
|-----------|-----------------|-------------|
| `anchor_1` | 200, 400 | horizontal |
| `anchor_2` | 550, 300 | horizontal |
| `anchor_3` | 550, 400 | horizontal |
| `anchor_4` | 700, 250 | horizontal |
| `anchor_5` | 850, 350 | horizontal |
| `anchor_6` | 1050, 850 | horizontal |
| `anchor_7` | 1100, 950 | horizontal |
| `anchor_8` | 1600, 900 | horizontal |
| `anchor_9` | 2000, 900 | horizontal |
| `anchor_10` | 2100, 1000 | horizontal |
| `anchor_11` | 2500, 1300 | horizontal |
| `anchor_12` | 2800, 1600 | horizontal |

### 3.9 Add Checkpoints

For each checkpoint:
- **Sprite**: Image = `/main/level/level.atlas`, Animation = `checkpoint`, Z = `0.05`
- **Collision Object**: Type = `Trigger`, Group = `checkpoint`, Mask = `player`
  - Shape = **Sphere**, radius = `40`
- **Component From File**: `main/level/checkpoint.script`
  - Set `checkpoint_id` property to the number below
  - Leave `is_finish` = `false`
- **Scale**: `2, 2, 1`

| Checkpoint Id | `checkpoint_id` | Position (X, Y) |
|---------------|-----------------|-----------------|
| `cp_1` | 1 | 950, 300 |
| `cp_2` | 2 | 1100, 900 |
| `cp_3` | 3 | 2100, 900 |
| `cp_4` | 4 | 2500, 1500 |

**Order matters.** Touching them out of order triggers a 1.5s penalty and resets the run.

### 3.10 Add Finish Line
1. Create game object, Id: `finish`, Position: `2900, 1700`
2. Scale: `3, 3, 1`
3. Add Sprite: Image = `/main/level/level.atlas`, Animation = `finish`, Z = `0.05`
4. Add Collision Object: Type = `Trigger`, Group = `checkpoint`, Mask = `player`
   - Sphere shape, radius = `50`
5. Add Component From File > `main/level/checkpoint.script`
   - Set `is_finish` = `true`
   - The script will send `register_finish` to level so it can reset on wrong-order penalty

### 3.11 Build and Test
1. **Project > Build** (Cmd+B)

---

## Phase 4: Verify Core Mechanics

### 4.1 Movement
- [ ] WASD moves the player (light steering force)
- [ ] Player collides with walls
- [ ] Player retains momentum after cable release (DAMPING_LAUNCH window)

### 4.2 Hook Firing (Q key)
- [ ] Q fires toward cursor
- [ ] Blue cable line appears from player to hit point
- [ ] Hooking to anchor points works (cable attaches to anchor center)
- [ ] Hooking to walls works (cable attaches to surface hit point)
- [ ] Missing (aiming at empty space) does nothing

### 4.3 Pull Mechanic
- [ ] 1 cable: player is pulled directly toward anchor
- [ ] 2 cables: player moves toward bisector of both anchors
- [ ] 3 cables: player moves toward bisector of the last two anchors
- [ ] Player is capped at MAX_SPEED (900 px/s)
- [ ] Cable auto-releases when player arrives at anchor (within 120px)

### 4.4 Release (E key)
- [ ] E releases all cables
- [ ] Player coasts for ~1.5s before friction increases
- [ ] Player retains full velocity direction at moment of release

### 4.5 Chain Momentum
- [ ] Re-hooking within 3s shows chain counter in HUD
- [ ] Higher chain = noticeably stronger pull
- [ ] Chain resets after 3s gap

### 4.6 Checkpoint Ordering
- [ ] Checkpoints 1–4 are numbered (7-segment labels drawn above them)
- [ ] Hitting them in order advances to next
- [ ] Hitting them out of order shows "WRONG ORDER! RESETTING..." message
- [ ] Run resets after 1.5s penalty
- [ ] Touching finish before all 4 checkpoints also triggers reset

### 4.7 Timer
- [ ] Timer starts on first hook fire (Q press that connects)
- [ ] Timer displayed near finish line in world space (7-segment format: M:SS.T)
- [ ] Timer stops when finish is crossed after all 4 checkpoints
- [ ] R key resets timer, player position, and all checkpoint states

---

## Phase 5: Tuning

Open `main/player/player.script` and adjust these constants (lines 3–14):

| Constant | Default | Adjust If... |
|----------|---------|--------------|
| `PULL_FORCE` | 500 | Pull feels too weak/strong |
| `FREE_MOVE_FORCE` | 90 | Walking feels too sluggish/snappy |
| `MAX_SPEED` | 900 | Game feels too slow/fast |
| `DAMPING_FREE` | 0.6 | Player slides too much/stops too fast |
| `DAMPING_HOOKED` | 0.02 | Player decelerates while being pulled |
| `DAMPING_LAUNCH` | 0.25 | Post-release decel too quick/slow |
| `LAUNCH_DURATION` | 1.5 | Coast window after cable release |
| `CHAIN_WINDOW` | 3.0 | Hard/easy to maintain chain |
| `CHAIN_BONUS` | 0.20 | Chain speed boost too small/big |
| `HOOK_MAX_RANGE` | 1200 | Can't reach anchors / too easy |
| `AUTO_RELEASE_DIST` | 120 | Cable releases too early/late |

**Tuning loop:** Change constant → Cmd+B → test → repeat.

---

## Phase 6: Known Limitations

- Cable rendering uses `draw_line` (thin debug lines, no thickness or glow)
- Wall rendering uses `draw_line` (visible only — collision is physics-driven)
- Placeholder sprites are solid-color squares/rectangles
- Single level only
- No sound effects
- Best time persists via `sys.save()` (works in HTML5 via localStorage)

### Render Pipeline Note
The render script (`render/game.render_script`) uses a custom camera system:
- Camera sends `set_camera_pos` message each frame to the render script
- Render script builds the view matrix using `vmath.matrix4_look_at`
- Zoom factor is **0.5** (world is shown at 2× scale) — defined in both `game.render_script` and `main/util/screen_to_world.lua`
- **Do not** add a Camera component with `acquire_camera_focus` — it overrides the render projection and breaks GUI

### Atlas Format Note
Defold atlas files (`.atlas`) only allow `animations {}` blocks. Do **not** add top-level `images {}` blocks — they cause "atlas in use by another instance" errors at build time. All images must be inside an `animations {}` block.

---

## Phase 7: HTML5 Bundle

### 7.1 Build
1. **Project > Bundle > HTML5 Application**
2. Select output folder
3. Wait for build to complete

### 7.2 Test Locally
```
cd <output-folder>
python3 -m http.server 8080
```
Open `http://localhost:8080` in browser.

### 7.3 Test Checklist
- [ ] Game loads without console errors
- [ ] All sprites render (no missing texture errors)
- [ ] Q fires hook, E releases
- [ ] WASD steering works
- [ ] Right-click drag pans camera
- [ ] Scroll wheel zooms
- [ ] Checkpoint ordering enforced (wrong order resets)
- [ ] Timer starts on first hook, stops at finish
- [ ] Best time persists on page refresh (localStorage via sys.save)
- [ ] Test in both Chrome and Firefox

### 7.4 Ship to itch.io
1. Zip the entire output folder
2. On itch.io: create new project → upload zip
3. Set **Kind of project** = HTML
4. Set **Viewport dimensions** = 960 × 640
5. Check **SharedArrayBuffer support** if prompted

---

## Quick Reference

### Keyboard Shortcuts (Defold Editor)
| Shortcut | Action |
|----------|--------|
| Cmd+B | Build & Run |
| Cmd+Z | Undo |
| Cmd+S | Save |
| F5 | Hot Reload (while game is running) |

### Key Files to Edit
| What to change | File |
|----------------|------|
| Physics / pull feel | `main/player/player.script` (lines 3–14) |
| Level layout | `main/main.collection` (in editor) |
| Corridor walls | `main/level/level.script` (WALLS table) |
| Checkpoint positions/labels | `main/level/level.script` (CHECKPOINTS table) |
| Camera behavior | `main/camera/camera.script` |
| HUD display | `main/hud/hud.gui` + `hud.gui_script` |
| Controls | `input/game.input_binding` (in editor) |
| Background color | `render/game.render_script` |
| Zoom level | `render/game.render_script` zoom constant + `main/util/screen_to_world.lua` ZOOM constant (must match) |
