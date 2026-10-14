## Physics configuration — single source of truth for all gameplay physics
## All scripts read these constants; do not duplicate or override them.
##
## EDIT THIS FILE to tune gameplay feel. All values documented below.

class_name PhysicsConfig
extends RefCounted

# ─── CONFIG RESOURCE REFERENCE ────────────────────────────────────────────────
const GameplayPhysicsConfigScript = preload("res://scripts/gameplay_physics_config.gd")
static var _config: Resource = null

static func get_config() -> Resource:
	if _config == null:
		_config = load("res://data/gameplay_physics_config.tres")
		if _config == null:
			_config = GameplayPhysicsConfigScript.new()
	return _config


# ─── GRAVITY & FALL ───────────────────────────────────────────────────────────
const GRAVITY: float = 24.0
const TERMINAL_FALL_SPEED: float = 55.0
const MAX_FALL_SPEED: float = 55.0

# ─── PLAYER MOVEMENT ──────────────────────────────────────────────────────────
const PLAYER_WALK_SPEED: float = 8.5
const PLAYER_SPRINT_SPEED: float = 14.0
const PLAYER_ACCELERATION: float = 50.0       # m/s² ground acceleration
const PLAYER_DECELERATION: float = 40.0       # m/s² ground deceleration
const AIR_CONTROL_MULTIPLIER: float = 0.45    # air_acceleration = acceleration * air_control_multiplier
const PLAYER_ACCEL: float = 50.0             # backwards-compatibility alias
const PLAYER_FRICTION: float = 40.0          # backwards-compatibility alias
const PLAYER_AIR_ACCEL: float = 22.5         # 50.0 * 0.45
const PLAYER_AIR_FRICTION: float = 18.0

# ─── JUMP & TIMING ────────────────────────────────────────────────────────────
const JUMP_VELOCITY: float = 9.5
const DOUBLE_JUMP_VELOCITY: float = 10.5
const MAX_JUMPS: int = 2
const COYOTE_TIME: float = 0.15              # Seconds allowed to jump after leaving floor
const JUMP_BUFFER: float = 0.12              # Seconds jump input is preserved before landing

# ─── TRAVERSAL ABILITIES ──────────────────────────────────────────────────────
const TRAVERSAL_SPEED_CAP: float = 30.0
const WEB_PULL_SPEED: float = 26.0
const WEB_PULL_LIFT: float = 12.0
const WEB_FORCE: float = 26.0
const WEB_LIFT: float = 12.0
const ROPE_LENGTH: float = 45.0
const TRAVERSAL_DAMPING: float = 0.92
const TRAVERSAL_COOLDOWN: float = 1.4
const GRAPPLE_SPEED: float = 24.0
const GRAPPLE_LIFT: float = 10.0

# ─── COMBAT ───────────────────────────────────────────────────────────────────
const KNOCKBACK_FORCE: float = 9.0
const KNOCKBACK_UPWARD_LIFT: float = 4.5
const HIT_STUN_DURATION: float = 0.25
const INVULNERABILITY_FRAMES: float = 0.0

# ─── NPC MOVEMENT ─────────────────────────────────────────────────────────────
const NPC_WALK_SPEED: float = 2.4
const NPC_RUN_SPEED: float = 5.2
const HOSTILE_NPC_SPEED: float = 4.2

# ─── VEHICLE ──────────────────────────────────────────────────────────────────
const VEHICLE_SPEED: float = 11.0
const VEHICLE_ACCELERATION: float = 18.0
const VEHICLE_BRAKING: float = 26.0
const VEHICLE_STEER_SPEED: float = 6.0
const VEHICLE_STEERING: float = 6.0
const VEHICLE_GRIP: float = 0.95
const VEHICLE_FLOOR_CAST_DIST: float = 2.0

# ─── CAMERA ───────────────────────────────────────────────────────────────────
const CAM_FOLLOW_SPEED: float = 14.0
const CAM_SMOOTHING: float = 14.0
const CAM_DEFAULT_DIST: float = 4.8

const CAM_DISTANCE: float = 4.8
const CAM_HEIGHT: float = 1.6
const CAM_MIN_DIST: float = 1.5
const CAM_MAX_DIST: float = 8.0
const CAM_PITCH_MIN: float = -70.0          # degrees (updated to -70 to +45)
const CAM_PITCH_MAX: float = 45.0           # degrees
const CAM_MOUSE_SENSITIVITY: float = 0.003
const CAM_FOV: float = 75.0
const CAM_AIM_FOV: float = 55.0
const CAM_SHOULDER_OFFSET: float = 1.2


# ─── ARENA BOUNDS ─────────────────────────────────────────────────────────────
const ARENA_BOUND: float = 14.5             # X/Z clamp limit in arena mode

# ─── PROJECTILE ───────────────────────────────────────────────────────────────
const PROJECTILE_SPEED: float = 28.0        # Default projectile m/s
const PROJECTILE_LIFETIME: float = 3.0      # Seconds before auto-cleanup
const SPECIAL_PROJECTILE_SPEED: float = 18.0

# ─── COLLISION LAYER MAP ──────────────────────────────────────────────────────
# Layer 1 = Environment (ground, buildings, walls, props)
# Layer 2 = Player1    (CharacterBody3D collision body)
# Layer 3 = Player2    (CharacterBody3D collision body)
# Layer 4 = AttackP1   (melee hitbox Area3D for P1)
# Layer 5 = AttackP2   (melee hitbox Area3D for P2)
# Layer 6 = NPC        (citizen NPCs)
# Layer 7 = HostileNPC (hostile NPCs — enemies)
# Layer 8 = Vehicles   (CityVehicle CharacterBody3D)
# Layer 9 = Collectibles (token/item Area3D)
