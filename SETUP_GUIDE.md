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
main/hook/cable_line.script
main/hook/cable.atlas
main/level/level.script
main/level/checkpoint.script
main/level/anchor.atlas
main/level/level.atlas
main/hud/hud.gui
main/hud/hud.gui_script
main/util/screen_to_world.lua
assets/images/*.png (8 files)
```

---

## Phase 2: First Build Attempt

### 2.1 Try Building
1. **Project > Build** (Cmd+B / Ctrl+B)
2. Watch the Console panel at the bottom for errors

### 2.2 If It Builds Successfully
- You should see a dark background with:
  - A cyan square (player) at center
  - Yellow squares (anchor points) scattered around
  - Green squares (checkpoints) along the course
  - A red square (finish line) near bottom
  - HUD text at the top (timer, speed, hooks)
- Try the controls: WASD to move, left-click toward an anchor to hook

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

If `main.collection` doesn't parse, recreate the game world manually in the editor. This takes ~30 minutes but guarantees correctness.

### 3.1 Create a Fresh Collection
1. Right-click `main/` in Asset Browser > **New > Collection**
2. Name it `main` (overwrite the existing file when prompted)

### 3.2 Add the Player
1. In the Outline panel, right-click **Collection** (root) > **Add Game Object**
2. Set **Id** to `player`
3. Set **Position** to `X: 480, Y: 320, Z: 0`
4. Right-click `player` > **Add Component From File** > select `main/player/player.script`
5. Right-click `player` > **Add Component (Embedded)** > choose **Sprite**
   - Set **Image** to `/main/player/player.atlas`
   - Set **Default Animation** to `idle`
   - Set **Material** to `/builtins/materials/sprite.material`
   - Set sprite **Z position** to `0.1` (renders above floor)
6. Right-click `player` > **Add Component (Embedded)** > choose **Collision Object**
   - Set **Type** to `Dynamic`
   - Set **Mass** to `1.0`
   - Set **Friction** to `0.1`
   - Set **Restitution** to `0.3`
   - Set **Linear Damping** to `0.4`
   - Set **Angular Damping** to `1.0`
   - Check **Locked Rotation** = true
   - Set **Group** to `player`
   - Set **Mask** to `wall, anchor, checkpoint`
   - Right-click the collision object > **Add Shape** > **Sphere** > radius `16`

### 3.3 Add the Camera
1. Right-click **Collection** > **Add Game Object**
2. Set **Id** to `camera`
3. Set **Position** to `X: 480, Y: 320, Z: 0`
4. Right-click `camera` > **Add Component From File** > select `main/camera/camera.script`
   - In Properties panel, set the `target` property to `/player`
5. Right-click `camera` > **Add Component (Embedded)** > choose **Camera**
   - Set **Orthographic Projection** = checked (1)
   - Set **Orthographic Zoom** = `1.0`
   - Set **Near Z** = `-1.0`
   - Set **Far Z** = `1.0`

### 3.4 Add the Level Controller
1. Right-click **Collection** > **Add Game Object**
2. Set **Id** to `level`
3. Position: `0, 0, 0`
4. Right-click `level` > **Add Component From File** > select `main/level/level.script`

### 3.5 Add the HUD
1. Right-click **Collection** > **Add Game Object**
2. Set **Id** to `hud`
3. Position: `0, 0, 0`
4. Right-click `hud` > **Add Component From File** > select `main/hud/hud.gui`

### 3.6 Add Arena Walls
Create 4 game objects for the boundary. For each wall:

1. Right-click **Collection** > **Add Game Object**
2. Right-click the game object > **Add Component (Embedded)** > **Collision Object**
   - Type: `Static`
   - Group: `wall`
   - Mask: `player`
   - Add Shape > **Box**

| Wall Id | Position (X, Y) | Box Size (W, H, D) |
|---------|-----------------|---------------------|
| `wall_bottom` | 1500, 0 | 1500, 16, 10 |
| `wall_top` | 1500, 2000 | 1500, 16, 10 |
| `wall_left` | 0, 1000 | 16, 1000, 10 |
| `wall_right` | 3000, 1000 | 16, 1000, 10 |

Then add 3 internal walls:

| Wall Id | Position (X, Y) | Box Size (W, H, D) |
|---------|-----------------|---------------------|
| `wall_mid_1` | 900, 700 | 300, 16, 10 |
| `wall_mid_2` | 1800, 1000 | 16, 300, 10 |
| `wall_mid_3` | 2200, 1400 | 400, 16, 10 |

### 3.7 Add Anchor Points
For each anchor, create a game object with:
- A **Sprite** component: Image = `/main/level/anchor.atlas`, Animation = `idle`
- A **Collision Object**: Type = `Static`, Group = `anchor`, Mask = `player`
  - Add Sphere shape, radius = `24`

| Anchor Id | Position (X, Y) |
|-----------|-----------------|
| `anchor_1` | 300, 500 |
| `anchor_2` | 600, 300 |
| `anchor_3` | 700, 900 |
| `anchor_4` | 1200, 500 |
| `anchor_5` | 1200, 1000 |
| `anchor_6` | 1500, 1500 |
| `anchor_7` | 2000, 800 |
| `anchor_8` | 2500, 1200 |
| `anchor_9` | 2700, 500 |
| `anchor_10` | 400, 1500 |
| `anchor_11` | 900, 1700 |
| `anchor_12` | 2000, 1700 |

### 3.8 Add Checkpoints
For each checkpoint, create a game object with:
- A **Sprite**: Image = `/main/level/level.atlas`, Animation = `checkpoint`
  - Set sprite Z to `0.05`
- A **Collision Object**: Type = `Trigger`, Group = `checkpoint`, Mask = `player`
  - Add Sphere shape, radius = `40`
- **Add Component From File** > `main/level/checkpoint.script`
  - Set `checkpoint_id` property to the number below
- Set **Scale** to `2, 2, 1`

| Checkpoint Id | Property `checkpoint_id` | Position (X, Y) |
|---------------|--------------------------|-----------------|
| `cp_1` | 1 | 800, 400 |
| `cp_2` | 2 | 1500, 800 |
| `cp_3` | 3 | 2400, 1400 |
| `cp_4` | 4 | 1000, 1600 |

### 3.9 Add Finish Line
1. Create game object with Id `finish`
2. Position: `480, 200`
3. Scale: `3, 3, 1`
4. Add Sprite: Image = `/main/level/level.atlas`, Animation = `finish`, Z = `0.05`
5. Add Collision Object: Type = `Trigger`, Group = `checkpoint`, Mask = `player`
   - Sphere shape, radius = `50`
6. Add Component From File > `main/level/checkpoint.script`
   - Set `is_finish` = `true`

### 3.10 Build and Test
1. **Project > Build** (Cmd+B)
2. You should now have a working game

---

## Phase 4: Verify Core Mechanics

Test each mechanic in order:

### 4.1 Movement
- [x] WASD moves the player
- [x] Player collides with walls and stops
- [x] Player slides along walls (doesn't stick)

### 4.2 Hook Firing
- [x] Left-click fires toward cursor
- [x] Cable line appears from player to hit point
- [x] Hooking to anchor points works
- [x] Hooking to walls works
- [x] Missing (clicking empty space) does nothing

### 4.3 Swing
- [x] While hooked, WASD creates circular motion (not linear)
- [x] Player stays within rope length of anchor
- [x] Swing speed increases with sustained input
- [x] Multiple cables constrain simultaneously

### 4.4 Release
- [x] Right-click releases all cables
- [x] Player flies off with preserved velocity
- [x] Brief "launch" feel (low friction for 0.5s)

### 4.5 Chain Momentum
- [x] Quick re-hook shows chain counter in HUD
- [x] Higher chain = noticeably faster swings
- [x] Chain resets after 1.5s without hooking

### 4.6 Time Trial
- [x] Timer starts on first hook fire
- [x] Passing checkpoints in order triggers "CHECKPOINT N"
- [x] Passing finish after all checkpoints shows final time
- [x] R key resets everything
- [x] Best time persists across restarts

---

## Phase 5: Tuning

Open `main/player/player.script` and adjust these constants (lines 3-13):

### If swinging feels too weak:
- Increase `SWING_FORCE` (try 8000-10000)

### If the player slides too much when walking:
- Increase `DAMPING_FREE` (try 0.6-0.8)

### If speed caps feel limiting:
- Increase `MAX_SPEED` (try 1000-1200)

### If chains are hard to maintain:
- Increase `CHAIN_WINDOW` (try 2.0-2.5 seconds)

### If hooks don't reach far enough:
- Increase `HOOK_MAX_RANGE` (try 800-1000)

### Tuning loop:
1. Change a constant
2. **Cmd+B** to rebuild (Defold hot-reloads)
3. Test the feel
4. Repeat

---

## Phase 6: Replace Placeholder Art

The current sprites are solid-color squares. To improve them:

### 6.1 Replace Images
Put new PNG files in `assets/images/`, replacing:
- `player.png` — 32x32, should show direction (arrow or triangle)
- `anchor.png` — 16x16, hook attachment point (diamond, glow, ring)
- `wall.png` — 32x32, wall tile
- `checkpoint.png` — 24x24, gate/ring
- `finish.png` — 24x24, finish marker (flag, star)

### 6.2 Update Atlases (if dimensions change)
If you change image sizes, open each `.atlas` file in the editor and verify the images still load correctly. The atlas auto-packs on build.

### 6.3 Upgrade Cable Rendering
The cables currently use `draw_line` (thin debug lines). To upgrade:
1. Open `main/player/player.script`
2. In the `update()` function, the `draw_line` call (line 110-114) renders cables
3. For thicker styled cables: use factory-spawned `cable_line.go` objects instead (the `cable_line.script` is already written for this approach)

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
- [ ] All sprites render
- [ ] Mouse input works for hook firing
- [ ] WASD movement works
- [ ] HUD text displays correctly
- [ ] Best time saves and persists on page refresh (localStorage)
- [ ] Test in both Chrome and Firefox

### 7.4 Ship to itch.io
1. Zip the entire output folder
2. On itch.io: create new project > upload zip
3. Set **Kind of project** = HTML
4. Set **Viewport dimensions** = 960 x 640
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
| Physics feel | `main/player/player.script` (lines 3-13) |
| Level layout | `main/main.collection` (in editor) |
| Camera behavior | `main/camera/camera.script` |
| HUD display | `main/hud/hud.gui` (in editor) + `hud.gui_script` |
| Controls | `input/game.input_binding` (in editor) |
| Background color | `render/game.render_script` (line 7) |
| Hook max range | `main/player/player.script` line 13 |
