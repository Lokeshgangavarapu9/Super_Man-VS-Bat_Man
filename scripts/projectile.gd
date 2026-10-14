class_name Projectile
extends Area3D

const CombatScript = preload("res://scripts/combat.gd")
const PC = preload("res://scripts/physics_config.gd")

@export var speed: float = PC.PROJECTILE_SPEED
@export var damage: float = 15.0
@export var knockback_force: float = 11.0
@export var lifetime: float = PC.PROJECTILE_LIFETIME
@export var owner_player_id: int = 1
@export var projectile_type: String = "web" # "web", "shadow", "special_web", "special_shadow"

var move_direction: Vector3 = Vector3.FORWARD
var time_alive: float = 0.0
var has_impacted: bool = false

@onready var visual_mesh: Node3D = $VisualMesh
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	_setup_visuals()

func setup(p_owner_id: int, p_type: String, p_direction: Vector3, p_damage: float, p_knockback: float, p_speed: float = PC.PROJECTILE_SPEED) -> void:
	owner_player_id = p_owner_id
	projectile_type = p_type
	move_direction = p_direction.normalized()
	damage = p_damage
	knockback_force = p_knockback
	speed = p_speed
	
	# Configure masks
	if owner_player_id == 1:
		collision_layer = 8
		collision_mask = 1 | 4 # Hit Environment and Player 2
	else:
		collision_layer = 16
		collision_mask = 1 | 2 # Hit Environment and Player 1
	
	if move_direction.length_squared() > 0.001:
		look_at(global_position + move_direction, Vector3.UP)
	
	_setup_visuals()
	
	# Immediate overlap check for point-blank shots
	var timer := get_tree().create_timer(0.02) if get_tree() else null
	if timer:
		timer.timeout.connect(_check_point_blank_overlaps)

func _check_point_blank_overlaps() -> void:
	if has_impacted or not is_inside_tree():
		return
	for body in get_overlapping_bodies():
		if body.has_method("take_damage") and body.has_method("get_player_id"):
			if body.get_player_id() != owner_player_id:
				_handle_hit_target(body)
				return

func _setup_visuals() -> void:
	if not is_inside_tree() or visual_mesh == null:
		return
		
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	
	match projectile_type:
		"web":
			mat.albedo_color = Color(0.95, 0.98, 1.0, 0.95)
			mat.emission_enabled = true
			mat.emission = Color(0.3, 0.7, 1.0)
			mat.emission_energy_multiplier = 2.5
			scale = Vector3(1.0, 1.0, 1.0)
		"shadow":
			mat.albedo_color = Color(0.14, 0.15, 0.18, 1.0) # Matte steel batarang
			mat.metallic = 0.9
			mat.roughness = 0.2
			mat.emission_enabled = true
			mat.emission = Color(0.6, 0.8, 1.0) # Cold steel / blue edge glow
			mat.emission_energy_multiplier = 2.0
			scale = Vector3(1.2, 0.35, 1.2)
		"special_web":
			mat.albedo_color = Color(0.5, 0.88, 1.0, 0.95)
			mat.emission_enabled = true
			mat.emission = Color(0.2, 0.9, 1.0)
			mat.emission_energy_multiplier = 4.5
			scale = Vector3(2.4, 2.4, 2.4)
		"special_shadow":
			mat.albedo_color = Color(0.08, 0.08, 0.1, 1.0)
			mat.metallic = 0.9
			mat.emission_enabled = true
			mat.emission = Color(0.3, 0.6, 1.0)
			mat.emission_energy_multiplier = 4.5
			scale = Vector3(2.5, 1.3, 2.5)
			
	for child in visual_mesh.get_children():
		if child is MeshInstance3D:
			child.material_override = mat

func _physics_process(delta: float) -> void:
	if has_impacted:
		return
		
	time_alive += delta
	if time_alive >= lifetime:
		_impact_and_vanish(false)
		return
		
	global_position += move_direction * speed * delta
	
	if visual_mesh:
		if projectile_type == "shadow" or projectile_type == "special_shadow":
			visual_mesh.rotate_y(delta * 28.0) # Fast spinning batarang
		else:
			visual_mesh.rotate_x(delta * 12.0)
			visual_mesh.rotate_z(delta * 14.0)

func _on_body_entered(body: Node) -> void:
	if has_impacted:
		return
	if body.has_method("get_player_id") and body.get_player_id() == owner_player_id:
		return
		
	if body.has_method("take_damage") and body.has_method("get_player_id"):
		if body.get_player_id() != owner_player_id:
			_handle_hit_target(body)
			return
			
	if body.has_method("take_damage") and (body is CharacterBody3D or body.is_in_group("hostiles")):
		_handle_hit_target(body)
		if projectile_type.begins_with("web") and body.has_method("apply_web_restraint"):
			body.apply_web_restraint(2.5)
		elif projectile_type.begins_with("special_shadow") and body.has_method("apply_emp_disruption"):
			body.apply_emp_disruption(2.0)
		return
		
	if body is StaticBody3D or body is CSGShape3D:
		_impact_and_vanish(false)

func _on_area_entered(area: Area3D) -> void:
	if has_impacted:
		return
	var parent: Node = area.get_parent()
	if parent and parent.has_method("take_damage") and parent.has_method("get_player_id"):
		if parent.get_player_id() != owner_player_id:
			_handle_hit_target(parent)
	elif parent and parent.has_method("take_damage") and parent.is_in_group("hostiles"):
		_handle_hit_target(parent)

func _handle_hit_target(target: Node) -> void:
	has_impacted = true
	var knock_dir: Vector3 = CombatScript.calculate_knockback(global_position, target.global_position, knockback_force, 3.5)
	target.take_damage(damage, knock_dir, owner_player_id)
	if projectile_type.begins_with("web") and target.has_method("apply_web_slow"):
		target.apply_web_slow(1.5, 0.45)
	elif projectile_type.begins_with("special_shadow") and target.has_method("apply_emp_disruption"):
		target.apply_emp_disruption(1.5)
	_impact_and_vanish(true)

func _impact_and_vanish(hit_target: bool) -> void:
	has_impacted = true
	var flash: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.6 if not projectile_type.begins_with("special") else 1.2
	sphere.height = sphere.radius * 2.0
	flash.mesh = sphere
	
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if projectile_type == "web" or projectile_type == "special_web":
		mat.albedo_color = Color(0.4, 0.85, 1.0, 0.9)
	else:
		mat.albedo_color = Color(0.7, 0.85, 1.0, 0.9)
	var parent_node: Node = get_parent()
	if parent_node:
		parent_node.add_child(flash)
		flash.global_position = global_position
		var tween: Tween = flash.create_tween()
		if tween:
			tween.tween_property(flash, "scale", Vector3.ZERO, 0.2)
			tween.tween_callback(flash.queue_free)
	
	queue_free()
