# G-Hook - Defold Grappling Hook Game

## Project Overview

2D top-down grappling hook time-trial game. Built with Defold engine, targeting HTML5/browser. Game jam project.

## Tech Stack

- **Engine**: Defold (Lua scripting, Box2D physics)
- **Target**: HTML5 (WebAssembly)
- **Physics**: Zero-gravity top-down with manual rope constraints
- **Display**: 960x640, nearest-neighbor filtering

## Architecture

### Core Mechanic (player.script)

The grappling hook uses a **manual rope constraint** (not physics joints) because zero-gravity top-down makes standard joints feel lifeless. The approach:

1. Raycast from player toward mouse cursor on click
2. Store anchor position and rope length
3. Each frame: if player distance > rope length, snap back and remove outward velocity
4. WASD input projected onto tangent (perpendicular to rope) creates circular swing
5. Chain system tracks successive hooks within 1.5s window for speed multiplier

### File Responsibilities

- `main/player/player.script` — All player logic: movement, hook fire/release, swing physics, chain momentum, state machine (FREE/HOOKED/LAUNCHING)
- `main/camera/camera.script` — Smooth lerp follow + velocity-based lead offset
- `main/level/level.script` — Checkpoint ordering, finish detection, reset
- `main/level/checkpoint.script` — Individual checkpoint trigger + visual state
- `main/hud/hud.gui_script` — Timer, best time (persisted via sys.save), chain/speed/cable display
- `main/util/screen_to_world.lua` — Mouse coordinate conversion (screen -> world using camera offset)
- `render/game.render_script` — Custom render pipeline: camera-aware sprite rendering, draw_line for cables, separate GUI pass

### Collision Groups

| Group | Type | Mask | Used By |
|-------|------|------|---------|
| `player` | dynamic | wall, anchor, checkpoint | Player body |
| `wall` | static | player | Arena walls + internal walls |
| `anchor` | static | player | Grappling hook attachment points |
| `checkpoint` | trigger | player | Checkpoints + finish line |

### Message Flow

```
player.script --"checkpoint_hit"--> hud.gui_script
player.script --"finish_hit"-----> hud.gui_script
checkpoint.script --"checkpoint_triggered"--> level.script
checkpoint.script --"finish_triggered"------> level.script
level.script --"checkpoint_hit"--> player.script
level.script --"finish_hit"-----> player.script
player.script --"reset_checkpoints"--> level.script
player.script --"set_lead"------------> camera.script
```

## Build Commands

- **Run in editor**: Project > Build (Cmd+B)
- **HTML5 bundle**: Project > Bundle > HTML5 Application
- **Local test server**: `python3 -m http.server 8080` in bundle directory

## Conventions

- Defold protobuf text format for .collection, .go, .atlas, .gui files
- Lua scripts use `self` table for instance state
- Physics constants defined as `local` at top of player.script
- All file paths in Defold use absolute paths starting with `/`
- Collection uses embedded instances (not separate .go files) to keep everything in one file

## Key Tuning Constants (player.script lines 3-13)

Adjust these to change game feel:
- `SWING_FORCE` — tangential swing power
- `FREE_MOVE_FORCE` — walking speed
- `MAX_SPEED` — velocity cap
- `CHAIN_BONUS` — per-chain speed multiplier
- `HOOK_MAX_RANGE` — hook reach distance
- `DAMPING_FREE` / `DAMPING_HOOKED` — friction in each state

## Known Limitations

- Cable rendering uses debug draw_line (thin lines, no styling)
- Placeholder sprites are solid-color squares
- Single level only
- No sound effects
- Rope constraint is manual Lua (not physics joints) — more control but bypasses Box2D solver for rope behavior
