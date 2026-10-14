class_name CityVehicle
extends CharacterBody3D

const PC = preload("res://scripts/physics_config.gd")

@export var speed: float = PC.VEHICLE_SPEED
@export var steer_speed: float = PC.VEHICLE_STEER_SPEED
@export var waypoints: Array[Vector3] = []
@export var vehicle_color: Color = Color(0.2, 0.4, 0.8)

@onready var raycast: RayCast3D = $RayCast3D
@onready var body_mesh: MeshInstance3D = $CarBody
@onready var cabin_mesh: MeshInstance3D = $Cabin

var current_waypoint_idx: int = 0
var is_stopped: bool = false
var stop_timer: float = 0.0

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
	# Always apply gravity when not on the road/floor so cars never float
	if not is_on_floor():
		velocity.y -= PC.GRAVITY * delta
		velocity.y = max(velocity.y, -PC.MAX_FALL_SPEED)
	else:
		velocity.y = 0.0

	if waypoints.is_empty():
		move_and_slide()
		return
		
	var obstacle_detected: bool = false
	if raycast and raycast.is_colliding():
		var col: Object = raycast.get_collider()
		if col != self:
			obstacle_detected = true
			
	if obstacle_detected:
		velocity.x = move_toward(velocity.x, 0.0, delta * 18.0)
		velocity.z = move_toward(velocity.z, 0.0, delta * 18.0)
		move_and_slide()
		return
		
	var target_pt: Vector3 = waypoints[current_waypoint_idx]
	target_pt.y = global_position.y
	
	var dist: float = global_position.distance_to(target_pt)
	if dist < 2.0:
		current_waypoint_idx = (current_waypoint_idx + 1) % waypoints.size()
		target_pt = waypoints[current_waypoint_idx]
		target_pt.y = global_position.y
		
	var dir: Vector3 = (target_pt - global_position).normalized()
	if dir.length_squared() > 0.001:
		var target_rot: float = atan2(-dir.x, -dir.z)
		rotation.y = lerp_angle(rotation.y, target_rot, delta * steer_speed)
		
	var fwd := -transform.basis.z
	velocity.x = fwd.x * speed
	velocity.z = fwd.z * speed
	move_and_slide()
