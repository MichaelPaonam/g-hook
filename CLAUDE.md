# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

2D top-down grappling hook time-trial game. Built with Defold engine (Lua), targeting HTML5/browser. Zero-gravity physics — player fires cables at anchors and is pulled toward them.

## Build Commands

- **Run in editor**: Open `game.project` in Defold Editor, then Project > Build (Cmd+B)
- **Fetch libraries**: Project > Fetch Libraries (required after clone)
- **HTML5 bundle**: `./build.sh` (requires `bob.jar` in project root + JDK 17+)
- **Local test server**: `cd build && python3 -m http.server 8080`

## Architecture

### Core Mechanic (player.script)

The grappling hook uses a **pull-toward system** (not swing/pendulum):

1. Press Q → raycast toward cursor, attach cable to wall/anchor hit
2. Up to 3 cables active simultaneously (oldest drops if 4th fired)
3. Each frame: player is pulled toward anchor(s) — 1 cable = direct pull, 2+ cables = bisector of last two
4. Cable auto-releases when player arrives within `AUTO_RELEASE_DIST`
5. Chain system: re-hooking within 3s maintains chain, each link adds +20% pull force
6. Speed aura activates above 700 px/s — required to pass speed-gate checkpoints

### States

`STATE_FREE` → `STATE_HOOKED` (cable attached) → `STATE_LAUNCHING` (post-release coast with reduced friction)

### File Responsibilities

- `main/player/player.script` — All player logic: movement, pull physics, multi-cable management, chain momentum, speed aura, state machine
- `main/camera/camera.script` — Smooth lerp follow + velocity-based lead offset
- `main/level/level.script` — Checkpoint ordering, finish detection, reset, tutorial hints
- `main/level/checkpoint.script` — Per-checkpoint trigger, supports speed-gate mechanic
- `main/hud/hud.gui_script` — Speed/chain/cable display, timer, settings panel
- `main/hud/start_screen.gui` — Title screen with Play button and settings
- `main/hud/level_complete.gui` — Level complete overlay with best time + next level
- `main/loader/loader.script` — Loads/unloads level collections via collection proxies
- `main/hook/cable_line.script` — Positions/scales cable sprite between player and anchor
- `main/util/screen_to_world.lua` — Mouse screen→world conversion (accounts for camera/zoom)
- `main/util/settings.lua` — Persistent settings: music volume, mute, per-level best times
- `render/game.render_script` — Camera-aware sprite rendering, draw_line for cables, separate GUI pass

### Collision Groups

| Group | Type | Mask | Used By |
|-------|------|------|---------|
| `player` | dynamic | wall, anchor, checkpoint | Player body |
| `wall` | static | player | Arena walls + internal walls |
| `anchor` | static | player | Cable attachment points |
| `checkpoint` | trigger | player | Checkpoints + finish line (some are speed gates) |

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

### Level Loading

`main/main.collection` is the bootstrap — contains HUD, start screen, and collection proxies for each level. `loader.script` handles loading/unloading level collections. Each level lives in `levels/level_N/`.

## Controls

| Input | Action |
|-------|--------|
| Q | Fire cable toward cursor |
| E | Release all cables |
| WASD | Steer (weak force; preserves momentum) |
| R | Restart current level |
| ESC | Open settings |
| Mouse | Aim direction |

## Conventions

- Defold protobuf text format for `.collection`, `.go`, `.atlas`, `.gui` files — don't manually edit these unless you understand the format
- Lua scripts use `self` table for instance state
- Physics constants defined as `local` at top of `player.script` (lines 3–16)
- All Defold file paths use absolute paths starting with `/`
- `game.project` sets `shared_state = 1` — all scripts share one Lua state
- Collections use embedded instances to keep level geometry in one file

## Key Tuning Constants (player.script)

| Constant | Value | Effect |
|----------|-------|--------|
| `PULL_FORCE` | 500 | Force pulling toward anchor(s) |
| `FREE_MOVE_FORCE` | 90 | Steering force when unhooked |
| `MAX_SPEED` | 900 | Velocity cap (px/s) |
| `DAMPING_FREE` | 0.6 | Friction when walking |
| `DAMPING_HOOKED` | 0.02 | Near-zero friction while pulled |
| `DAMPING_LAUNCH` | 0.25 | Deceleration after cable release |
| `LAUNCH_DURATION` | 1.5 | Coast window after release (seconds) |
| `MAX_CABLES` | 3 | Simultaneous cable limit |
| `CHAIN_WINDOW` | 3.0 | Seconds to maintain chain |
| `CHAIN_BONUS` | 0.20 | Pull multiplier per chain level |
| `HOOK_MAX_RANGE` | 1200 | Max raycast distance (px) |
| `AUTO_RELEASE_DIST` | 120 | Auto-release proximity (px) |
| `AURA_SPEED_THRESHOLD` | 700 | Speed for aura + speed gates |

## Known Limitations

- Cable rendering uses debug draw_line (thin lines, no styling)
- No sound effects beyond background music
- Rope constraint is manual Lua (not physics joints) — intentional for zero-gravity feel
