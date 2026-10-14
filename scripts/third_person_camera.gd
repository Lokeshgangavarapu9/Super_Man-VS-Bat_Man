class_name ThirdPersonCamera
extends Node3D

const PC = preload("res://scripts/physics_config.gd")

@export var target: Node3D = null
@export var follow_speed: float = PC.CAM_FOLLOW_SPEED
@export var camera_smoothing: float = PC.CAM_SMOOTHING
@export var mouse_sensitivity: float = PC.CAM_MOUSE_SENSITIVITY
@export var min_pitch: float = PC.CAM_PITCH_MIN       # -70.0 degrees
@export var max_pitch: float = PC.CAM_PITCH_MAX       # +45.0 degrees
@export var default_distance: float = PC.CAM_DEFAULT_DIST # 4.8m
@export var min_distance: float = PC.CAM_MIN_DIST     # 1.5m
@export var max_distance: float = PC.CAM_MAX_DIST     # 8.0m
@export var camera_height: float = PC.CAM_HEIGHT     # 1.6m
@export var default_fov: float = PC.CAM_FOV           # 75.0 deg
@export var aim_fov: float = PC.CAM_AIM_FOV           # 55.0 deg
@export var shoulder_offset: float = PC.CAM_SHOULDER_OFFSET # 1.2m
@export var player_id: int = 1

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var camera: Camera3D = $SpringArm3D/Camera3D

var pitch: float = deg_to_rad(-12.0) # Initial pitch looking slightly down
var yaw: float = 0.0
var shake_amount: float = 0.0
var is_aiming: bool = false

func _ready() -> void:
	top_level = true # Move independently in world space
	if target and "player_id" in target:
		player_id = target.player_id
	if spring_arm:
		spring_arm.spring_length = default_distance
		spring_arm.margin = 0.25
		spring_arm.collision_mask = 1 # Environment layer
	if camera:
		camera.fov = default_fov
	# Capture mouse by default for P1 in single-viewport
	if not Engine.is_editor_hint() and player_id == 1:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if player_id == 1:
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			yaw -= event.relative.x * mouse_sensitivity
			pitch -= event.relative.y * mouse_sensitivity
			pitch = clamp(pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
		elif event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				if spring_arm: spring_arm.spring_length = max(min_distance, spring_arm.spring_length - 0.4)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				if spring_arm: spring_arm.spring_length = min(max_distance, spring_arm.spring_length + 0.4)
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				is_aiming = event.pressed
			elif event.pressed and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED and not get_tree().paused:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		# Player 2 controller / arrow key camera controls
		var stick_look := Vector2.ZERO
		if Input.is_action_pressed("p2_look_left"): stick_look.x -= 1.0
		if Input.is_action_pressed("p2_look_right"): stick_look.x += 1.0
		if Input.is_action_pressed("p2_look_up"): stick_look.y -= 1.0
		if Input.is_action_pressed("p2_look_down"): stick_look.y += 1.0
		if stick_look.length_squared() > 0.0:
			yaw -= stick_look.x * 2.5 * get_process_delta_time()
			pitch -= stick_look.y * 2.5 * get_process_delta_time()
			pitch = clamp(pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))

func _physics_process(delta: float) -> void:
	if target and is_instance_valid(target):
		var target_pos := target.global_position + Vector3(0, camera_height, 0)
		if global_position.distance_squared_to(target_pos) > 225.0:
			global_position = target_pos
		else:
			# Smooth frame-rate independent exponential interpolation:
			var blend := 1.0 - exp(-camera_smoothing * delta)
			global_position = global_position.lerp(target_pos, blend)
	
	# Apply rotation from yaw and pitch
	quaternion = Quaternion(Vector3.UP, yaw) * Quaternion(Vector3.RIGHT, pitch)
	
	# Smoothly interpolate FOV and shoulder offset for aiming
	if camera:
		var blend := 1.0 - exp(-8.0 * delta)
		var target_h_offset := shoulder_offset if is_aiming else 0.0
		camera.h_offset = lerp(camera.h_offset, target_h_offset, blend)
		var target_fov := aim_fov if is_aiming else default_fov
		camera.fov = lerp(camera.fov, target_fov, blend)
		
		# Apply camera shake if active
		if shake_amount > 0.0:
			camera.h_offset += randf_range(-shake_amount, shake_amount)
			camera.v_offset = randf_range(-shake_amount, shake_amount)
			shake_amount = move_toward(shake_amount, 0.0, delta * 3.5)
		else:
			camera.v_offset = 0.0

func trigger_shake(amount: float = 0.3) -> void:
	shake_amount = amount

func get_camera_basis() -> Basis:
	return Basis(Vector3.UP, yaw)

