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

## Speed Aura

When the player exceeds **700 px/s**, an orange glow aura activates around the player. Some checkpoints require this speed to pass — hitting them too slowly knocks the player back.

## Levels

| Level | Description |
|-------|-------------|
| **Level 1** | Tutorial — learn the controls. Hit the checkpoint to finish. |
| **Level 2** | Speed gate — the final checkpoint requires speed ≥ 700 to pass. |
| **Level 3** | Coming soon. |

Checkpoints must be hit in order. Hitting one out of order triggers a 1.5-second penalty and resets the run.

## Project Structure

```
game.project                   # Defold project config (zero gravity, 960x640, HTML5)
input/game.input_binding       # Q, E, WASD, right-click pan, scroll zoom
render/
  game.render_script           # Camera-aware rendering + draw_line for cables/timer
main/
  main.collection              # Bootstrap: start screen + level loader (collection proxies)
  loader/
    loader.script              # Loads/unloads level collections via proxies
  player/
    player.script              # Core game logic (movement, pull mechanic, chain, aura)
    player.atlas               # Player sprite + hook cursor (target animation)
  camera/
    camera.script              # Smooth follow, velocity lead, right-click pan
  hook/
    cable.factory              # Spawns cable visuals
  level/
    level.script               # Checkpoint ordering, finish detection, tutorial hints
    checkpoint.script          # Per-checkpoint trigger (supports speed gate mechanic)
  hud/
    hud.gui / hud.gui_script   # HUD: speed, chain, cable count, level label, cursor, messages
    start_screen.gui           # Start screen with title and Start button
    level_complete.gui         # Level complete overlay with dynamic "Go to Level N" button
  fx/
    speed_aura.particlefx      # Orange particle aura active above speed 700
  util/
    screen_to_world.lua        # Mouse screen coords → world coords (accounts for zoom)
levels/
  level_1/                     # Level 1 collection + tilemap
  level_2/                     # Level 2 collection + tilemaps + anchors
  level_3/                     # Level 3 shell (empty, ready for content)
assets/images/                 # Sprites and images
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

1. Download `bob.jar` from [Defold releases](https://github.com/defold/defold/releases) and place it in the project root.
2. Run the build script:
   ```
   ./build.sh
   ```
3. Serve the output locally (WASM requires HTTP, not `file://`):
   ```
   cd build
   python3 -m http.server 8080
   ```
4. Open `http://localhost:8080` in Chrome or Firefox.

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
| `AURA_SPEED_THRESHOLD` | 700 | Speed required to trigger aura and pass speed gates |

## License

MIT License. See [LICENSE](LICENSE).
