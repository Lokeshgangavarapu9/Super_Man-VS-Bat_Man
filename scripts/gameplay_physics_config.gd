class_name GameplayPhysicsConfig
extends Resource

## Authoritative gameplay physics configuration resource
## Exposes all tunable parameters for player, combat, vehicles, traversal, and camera.

@export_group("Gravity & Fall")
@export var gravity: float = 24.0
@export var terminal_fall_speed: float = 55.0

@export_group("Player Movement")
@export var walk_speed: float = 8.5
@export var sprint_speed: float = 14.0
@export var acceleration: float = 50.0 # m/s² acceleration
@export var deceleration: float = 40.0 # m/s² deceleration
@export var air_control_multiplier: float = 0.45 # air_acceleration = acceleration * air_control_multiplier

@export_group("Jump & Timing")
@export var jump_velocity: float = 9.5
@export var double_jump_velocity: float = 10.5
@export var max_jumps: int = 2
@export var coyote_time: float = 0.15 # seconds allowed to jump after walking off a ledge
@export var jump_buffer: float = 0.12 # seconds jump input is buffered prior to landing

@export_group("Combat")
@export var knockback_force: float = 9.0
@export var knockback_upward_lift: float = 4.5
@export var hit_stun: float = 0.25
@export var projectile_speed: float = 28.0
@export var projectile_lifetime: float = 3.0

@export_group("Vehicles")
@export var vehicle_speed: float = 11.0
@export var vehicle_acceleration: float = 18.0
@export var vehicle_braking: float = 26.0
@export var vehicle_steering: float = 6.0
@export var vehicle_grip: float = 0.95

@export_group("Traversal Abilities")
@export var traversal_speed_cap: float = 30.0
@export var web_force: float = 26.0
@export var web_lift: float = 12.0
@export var rope_length: float = 45.0
@export var traversal_damping: float = 0.92
@export var traversal_cooldown: float = 1.4

@export_group("Camera")
@export var camera_distance: float = 4.8
@export var camera_height: float = 1.6
@export var camera_sensitivity: float = 0.003
@export var min_pitch: float = -70.0 # degrees
@export var max_pitch: float = 45.0  # degrees
@export var camera_smoothing: float = 10.0
@export var camera_fov: float = 75.0
@export var aim_fov: float = 55.0
@export var shoulder_offset: float = 1.2
@export var zoom_min: float = 1.5
@export var zoom_max: float = 8.0
