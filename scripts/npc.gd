class_name CitizenNPC
extends CharacterBody3D

enum State {
	IDLE,
	WANDER,
	REACT_HERO,
	PANIC_FLEE
}

const PC = preload("res://scripts/physics_config.gd")

@export var walk_speed: float = PC.NPC_WALK_SPEED
@export var run_speed: float = PC.NPC_RUN_SPEED
@export var waypoints: Array[Vector3] = []

@onready var mesh_root: Node3D = $MeshRoot
@onready var body_mesh: MeshInstance3D = $MeshRoot/Torso
@onready var head_mesh: MeshInstance3D = $MeshRoot/Head
@onready var left_arm: Node3D = $MeshRoot/LeftArm
@onready var right_arm: Node3D = $MeshRoot/RightArm
@onready var left_leg: Node3D = $MeshRoot/LeftLeg
@onready var right_leg: Node3D = $MeshRoot/RightLeg

var current_state: State = State.WANDER
var state_timer: float = 0.0
var walk_cycle: float = 0.0
var current_waypoint_idx: int = 0
var flee_direction: Vector3 = Vector3.ZERO
var panic_duration: float = 0.0
var hero_ref: Node3D = null

func _ready() -> void:
	# Randomize outfit color
	if body_mesh:
		var mat := StandardMaterial3D.new()
		var colors := [
			Color(0.2, 0.45, 0.7), Color(0.7, 0.3, 0.25), Color(0.25, 0.6, 0.4),
			Color(0.8, 0.65, 0.2), Color(0.4, 0.25, 0.5), Color(0.3, 0.35, 0.4)
		]
		mat.albedo_color = colors[randi() % colors.size()]
		body_mesh.material_override = mat

func set_route(points: Array[Vector3]) -> void:
	waypoints = points
	current_waypoint_idx = 0
	if waypoints.size() > 0:
		global_position = waypoints[0]

func trigger_panic(danger_origin: Vector3) -> void:
	current_state = State.PANIC_FLEE
	flee_direction = (global_position - danger_origin).normalized()
	if flee_direction.length_squared() < 0.001:
		flee_direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	panic_duration = randf_range(4.0, 7.0)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= PC.GRAVITY * delta
		velocity.y = max(velocity.y, -PC.MAX_FALL_SPEED)
		
	match current_state:
		State.IDLE:
			_process_idle(delta)
		State.WANDER:
			_process_wander(delta)
		State.REACT_HERO:
			_process_react_hero(delta)
		State.PANIC_FLEE:
			_process_panic(delta)
			
	move_and_slide()
	_animate_limbs(delta)

func _process_idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, delta * 8.0)
	velocity.z = move_toward(velocity.z, 0.0, delta * 8.0)
	state_timer -= delta
	if state_timer <= 0.0:
		current_state = State.WANDER
		state_timer = randf_range(4.0, 9.0)

func _process_wander(delta: float) -> void:
	state_timer -= delta
	if state_timer <= 0.0 and randf() < 0.35:
		current_state = State.IDLE
		state_timer = randf_range(2.0, 5.0)
		return
		
	if waypoints.is_empty():
		return
		
	var target_pt: Vector3 = waypoints[current_waypoint_idx]
	target_pt.y = global_position.y
	
	if global_position.distance_to(target_pt) < 1.4:
		current_waypoint_idx = (current_waypoint_idx + 1) % waypoints.size()
		target_pt = waypoints[current_waypoint_idx]
		target_pt.y = global_position.y
		
	var dir: Vector3 = (target_pt - global_position).normalized()
	if dir.length_squared() > 0.001:
		var target_rot: float = atan2(-dir.x, -dir.z)
		rotation.y = lerp_angle(rotation.y, target_rot, delta * 5.0)
		
	velocity.x = dir.x * walk_speed
	velocity.z = dir.z * walk_speed

func _process_react_hero(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, delta * 8.0)
	velocity.z = move_toward(velocity.z, 0.0, delta * 8.0)
	if hero_ref and is_instance_valid(hero_ref):
		var dir := (hero_ref.global_position - global_position).normalized()
		var target_rot := atan2(-dir.x, -dir.z)
		rotation.y = lerp_angle(rotation.y, target_rot, delta * 5.0)
	state_timer -= delta
	if state_timer <= 0.0:
		current_state = State.WANDER

func _process_panic(delta: float) -> void:
	panic_duration -= delta
	if panic_duration <= 0.0:
		current_state = State.WANDER
		return
		
	var target_rot: float = atan2(-flee_direction.x, -flee_direction.z)
	rotation.y = lerp_angle(rotation.y, target_rot, delta * 8.0)
	velocity.x = flee_direction.x * run_speed
	velocity.z = flee_direction.z * run_speed

func _animate_limbs(delta: float) -> void:
	var horiz_vel := Vector2(velocity.x, velocity.z).length()
	if horiz_vel > 0.4:
		var anim_spd := 8.0 if current_state == State.PANIC_FLEE else 5.0
		walk_cycle += delta * anim_spd
		var swing := sin(walk_cycle) * (0.65 if current_state == State.PANIC_FLEE else 0.4)
		if left_arm: left_arm.rotation.x = -swing
		if right_arm: right_arm.rotation.x = swing
		if left_leg: left_leg.rotation.x = swing
		if right_leg: right_leg.rotation.x = -swing
	else:
		if left_arm: left_arm.rotation.x = move_toward(left_arm.rotation.x, 0.0, delta * 4.0)
		if right_arm: right_arm.rotation.x = move_toward(right_arm.rotation.x, 0.0, delta * 4.0)
		if left_leg: left_leg.rotation.x = move_toward(left_leg.rotation.x, 0.0, delta * 4.0)
		if right_leg: right_leg.rotation.x = move_toward(right_leg.rotation.x, 0.0, delta * 4.0)
