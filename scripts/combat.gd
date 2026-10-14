class_name Combat
extends RefCounted

## Damage values
const MELEE_DAMAGE: float = 12.0
const PROJECTILE_DAMAGE: float = 15.0
const SPECIAL_DAMAGE: float = 28.0

## Knockback values
const MELEE_KNOCKBACK: float = 9.0
const PROJECTILE_KNOCKBACK: float = 11.0
const SPECIAL_KNOCKBACK: float = 18.0

## Cooldown values (seconds)
const MELEE_COOLDOWN: float = 0.35
const PROJECTILE_COOLDOWN: float = 1.0
const SPECIAL_COOLDOWN: float = 3.5
const TRAVERSAL_COOLDOWN: float = 1.4

const PC = preload("res://scripts/physics_config.gd")

## Helper function to calculate 3D knockback vector
static func calculate_knockback(attacker_pos: Vector3, target_pos: Vector3, force: float, upward_lift: float = PC.KNOCKBACK_UPWARD_LIFT) -> Vector3:
	var dir := (target_pos - attacker_pos)
	dir.y = 0.0
	if dir.length_squared() < 0.001:
		dir = Vector3(1.0, 0.0, 0.0) # default push
	else:
		dir = dir.normalized()
	return dir * force + Vector3.UP * upward_lift
