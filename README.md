# G-Hook

A 2D top-down grappling hook time-trial game built with [Defold](https://defold.com) for HTML5 browsers.

Fire cables at anchor points, swing around them using momentum, chain hooks for speed boosts, and race through checkpoints as fast as possible. Inspired by Fanny's cable mechanics from Mobile Legends: Bang Bang.

## Controls

| Input | Action |
|-------|--------|
| **Left Click** | Fire grappling hook toward cursor |
| **Right Click** | Release all cables |
| **WASD** | Move (free) / Swing (hooked) |
| **R** | Restart run |

## How It Works

This is a **top-down** game with **zero gravity**. Unlike a side-view grappling hook where gravity creates pendulum swings, momentum here comes entirely from player input:

1. **Hook** — Left-click raycasts toward the cursor. If it hits a wall or anchor point, a cable is created.
2. **Swing** — While hooked, WASD input is projected onto the **tangential** direction (perpendicular to the rope). This creates circular motion around the anchor.
3. **Release** — Right-click destroys all cables. The player flies off at their current velocity.
4. **Chain** — Hooking again within 1.5s of releasing keeps the chain alive. Each chain level adds a 15% speed multiplier.

Up to 3 cables can be active simultaneously. The most recent cable acts as the primary swing pivot.

## Project Structure

```
game.project                 # Defold project config (zero gravity, 960x640, HTML5)
input/game.input_binding     # Mouse + WASD + R key bindings
render/
  game.render                # Custom render pipeline
  game.render_script         # Camera-aware rendering + draw_line for cables
main/
  main.collection            # Game world: player, camera, walls, anchors, checkpoints
  player/
    player.script            # Core game logic (movement, hook, swing, chain)
    player.atlas             # Player sprite
  camera/
    camera.script            # Smooth follow with velocity-based lead
  hook/
    cable_line.script        # Rope visual rendering (stretched sprite)
    cable.atlas              # Cable sprite
  level/
    level.script             # Checkpoint ordering and finish detection
    checkpoint.script        # Per-checkpoint trigger and visual feedback
    anchor.atlas             # Anchor point sprite
    level.atlas              # Checkpoint/wall/finish sprites
  hud/
    hud.gui                  # HUD layout (timer, speed, chain, cables)
    hud.gui_script           # HUD logic + best time persistence
  util/
    screen_to_world.lua      # Mouse screen coords to world coords
assets/images/               # Placeholder PNGs (32x32 colored squares)
```

## Setup

### Prerequisites

- [Defold Editor](https://defold.com/download/) (latest stable)

### Run Locally

1. Clone the repo:
   ```
   git clone https://github.com/MichaelPaonam/g-hook.git
   ```
2. Open the project in Defold Editor: **File > Open Project** and select `game.project`.
3. Fetch built-in libraries: **Project > Fetch Libraries**.
4. Build and run: **Project > Build** (Cmd+B / Ctrl+B).

### Build for HTML5

1. In Defold Editor: **Project > Bundle > HTML5 Application**.
2. Choose an output directory.
3. Test locally (WASM requires HTTP, not file://):
   ```
   cd <output-directory>
   python3 -m http.server 8080
   ```
4. Open `http://localhost:8080` in Chrome or Firefox.
5. For itch.io: zip the bundle folder and upload.

## Tuning

All physics constants are at the top of `main/player/player.script`:

| Constant | Default | What It Does |
|----------|---------|--------------|
| `SWING_FORCE` | 5000 | Tangential force applied while hooked |
| `FREE_MOVE_FORCE` | 2000 | Direct movement force when not hooked |
| `MAX_SPEED` | 800 | Velocity cap (px/s) |
| `DAMPING_FREE` | 0.4 | Ground friction when walking |
| `DAMPING_HOOKED` | 0.05 | Reduced friction while swinging |
| `MAX_CABLES` | 3 | Simultaneous cable limit |
| `CHAIN_WINDOW` | 1.5 | Seconds to maintain chain between hooks |
| `CHAIN_BONUS` | 0.15 | Speed multiplier per chain level (15%) |
| `HOOK_MAX_RANGE` | 600 | Max raycast distance for hooks |

## Level Layout

The arena is 3000x2000 pixels with:
- 4 boundary walls
- 3 internal wall segments creating corridors
- 12 anchor points distributed for continuous swing paths
- 4 checkpoints forming a circuit
- 1 finish line near the spawn point

To add or move anchors/checkpoints, edit `main/main.collection` in the Defold Editor (or modify the protobuf text directly).

## License

MIT License. See [LICENSE](LICENSE).
