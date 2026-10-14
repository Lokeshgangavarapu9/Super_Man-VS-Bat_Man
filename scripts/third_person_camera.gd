class_name ThirdPersonCamera
extends Node3D

@export var target: Node3D = null
@export var follow_speed: float = 14.0
@export var mouse_sensitivity: float = 0.003
@export var min_pitch: float = -60.0
@export var max_pitch: float = 45.0
@export var default_distance: float = 4.8
@export var min_distance: float = 1.5
@export var max_distance: float = 8.0

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var camera: Camera3D = $SpringArm3D/Camera3D

var pitch: float = deg_to_rad(-12.0) # Initial pitch looking slightly down in radians
var yaw: float = 0.0
var shake_amount: float = 0.0

func _ready() -> void:
	top_level = true # Move independently in world space
	if spring_arm:
		spring_arm.spring_length = default_distance
		spring_arm.margin = 0.25
	# Capture mouse by default for seamless 3D control
	if not Engine.is_editor_hint():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if spring_arm: spring_arm.spring_length = max(min_distance, spring_arm.spring_length - 0.4)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if spring_arm: spring_arm.spring_length = min(max_distance, spring_arm.spring_length + 0.4)
		elif event.pressed and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED and not get_tree().paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	if target and is_instance_valid(target):
		var target_pos := target.global_position + Vector3(0, 1.6, 0)
		global_position = global_position.lerp(target_pos, follow_speed * delta)
	
	# Apply rotation from yaw and pitch
	quaternion = Quaternion(Vector3.UP, yaw) * Quaternion(Vector3.RIGHT, pitch)
	
	# Apply camera shake if active
	if shake_amount > 0.0 and camera:
		camera.h_offset = randf_range(-shake_amount, shake_amount)
		camera.v_offset = randf_range(-shake_amount, shake_amount)
		shake_amount = move_toward(shake_amount, 0.0, delta * 3.5)
	elif camera:
		camera.h_offset = 0.0
		camera.v_offset = 0.0

func trigger_shake(amount: float = 0.3) -> void:
	shake_amount = amount

func get_camera_basis() -> Basis:
	return Basis(Vector3.UP, yaw)
