# Physics Configuration Guide & Constants

This document details the single source of truth for all physics variables and parameters across the game, centralized in `scripts/physics_config.gd`.

## File Location
- **Configuration File:** [`scripts/physics_config.gd`](file:///c:/Users/LOKESH/gotbot%20game/scripts/physics_config.gd)
- **Engine Project Settings:** [`project.godot`](file:///c:/Users/LOKESH/gotbot%20game/project.godot) (`[physics] 3d/default_gravity = 24.0`)

---

## Centralized Physics Parameters

| Parameter | Value | Unit | Controlled Script(s) | Description |
|:---|:---:|:---:|:---|:---|
| `GRAVITY` | `24.0` | m/s² | `player.gd`, `npc.gd`, `hostile_npc.gd`, `vehicle.gd` | Uniform downward acceleration applied when not on floor. |
| `MAX_FALL_SPEED` | `55.0` | m/s | `player.gd`, `npc.gd`, `hostile_npc.gd`, `vehicle.gd` | Terminal velocity clamp preventing collision tunneling at high speeds. |
| `PLAYER_WALK_SPEED` | `8.5` | m/s | `player.gd` | Base walking movement velocity. |
| `PLAYER_SPRINT_SPEED` | `14.0` | m/s | `player.gd` | Sprinting velocity while holding Shift / Ctrl. |
| `PLAYER_ACCEL` | `8.0` | rate | `player.gd` | Ground acceleration interpolation rate. |
| `PLAYER_FRICTION` | `6.0` | rate | `player.gd` | Ground deceleration / stopping friction rate. |
| `PLAYER_AIR_ACCEL` | `4.0` | rate | `player.gd` | Reduced aerial steering acceleration. |
| `PLAYER_AIR_FRICTION` | `2.5` | rate | `player.gd` | Reduced aerial stopping friction (maintains jump momentum). |
| `JUMP_VELOCITY` | `9.5` | m/s | `player.gd` | Upward impulse on initial floor jump. |
| `DOUBLE_JUMP_VELOCITY`| `10.5`| m/s | `player.gd` | Upward impulse on mid-air double jump (replaces Y velocity). |
| `MAX_JUMPS` | `2` | count | `player.gd` | Maximum jump count (1 in fighting arena, 2 in city mode). |
| `TRAVERSAL_SPEED_CAP`| `30.0`| m/s | `player.gd` | Maximum total velocity cap after web slingshot or grapple dash. |
| `WEB_PULL_SPEED` | `26.0` | m/s | `player.gd` | Horizontal slingshot pull velocity towards anchor. |
| `WEB_PULL_LIFT` | `12.0` | m/s | `player.gd` | Vertical boost component of web slingshot. |
| `GRAPPLE_SPEED` | `24.0` | m/s | `player.gd` | Tactical forward grapple impulse. |
| `GRAPPLE_LIFT` | `10.0` | m/s | `player.gd` | Vertical lift component of tactical grapple. |
| `KNOCKBACK_UPWARD_LIFT`| `4.5`| m/s | `combat.gd`, `player.gd`, `hostile_npc.gd` | Upward component imparted on hits to pop enemies off ground. |
| `NPC_WALK_SPEED` | `2.4` | m/s | `npc.gd` | Citizen wandering speed. |
| `NPC_RUN_SPEED` | `5.2` | m/s | `npc.gd` | Citizen panic running speed when danger is detected. |
| `HOSTILE_NPC_SPEED` | `4.2` | m/s | `hostile_npc.gd` | Syndicate enemy alert chase speed. |
| `VEHICLE_SPEED` | `11.0` | m/s | `vehicle.gd` | Automobile road cruising speed. |
| `VEHICLE_STEER_SPEED` | `6.0` | rate | `vehicle.gd` | Smooth turning interpolation along road waypoints. |
| `CAM_FOLLOW_SPEED` | `14.0` | rate | `third_person_camera.gd` | Camera pivot tracking interpolation rate. |
| `CAM_DEFAULT_DIST` | `4.8` | m | `third_person_camera.gd` | Default 3rd person SpringArm distance. |
| `CAM_MIN_DIST` | `1.5` | m | `third_person_camera.gd` | Minimum zoom distance on scroll wheel up. |
| `CAM_MAX_DIST` | `8.0` | m | `third_person_camera.gd` | Maximum zoom distance on scroll wheel down. |
| `CAM_PITCH_MIN` | `-60.0`| deg | `third_person_camera.gd` | Maximum upward camera pitch (looking down). |
| `CAM_PITCH_MAX` | `45.0` | deg | `third_person_camera.gd` | Maximum downward camera pitch (looking up). |
| `ARENA_BOUND` | `14.5` | m | `player.gd`, `game_manager.gd` | Clamping boundary for rooftop arena mode. |
| `PROJECTILE_SPEED` | `28.0` | m/s | `projectile.gd` | Web / Batarang linear flight speed. |
| `PROJECTILE_LIFETIME` | `3.0` | s | `projectile.gd` | Auto-despawn timer for projectiles. |

---

## How to Tune Physics
To adjust gameplay feel (e.g., increase gravity, modify sprint speed, or adjust camera zoom):
1. Open [`scripts/physics_config.gd`](file:///c:/Users/LOKESH/gotbot%20game/scripts/physics_config.gd).
2. Modify the target constant.
3. Every script automatically inherits the updated value on next run. No manual edits across individual entity scripts are required.
