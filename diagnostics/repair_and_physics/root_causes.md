# Root Causes & Diagnostics Analysis

This document details the root causes of the physics discrepancies, visual regressions, and runtime anomalies observed prior to this audit, along with their permanent resolutions.

---

## Issue 1: Fragmented & Conflicting Gravity Values
- **Observed Behavior:** Player, NPCs, Hostile NPCs, and Vehicles operated under 4 conflicting gravity schemes. The player used `24.0`, citizen NPCs used `20.0`, hostile NPCs used `22.0`, vehicles had no gravity and floated if spawned above ground, and the Godot project setting had no `[physics]` section (falling back to Godot's built-in default `9.8 m/s²`).
- **Root Cause:** Decentralized constants hardcoded independently inside each script file without a single source of truth.
- **Resolution:**
  - Created [`scripts/physics_config.gd`](file:///c:/Users/LOKESH/gotbot%20game/scripts/physics_config.gd) defining `GRAVITY = 24.0` and `MAX_FALL_SPEED = 55.0`.
  - Added `[physics]` section to [`project.godot`](file:///c:/Users/LOKESH/gotbot%20game/project.godot) with `3d/default_gravity = 24.0`.
  - Refactored `player.gd`, `npc.gd`, `hostile_npc.gd`, and `vehicle.gd` to preload and utilize `PhysicsConfig.GRAVITY`.

---

## Issue 2: High-Speed Physics Tunneling (Missing Terminal Velocity)
- **Observed Behavior:** If characters fell from high skyscrapers (e.g., Sky-Piercer tower at `48m` height) or were knocked down at extreme velocities, downward velocity could exceed collision detection thresholds, risking tunneling through ground geometry.
- **Root Cause:** Downward acceleration was applied unconditionally (`velocity.y -= GRAVITY * delta`) with no terminal velocity clamp.
- **Resolution:**
  - Added `velocity.y = max(velocity.y, -PC.MAX_FALL_SPEED)` to all entity physics loops. At `55.0 m/s`, the maximum step per frame at 60 FPS is under `0.92m`, well within the `2.0m` ground collision box thickness.

---

## Issue 3: Unbounded Slingshot & Grapple Traversal Momentum
- **Observed Behavior:** Triggering web pull or grapple dash in rapid succession could stack horizontal impulse to unrealistic speeds (`>60 m/s`), causing visual jitter and control loss.
- **Root Cause:** `_perform_web_pull` and `_perform_grapple_dash` assigned raw impulse vectors without speed capping.
- **Resolution:**
  - Implemented `impulse.limit_length(PC.TRAVERSAL_SPEED_CAP)` where `TRAVERSAL_SPEED_CAP = 30.0 m/s`.
  - Separated aerial movement controls: `PLAYER_AIR_ACCEL = 4.0` (versus ground `8.0`) and `PLAYER_AIR_FRICTION = 2.5` (versus ground `6.0`), allowing responsive air steering without infinite acceleration.

---

## Issue 4: Floating Vehicles on Uneven Surface Transitions
- **Observed Behavior:** City vehicles lacked vertical velocity management. If a car hopped or spawned slightly above ground, `velocity = -transform.basis.z * speed` overwrote `velocity.y` to `0.0`, leaving the vehicle floating horizontally in mid-air.
- **Root Cause:** Complete absence of floor detection and gravity in `scripts/vehicle.gd`.
- **Resolution:**
  - Added `if not is_on_floor(): velocity.y -= PC.GRAVITY * delta` to `vehicle.gd`.
  - Kept vertical and horizontal components separate: `velocity.x` and `velocity.z` drive forward motion while `velocity.y` adheres to gravity and ground collision.

---

## Issue 5: Props Lacking Collision Bodies (Ghost Street Lamps & Antennas)
- **Observed Behavior:** Street lamps and roof antennas were instantiated as `StaticBody3D` nodes containing visual meshes, but lacked `CollisionShape3D` children, allowing heroes and NPCs to walk straight through them.
- **Root Cause:** Incomplete procedural generation in `city_builder.gd`.
- **Resolution:**
  - Added `CylinderShape3D` collision shapes to `_create_street_lamp()` (`radius = 0.25m, height = 5.0m`).
  - Added `CylinderShape3D` collision shapes to `_create_antenna()` (`radius = 0.35m, height = h`).
  - Created 4 perimeter boundary barriers (`16m` high walls) enclosing the 180x180m city district to guarantee players cannot drop into empty void space.

---

## Issue 6: Camera Occlusion and Teleport Lag
- **Observed Behavior:** On instant player respawns or long distance traversals, the camera's linear interpolation (`lerp`) could trail far behind or lose the hero.
- **Root Cause:** Unconditional lerping with fixed factor and no distance snap threshold.
- **Resolution:**
  - Added snap threshold: if `distance_squared_to(target_pos) > 225.0` (`15m`), the camera position snaps directly to the player.
  - Set `spring_arm.collision_mask = 1` explicitly to guarantee occlusion collision against all environment buildings and walls.
