# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

This repository is a Godot 4.6 2D action game prototype named `MythBoss`.

The codebase is still in bootstrap state. Right now it contains a minimal Godot project manifest, a single root scene, and placeholder assets only. Prefer small, runnable changes that keep the project opening cleanly in the editor.

## Common commands

### Open the project in Godot
Open `project.godot` in the Godot editor.

Current local executable used during setup:

```bash
"D:/environment/Godot_v4.6.2-stable_win64.exe"
```

### Run the project from the command line

```bash
"D:/environment/Godot_v4.6.2-stable_win64.exe" --path "D:/workspace/ai/mythboss"
```

This launches the configured startup scene from `project.godot`.

### Validate the current playable entry point
There is no separate build pipeline yet; the main validation step is confirming the project opens and runs.

- In the editor: use **Run Project**.
- From the CLI: run the command above.

### Tests and linting
There is currently no test framework, no single-test command, and no lint setup checked into the repository.

Before documenting test or lint commands here, verify that a framework has actually been added.

## Architecture

### Runtime entry point
- `project.godot` is the authoritative project manifest.
- `run/main_scene` is set to `res://scenes/main.tscn`.
- The project currently targets Godot 4.6 and uses the `gl_compatibility` renderer for both desktop and mobile settings.

### Current scene graph
- `scenes/main.tscn` is the only gameplay scene currently wired into the project.
- The root node is a plain `Node2D` named `Main`.
- There are no attached scripts, autoloads, addons, or secondary scenes in the repository yet.

### Repository shape
- `scenes/` is the only game-content directory currently in use.
- `scripts/` and `assets/` are intended future locations for gameplay logic and content, but they are not present yet.
- `icon.svg` is the project icon referenced by `project.godot`.

## Working conventions for this repo

- Default to GDScript unless the user explicitly chooses C#.
- Keep the project editor-runnable at all times; avoid partial scene or script wiring that breaks startup.
- Build the prototype as small vertical slices that stay reachable from `main.tscn`.
- Given the current bootstrap state, favor establishing the core player loop first: player control, combat interaction, enemy/boss behavior, then camera/UI.
- Update this file when the project gains real scripts, autoloads, test tooling, export configuration, or more than one meaningful runtime scene.
