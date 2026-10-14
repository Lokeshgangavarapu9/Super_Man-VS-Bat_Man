class_name CityVehicle
extends CharacterBody3D

const PC = preload("res://scripts/physics_config.gd")

@export var max_speed: float = PC.VEHICLE_SPEED
@export var speed: float = PC.VEHICLE_SPEED
@export var acceleration: float = PC.VEHICLE_ACCELERATION

@export var braking: float = PC.VEHICLE_BRAKING
@export var steer_speed: float = PC.VEHICLE_STEERING
@export var grip: float = PC.VEHICLE_GRIP
@export var waypoints: Array[Vector3] = []
@export var vehicle_color: Color = Color(0.2, 0.4, 0.8)

@onready var raycast: RayCast3D = $RayCast3D
@onready var body_mesh: MeshInstance3D = $CarBody
@onready var cabin_mesh: MeshInstance3D = $Cabin

var current_waypoint_idx: int = 0
var current_speed: float = 0.0
var is_stopped: bool = false
var stop_timer: float = 0.0
var hp: float = 100.0

func _ready() -> void:
	if body_mesh:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = vehicle_color
		mat.metallic = 0.6
		mat.roughness = 0.3
		body_mesh.material_override = mat
	if cabin_mesh:
		var glass_mat := StandardMaterial3D.new()
		glass_mat.albedo_color = Color(0.1, 0.15, 0.22, 0.8)
		glass_mat.metallic = 0.9
		glass_mat.roughness = 0.1
		cabin_mesh.material_override = glass_mat

func set_route(points: Array[Vector3]) -> void:
	waypoints = points
	current_waypoint_idx = 0
	if waypoints.size() > 0:
		global_position = waypoints[0]

func _physics_process(delta: float) -> void:
	# Vertical gravity: ensures vehicles hug road surfaces and never float
	if not is_on_floor():
		velocity.y = max(velocity.y - PC.GRAVITY * delta, -PC.TERMINAL_FALL_SPEED)
	else:
		velocity.y = 0.0

	if waypoints.is_empty():
		current_speed = move_toward(current_speed, 0.0, braking * delta)
		var fwd := -transform.basis.z
		velocity.x = fwd.x * current_speed
		velocity.z = fwd.z * current_speed
		move_and_slide()
		return
		
	var obstacle_detected: bool = false
	if raycast and raycast.is_colliding():
		var col: Object = raycast.get_collider()
		if col != self:
			obstacle_detected = true
			
	if obstacle_detected:
		# Braking: rapid deceleration when obstacle or pedestrian ahead
		current_speed = move_toward(current_speed, 0.0, braking * delta)
		var fwd := -transform.basis.z
		velocity.x = fwd.x * current_speed
		velocity.z = fwd.z * current_speed
		move_and_slide()
		return
		
	var target_pt: Vector3 = waypoints[current_waypoint_idx]
	target_pt.y = global_position.y
	
	var dist: float = global_position.distance_to(target_pt)
	if dist < 2.5:
		current_waypoint_idx = (current_waypoint_idx + 1) % waypoints.size()
		target_pt = waypoints[current_waypoint_idx]
		target_pt.y = global_position.y
		
	var dir: Vector3 = (target_pt - global_position).normalized()
	var steer_amount: float = 0.0
	if dir.length_squared() > 0.001:
		var target_rot: float = atan2(-dir.x, -dir.z)
		var rot_diff: float = wrapf(target_rot - rotation.y, -PI, PI)
		steer_amount = clampf(rot_diff * 2.0, -1.0, 1.0)
		rotation.y = lerp_angle(rotation.y, target_rot, delta * steer_speed)
		
	# Dynamic acceleration toward target cruise speed
	current_speed = move_toward(current_speed, max_speed, acceleration * delta)
	
	var fwd := -transform.basis.z
	var rgt := transform.basis.x
	# Lateral grip and slip modeling
	var lateral_slip := steer_amount * current_speed * (1.0 - grip)
	velocity.x = fwd.x * current_speed + rgt.x * lateral_slip
	velocity.z = fwd.z * current_speed + rgt.z * lateral_slip
	
	var prev_speed := current_speed
	move_and_slide()
	
	# Impact collision handling from GTA-mini foundation
	if get_slide_collision_count() > 0 and prev_speed > 4.0:
		for i in range(get_slide_collision_count()):
			var col := get_slide_collision(i)
			var normal := col.get_normal()
			var dot := (-normal).dot(fwd)
			if dot > 0.5:
				current_speed *= 0.65
				hp = max(0.0, hp - prev_speed * 1.5)
				break

