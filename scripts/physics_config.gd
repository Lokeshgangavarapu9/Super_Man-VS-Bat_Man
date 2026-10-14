## Physics configuration — single source of truth for all gameplay physics
## All scripts read these constants; do not duplicate or override them.
##
## EDIT THIS FILE to tune gameplay feel. All values documented below.

class_name PhysicsConfig
extends RefCounted

# ─── GRAVITY ──────────────────────────────────────────────────────────────────
## Applied per-frame when CharacterBody3D is NOT on_floor.
## Player, NPC, HostileNPC, and Vehicle all use this constant.
## Godot project-level gravity (9.8 m/s²) is NOT used — all entities apply
## their own gravity via velocity.y -= GRAVITY * delta.
const GRAVITY: float = 24.0

## Maximum fall speed (terminal velocity). Prevents tunnelling at high speeds.
const MAX_FALL_SPEED: float = 55.0

# ─── PLAYER MOVEMENT ──────────────────────────────────────────────────────────
const PLAYER_WALK_SPEED: float = 8.5        # m/s walk
const PLAYER_SPRINT_SPEED: float = 14.0     # m/s sprint (Shift/Ctrl held)
const PLAYER_ACCEL: float = 8.0             # Ground acceleration multiplier
const PLAYER_FRICTION: float = 6.0          # Ground deceleration multiplier
const PLAYER_AIR_ACCEL: float = 4.0         # Air acceleration (lower = sluggish)
const PLAYER_AIR_FRICTION: float = 2.5      # Air deceleration

# ─── JUMP ─────────────────────────────────────────────────────────────────────
const JUMP_VELOCITY: float = 9.5            # Initial upward impulse m/s
const DOUBLE_JUMP_VELOCITY: float = 10.5    # Double-jump upward impulse
const MAX_JUMPS: int = 2                    # 1 = single, 2 = double-jump

# ─── TRAVERSAL ABILITIES ──────────────────────────────────────────────────────
const TRAVERSAL_SPEED_CAP: float = 30.0     # Max speed after web-pull/grapple
const WEB_PULL_SPEED: float = 26.0          # Horizontal speed of web-pull impulse
const WEB_PULL_LIFT: float = 12.0           # Vertical component of web-pull
const GRAPPLE_SPEED: float = 24.0           # Horizontal speed of grapple dash
const GRAPPLE_LIFT: float = 10.0            # Vertical component of grapple

# ─── COMBAT ───────────────────────────────────────────────────────────────────
## (Damage values are in combat.gd — do not duplicate here)
const KNOCKBACK_UPWARD_LIFT: float = 4.5    # Default upward component of knockback
const HIT_STUN_DURATION: float = 0.25       # Seconds player is stunned after hit
const INVULNERABILITY_FRAMES: float = 0.0   # Seconds of post-hit invulnerability (0=none)

# ─── NPC MOVEMENT ─────────────────────────────────────────────────────────────
const NPC_WALK_SPEED: float = 2.4
const NPC_RUN_SPEED: float = 5.2
const HOSTILE_NPC_SPEED: float = 4.2

# ─── VEHICLE ──────────────────────────────────────────────────────────────────
const VEHICLE_SPEED: float = 11.0
const VEHICLE_STEER_SPEED: float = 6.0      # Rotation lerp speed (rad/s equivalent)
const VEHICLE_FLOOR_CAST_DIST: float = 2.0  # Downward raycast for road-following

# ─── CAMERA ───────────────────────────────────────────────────────────────────
const CAM_FOLLOW_SPEED: float = 14.0        # Lerp speed tracking player
const CAM_DEFAULT_DIST: float = 4.8
const CAM_MIN_DIST: float = 1.5
const CAM_MAX_DIST: float = 8.0
const CAM_PITCH_MIN: float = -60.0          # degrees
const CAM_PITCH_MAX: float = 45.0           # degrees
const CAM_MOUSE_SENSITIVITY: float = 0.003

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
