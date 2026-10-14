# Third-Person Camera Configuration

## Adapted System
- **Foundation Source:** `https://github.com/DoctorArta/godot-adaptive-camera-rig`
- **Implementation File:** [`scripts/third_person_camera.gd`](file:///c:/Users/LOKESH/gotbot%20game/scripts/third_person_camera.gd)
- **Scene File:** [`scenes/third_person_camera.tscn`](file:///c:/Users/LOKESH/gotbot%20game/scenes/third_person_camera.tscn)

---

## Architecture & Features

### 1. SpringArm Collision Protection
- `SpringArm3D` is configured with `collision_mask = 1` (World Environment Layer) and `margin = 0.25m`.
- When the player runs near skyscrapers, walls, underpasses, or props, the spring length automatically contracts, preventing the camera from clipping into geometry or showing void space.

### 2. Smooth Interpolation Equation
To eliminate frame-rate jitter and camera stutter, position follow uses frame-rate independent exponential decay:
```gdscript
var blend := 1.0 - exp(-camera_smoothing * delta)
global_position = global_position.lerp(target_pos, blend)
```
- A teleport threshold (`distance_squared > 225.0`) snaps the camera instantly if the player respawns or teleports across the city, avoiding unwanted long camera sweeps.

### 3. Pitch Limits & Orientation
- **Pitch Range:** `-70.0°` (looking straight down from high above) to `+45.0°` (looking upward at towering skyscrapers).
- **Initial Pitch:** `-12.0°` (`deg_to_rad(-12.0)`) provides an ideal third-person action viewing angle behind the hero.
- **Rotation Math:** `quaternion = Quaternion(Vector3.UP, yaw) * Quaternion(Vector3.RIGHT, pitch)`

### 4. Over-The-Shoulder Aim Mode
- Pressing and holding **Right Mouse Button** activates aim mode.
- Field of view smoothly zooms from default **75.0°** down to **55.0°**.
- Camera horizontal offset shifts to **+1.2m** (over the right shoulder) using exponential blend `1.0 - exp(-8.0 * delta)`.
- Releasing the button returns the camera smoothly to center.

### 5. Independent Split-Screen Operation
- In **Double Player** mode, Player 1 and Player 2 have separate `ThirdPersonCamera` instances in separate viewports.
- Player 1 uses mouse motion for looking, while Player 2 uses controller right stick / directional actions (`p2_look_left`, `p2_look_right`, `p2_look_up`, `p2_look_down`).
- Neither player's look inputs overwrite or conflict with the other.
