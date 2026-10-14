# Root Cause Analysis & Resolutions

## 1. Dispersed & Conflicting Physics Values

- **Root Cause:** Jump velocity, gravity, fall speeds, and traversal speeds were formerly declared across several scripts (`player.gd`, `vehicle.gd`, `npc.gd`, `third_person_camera.gd`, `game_config.gd`), creating inconsistency.
- **Resolution:** Created authoritative `GameplayPhysicsConfig` (`res://data/gameplay_physics_config.tres`) and updated `PhysicsConfig` (`scripts/physics_config.gd`) to serve as the single source of truth. All entities now reference centralized constants.

## 2. Abrupt Edge Falling & Jump Misses

- **Root Cause:** Standard CharacterBody3D `is_on_floor()` checks immediately returned false the instant a player ran off a ledge or pressed jump a fraction of a second before touching ground, causing frustrating missed jumps.
- **Resolution:** Adapted coyote time (`0.15s`) and jump buffering (`0.12s`) inspired by `real-controller`. Players now enjoy responsive platforming and acrobatics.

## 3. Camera Wall Snagging & Split-Screen Interference

- **Root Cause:** Basic camera follow lacked exponential damping, aim FOV zooming, and split-screen isolation, causing Player 1's mouse inputs to conflict with Player 2.
- **Resolution:** Integrated `godot-adaptive-camera-rig` architecture with -70° to +45° pitch clamp, exponential decay `1.0 - exp(-smoothing * delta)`, aim FOV transition, and isolated Player 2 look controls.

## 4. Oversimplified 2-Column Settings Modal

- **Root Cause:** Earlier settings modal only had raw sliders without categorized tabs or live engine system application.
- **Resolution:** Adapted `godot-settings-menus` architecture into a 5-tab system (Audio, Display, Graphics, Controls, Accessibility) with live bindings to Godot `DisplayServer`, `Engine`, `RenderingServer`, and `AudioServer`.
