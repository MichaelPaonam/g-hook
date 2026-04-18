# Repository Guidelines

## Project Structure & Module Organization
`game.project` is the Defold entry point and points at `main/main.collection`. Core gameplay code lives under `main/`: `player/` handles movement and grappling, `camera/` handles follow and pan behavior, `level/` owns checkpoints and finish logic, `hud/` owns GUI state, and `util/` contains shared Lua helpers such as `screen_to_world.lua`. Rendering is customized in `render/`. Input bindings live in `input/game.input_binding`. Source art is in `assets/images/`; generated HTML5 output belongs in `build/` and intermediate bundle artifacts in `bundle/`.

## Build, Test, and Development Commands
Use Defold Editor for the main inner loop: open `game.project`, run `Project > Fetch Libraries`, then `Project > Build` to play locally. For scripted HTML5 builds, run `.\build.bat` on Windows or `./build.sh` on Unix-like shells; both call `bob.jar` and flatten the bundle into `build/`. To smoke-test the browser build, serve `build/` over HTTP, for example `python -m http.server 8080`, then open `http://localhost:8080`.

## Coding Style & Naming Conventions
Lua files use tabs/spaces as already present; match the surrounding file instead of reformatting broadly. Keep module locals and tuning constants at the top in `UPPER_SNAKE_CASE`, for example `PULL_FORCE` and `HOOK_MAX_RANGE`. Prefer `local` helper functions, short `self` fields for instance state, and Defold message names in lowercase snake case such as `checkpoint_hit`. Keep folder and asset names lowercase with underscores.

## Testing Guidelines
This repo currently has no automated test suite. Verify changes by running the game in Defold and, for release-sensitive changes, by bundling HTML5 and testing the browser build. For gameplay edits, check hook fire/release, checkpoint ordering, restart flow, camera pan/zoom, and HUD updates. If you add tests or validation scripts later, place them in a dedicated top-level `tests/` or `tools/` directory and document the command here.

## Commit & Pull Request Guidelines
Recent commits use short, imperative summaries such as `added cable auto-release mechanism and mouse cursor used for aiming`. Keep commit titles concise, lowercase is acceptable, and scope each commit to one change. Pull requests should describe the gameplay or build impact, link any issue, and include a screenshot or short clip when visuals, HUD, or camera behavior changes.

## Security & Configuration Tips
Do not commit private signing material or alternate manifests beyond the files already tracked. Treat `bob.jar` and any `BOB_JAR` override as build tooling, not source. Keep generated `build/` or `bundle/` contents out of feature commits unless the change is specifically about packaged output.
