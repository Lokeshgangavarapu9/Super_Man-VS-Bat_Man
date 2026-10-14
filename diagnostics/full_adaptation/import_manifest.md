# Selective Import Manifest

## Principles
1. **No Project Replacement:** The existing superhero game architecture (`CityManager`, `PlayerCharacter`, `CombatScript`, `GameConfig`, `CityBuilder`) is preserved.
2. **Selective Adaptation:** Proven open-source foundations from 4 reference repositories were inspected and adapted cleanly into existing codebase scripts without importing bloat or conflicting autoloads.
3. **Network Limitation Handling:** Network access was verified; all 4 reference repositories were successfully cloned to `third_party/reference_repos/` for local inspection and adaptation.

---

## Imported & Adapted Systems

| Source Repository | Source Concept / System | Target File in Project | Adaptation Description |
|---|---|---|---|
| `godot-adaptive-camera-rig` | Dual-mode SpringArm, aim FOV, shoulder offset, exponential damping | [`scripts/third_person_camera.gd`](file:///c:/Users/LOKESH/gotbot%20game/scripts/third_person_camera.gd) | Implemented pitch clamp (-70° to +45°), exponential damping `1.0 - exp(-cam_smoothing * delta)`, aim FOV transition (75° to 55°), right-click aim mode, and split-screen isolation. |
| `real-controller` | Coyote time, jump buffering, ground/air acceleration equations | [`scripts/player.gd`](file:///c:/Users/LOKESH/gotbot%20game/scripts/player.gd) | Added `coyote_timer` (0.15s) and `jump_buffer_timer` (0.12s); updated movement to use `move_toward` with explicit `acceleration * delta` and `deceleration * delta`. |
| `real-controller` | Authoritative parameter resource design | [`scripts/gameplay_physics_config.gd`](file:///c:/Users/LOKESH/gotbot%20game/scripts/gameplay_physics_config.gd)<br>[`data/gameplay_physics_config.tres`](file:///c:/Users/LOKESH/gotbot%20game/data/gameplay_physics_config.tres)<br>[`scripts/physics_config.gd`](file:///c:/Users/LOKESH/gotbot%20game/scripts/physics_config.gd) | Centralized all physics, vehicle, combat, traversal, and camera parameters into an authoritative resource with backwards-compatible aliases. |
| `GTA-mini` | CharacterBody3D vehicle dynamics, braking, lateral slip & impacts | [`scripts/vehicle.gd`](file:///c:/Users/LOKESH/gotbot%20game/scripts/vehicle.gd) | Added dynamic speed ramp-up, rapid braking on obstacle detection, lateral grip and steering slip, and head-on collision speed dampening. |
| `GTA-mini` | Coastal atmospheric lighting, distance fog, directional shadows | [`scenes/city.tscn`](file:///c:/Users/LOKESH/gotbot%20game/scenes/city.tscn) | Configured Environment with ACES tonemapping, warm sun light energy (1.35), distance fog (begin 35m, end 240m), PSSM 4-split directional shadows (250m max distance). |
| `godot-settings-menus` | 5-tab settings structure, live engine integration | [`scenes/main_menu.tscn`](file:///c:/Users/LOKESH/gotbot%20game/scenes/main_menu.tscn)<br>[`scripts/main_menu.gd`](file:///c:/Users/LOKESH/gotbot%20game/scripts/main_menu.gd)<br>[`scripts/game_config.gd`](file:///c:/Users/LOKESH/gotbot%20game/scripts/game_config.gd) | Replaced static 2-column grid with full `TabContainer` featuring Audio, Display, Graphics, Controls, and Accessibility; connected options to `DisplayServer`, `Engine`, `RenderingServer`, and `AudioServer`. |
| `godot-settings-menus` | Clean ESC Pause Menu Overlay | [`scripts/pause_menu.gd`](file:///c:/Users/LOKESH/gotbot%20game/scripts/pause_menu.gd)<br>[`scenes/pause_menu.tscn`](file:///c:/Users/LOKESH/gotbot%20game/scenes/pause_menu.tscn) | Provides Resume, Settings, Main Menu, Exit with zero input blocking on resume. |
