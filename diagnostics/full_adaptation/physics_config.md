# Authoritative Gameplay Physics Configuration

## Configuration Source
- **Resource Definition:** [`scripts/gameplay_physics_config.gd`](file:///c:/Users/LOKESH/gotbot%20game/scripts/gameplay_physics_config.gd)
- **Default Resource Instance:** [`data/gameplay_physics_config.tres`](file:///c:/Users/LOKESH/gotbot%20game/data/gameplay_physics_config.tres)
- **Script Interface & Aliases:** [`scripts/physics_config.gd`](file:///c:/Users/LOKESH/gotbot%20game/scripts/physics_config.gd)

---

## Complete Parameter Reference

| Category | Parameter Name | Value | Unit | Description |
|---|---|---|---|---|
| **Gravity & Fall** | `gravity` | `24.0` | m/s² | Downward acceleration applied to CharacterBody3D when `not is_on_floor()`. |
| | `terminal_fall_speed` | `55.0` | m/s | Maximum downward fall velocity. Prevents tunneling through geometry. |
| **Player Movement** | `walk_speed` | `8.5` | m/s | Base ground walking speed. |
| | `sprint_speed` | `14.0` | m/s | Ground sprint speed (Shift / Ctrl). |
| | `acceleration` | `50.0` | m/s² | Rate at which player velocity approaches `target_velocity`. |
| | `deceleration` | `40.0` | m/s² | Rate at which player velocity returns to `0.0` when no input is provided. |
| | `air_control_multiplier` | `0.45` | ratio | Air acceleration multiplier (`air_accel = acceleration * 0.45 = 22.5 m/s²`). |
| **Jump & Buffering** | `jump_velocity` | `9.5` | m/s | Upward vertical impulse applied on primary jump. |
| | `double_jump_velocity` | `10.5` | m/s | Upward vertical impulse applied on acrobatic double jump (city mode). |
| | `max_jumps` | `2` | count | Maximum allowed jumps before landing (1 ground jump + 1 air double jump). |
| | `coyote_time` | `0.15` | s | Window of time in which player can still jump after running off a ledge. |
| | `jump_buffer` | `0.12` | s | Window of time in which jump input is queued prior to touching the ground. |
| **Combat** | `knockback_force` | `9.0` | m/s | Horizontal velocity impulse imparted on strike impact. |
| | `knockback_upward_lift` | `4.5` | m/s | Vertical lift impulse imparted on strike impact. |
| | `hit_stun` | `0.25` | s | Duration player/NPC movement is locked following a hit. |
| | `projectile_speed` | `28.0` | m/s | Travel speed of thrown projectile items. |
| | `projectile_lifetime` | `3.0` | s | Auto-cleanup lifetime of projectiles. |
| **Vehicles** | `vehicle_speed` | `11.0` | m/s | Cruising speed of street traffic. |
| | `vehicle_acceleration` | `18.0` | m/s² | Acceleration rate of vehicles toward cruise speed. |
| | `vehicle_braking` | `26.0` | m/s² | Deceleration rate when obstacle or pedestrian is detected. |
| | `vehicle_steering` | `6.0` | rad/s | Angular rotation interpolation speed around Y axis. |
| | `vehicle_grip` | `0.95` | ratio | Tire friction coefficient; controls lateral slip during turns. |
| **Traversal Abilities** | `traversal_speed_cap` | `30.0` | m/s | Speed ceiling after web pull or grapple leap. |
| | `web_force` | `26.0` | m/s | Horizontal pull speed toward target building ledge. |
| | `web_lift` | `12.0` | m/s | Vertical upward pop on web slingshot release. |
| | `rope_length` | `45.0` | m | Maximum acquisition distance for web / grapple anchors. |
| | `traversal_damping` | `0.92` | ratio | Per-frame velocity damping following traversal boost. |
| | `traversal_cooldown` | `1.4` | s | Re-use cooldown timer between traversal dashes. |
| **Camera** | `camera_distance` | `4.8` | m | Default SpringArm3D length. |
| | `camera_height` | `1.6` | m | Vertical offset of camera pivot relative to character origin. |
| | `camera_sensitivity` | `0.003` | rad/px | Mouse look rotation multiplier. |
| | `min_pitch` | `-70.0` | deg | Maximum upward look angle (looking down from above). |
| | `max_pitch` | `45.0` | deg | Maximum downward look angle (looking up at skyscrapers). |
| | `camera_smoothing` | `10.0` | rate | Exponential follow rate (`1.0 - exp(-smoothing * delta)`). |
| | `camera_fov` | `75.0` | deg | Default field of view. |
| | `aim_fov` | `55.0` | deg | Narrowed field of view when right-click aim mode is active. |
| | `shoulder_offset` | `1.2` | m | Horizontal camera offset when aiming over the shoulder. |
| | `zoom_min` | `1.5` | m | Minimum zoom distance on scroll up. |
| | `zoom_max` | `8.0` | m | Maximum zoom distance on scroll down. |

---

## Applied Movement Equations

1. **Vertical Gravity:**
   ```gdscript
   velocity.y = max(velocity.y - gravity * delta, -terminal_fall_speed)
   ```
2. **Horizontal Target Movement:**
   ```gdscript
   target_velocity = input_direction * current_speed
   ```
3. **Ground Acceleration:**
   ```gdscript
   velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
   velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)
   ```
4. **No-Input Ground Deceleration:**
   ```gdscript
   velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)
   velocity.z = move_toward(velocity.z, 0.0, deceleration * delta)
   ```
5. **Air Control:**
   ```gdscript
   var air_accel = acceleration * air_control_multiplier
   velocity.x = move_toward(velocity.x, target_velocity.x, air_accel * delta)
   velocity.z = move_toward(velocity.z, target_velocity.z, air_accel * delta)
   ```
