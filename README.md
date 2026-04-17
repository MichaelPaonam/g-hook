# G-Hook

A 2D top-down grappling hook time-trial game built with [Defold](https://defold.com) for HTML5 browsers.

Fire cables at anchor points and walls, get pulled toward them, chain hooks for speed boosts, and race through checkpoints as fast as possible.

## Controls

| Input | Action |
|-------|--------|
| **Q** | Fire grappling hook toward cursor |
| **E** | Release all cables |
| **WASD** | Move (weak steering force; retains momentum after cable release) |
| **Right-click drag** | Pan camera |
| **Scroll wheel** | Zoom in / out |
| **R** | Restart run |

## How It Works

This is a **top-down** game with **zero gravity**. The mechanic is inspired by Fanny from Mobile Legends — you are **pulled toward anchor points**, not swinging like a pendulum:

1. **Hook** — Press Q to raycast toward the cursor. If it hits a wall or anchor, a cable attaches.
2. **Pull** — While hooked, the player is pulled toward the anchor:
   - 1 cable → pulled directly toward it
   - 2 cables → pulled toward the bisector of both anchors
   - 3 cables → pulled toward the bisector of the **last two** anchors
3. **Auto-release** — A cable releases automatically when the player arrives at the anchor.
4. **Release** — Press E to drop all cables. The player coasts with preserved velocity.
5. **Chain** — Re-hooking within 3 seconds keeps the chain alive. Each level adds +20% pull force.

Up to 3 cables can be active simultaneously. The oldest cable is dropped if a 4th is fired.

## Level

The arena is 3000×2000 pixels arranged as a **S-shaped hallway**:

```
Start (150, 300)  →  Corridor 1 (y≈300)  →  Turn 1  →
Corridor 2 (y≈900)  →  Turn 2  →  Corridor 3 (y≈1500)  →  Finish
```

**Checkpoints must be hit in order** (1 → 2 → 3 → 4). Hitting a checkpoint out of order triggers a 1.5-second penalty and resets the run. The same applies to touching the finish before all checkpoints are cleared.

The timer starts on the first hook fire, stops at the finish, and is displayed near the finish line in world space.

## Project Structure

```
game.project                 # Defold project config (zero gravity, 960x640, HTML5)
input/game.input_binding     # Q, E, WASD, R, right-click pan, scroll zoom
render/
  game.render                # Custom render pipeline
  game.render_script         # Camera-aware rendering + draw_line for cables/walls/timer
main/
  main.collection            # Game world: player, camera, walls, anchors, checkpoints
  player/
    player.script            # Core game logic (movement, pull mechanic, chain, reset)
    player.atlas             # Player sprite
  camera/
    camera.script            # Smooth follow, velocity lead, right-click pan
  hook/
    cable_line.script        # (Unused — cables rendered via draw_line in player.script)
    cable.atlas              # Cable sprite
  level/
    level.script             # Checkpoint ordering, finish detection, world-space timer
    checkpoint.script        # Per-checkpoint trigger and visual feedback
    anchor.atlas             # Anchor point sprite (48×16 yellow rectangle)
    level.atlas              # Checkpoint/finish sprites
  hud/
    hud.gui                  # HUD layout (speed, chain, cable count, messages)
    hud.gui_script           # HUD logic + best time persistence (sys.save)
  util/
    screen_to_world.lua      # Mouse screen coords → world coords (accounts for zoom)
assets/images/               # Placeholder PNGs
```

## Setup

### Prerequisites

- [Defold Editor](https://defold.com/download/) (latest stable)

### Run Locally

1. Clone the repo:
   ```
   git clone https://github.com/MichaelPaonam/g-hook.git
   ```
2. Open the project in Defold Editor: **File > Open Project** → select `game.project`.
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

| Constant | Value | What It Does |
|----------|-------|--------------|
| `PULL_FORCE` | 500 | Force pulling player toward anchor(s) |
| `FREE_MOVE_FORCE` | 90 | Steering force when not hooked |
| `MAX_SPEED` | 900 | Velocity cap (px/s) |
| `DAMPING_FREE` | 0.6 | Friction when walking freely |
| `DAMPING_HOOKED` | 0.02 | Near-zero friction while being pulled |
| `DAMPING_LAUNCH` | 0.25 | Gradual decel after cable release |
| `LAUNCH_DURATION` | 1.5 | Seconds of reduced friction after release |
| `MAX_CABLES` | 3 | Simultaneous cable limit |
| `CHAIN_WINDOW` | 3.0 | Seconds to maintain chain between hooks |
| `CHAIN_BONUS` | 0.20 | Pull multiplier per chain level (+20%) |
| `HOOK_MAX_RANGE` | 1200 | Max raycast distance (px) |
| `AUTO_RELEASE_DIST` | 120 | Distance at which cable auto-releases |

## License

MIT License. See [LICENSE](LICENSE).
