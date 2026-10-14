class_name PlayerCharacter
extends CharacterBody3D

signal health_changed(new_health: float, max_health: float)
signal cooldown_updated(ability_name: String, remaining: float, total: float)
signal player_defeated(player_id: int)
signal traversal_triggered(ability: String, target_point: Vector3)

const CombatScript = preload("res://scripts/combat.gd")
const PROJECTILE_SCENE = preload("res://scenes/projectile.tscn")

@export var player_id: int = 1 # 1 or 2
@export var opponent_path: NodePath
@export var character_name: String = "Hero"
@export var hero_type: String = "" # "crimson_weaver" or "shadow_knight"

# Physics constants
const SPEED: float = 8.5
const SPRINT_SPEED: float = 14.0
const JUMP_VELOCITY: float = 9.5
const GRAVITY: float = 24.0

# Stats
var max_health: float = 100.0
var health: float = 100.0
var is_dead: bool = false
var is_stunned: bool = false
var stun_timer: float = 0.0
var is_web_slowed: bool = false
var web_slow_timer: float = 0.0
var is_emp_disrupted: bool = false
var emp_disrupt_timer: float = 0.0

# Cooldowns
var melee_cooldown_timer: float = 0.0
var projectile_cooldown_timer: float = 0.0
var special_cooldown_timer: float = 0.0
var traversal_cooldown_timer: float = 0.0

# Traversal & City Free Roam
var is_city_mode: bool = false
var camera_ref: Camera3D = null
var jump_count: int = 0
var max_jumps: int = 2
var respawn_position: Vector3 = Vector3(0, 1.2, 0)

# Attack states
var is_attacking: bool = false
var attack_anim_tween: Tween
var has_hit_in_current_attack: bool = false

# CPU Opponent Control
var is_cpu: bool = false
var cpu_difficulty: int = 1
var cpu_decision_timer: float = 0.0
var cpu_strafe_dir: float = 1.0

# Key state tracking for clean edge-triggered inputs
var _prev_keys: Dictionary = {}

# Reference nodes
var opponent: CharacterBody3D = null
@onready var mesh_root: Node3D = $MeshRoot
@onready var body_mesh: MeshInstance3D = $MeshRoot/Torso
@onready var chest_plate: MeshInstance3D = $MeshRoot/Torso/ChestPlate
@onready var spider_emblem: Node3D = $MeshRoot/Torso/SpiderEmblem
@onready var bat_crest: MeshInstance3D = $MeshRoot/Torso/BatCrest
@onready var belt: MeshInstance3D = $MeshRoot/Torso/Belt
@onready var head_mesh: MeshInstance3D = $MeshRoot/Head
@onready var eyes_mesh: MeshInstance3D = $MeshRoot/Head/Eyes
@onready var eye_border: MeshInstance3D = $MeshRoot/Head/EyeBorder
@onready var horns_root: Node3D = $MeshRoot/Head/Horns
@onready var left_arm: Node3D = $MeshRoot/LeftArm
@onready var right_arm: Node3D = $MeshRoot/RightArm
@onready var left_leg: Node3D = $MeshRoot/LeftLeg
@onready var right_leg: Node3D = $MeshRoot/RightLeg
@onready var cape_mesh: MeshInstance3D = $MeshRoot/Cape
@onready var melee_hitbox: Area3D = $MeleeHitbox
@onready var melee_collision: CollisionShape3D = $MeleeHitbox/CollisionShape3D
@onready var projectile_spawn: Marker3D = $ProjectileSpawn
@onready var special_spawn: Marker3D = $SpecialSpawn

# Materials
var primary_material: StandardMaterial3D
var secondary_material: StandardMaterial3D
var accent_material: StandardMaterial3D
var black_trim_material: StandardMaterial3D
var flash_material: StandardMaterial3D

func _ready() -> void:
	health = max_health
	if hero_type.is_empty():
		hero_type = "crimson_weaver" if player_id == 1 else "shadow_knight"
		
	_configure_collision_layers()
	_setup_materials()
	_apply_visuals()
	
	if melee_collision:
		melee_collision.disabled = true
	if melee_hitbox:
		melee_hitbox.body_entered.connect(_on_melee_hitbox_body_entered)
	
	if not opponent_path.is_empty():
		opponent = get_node_or_null(opponent_path)

func set_hero_type(type: String) -> void:
	hero_type = type
	_setup_materials()
	_apply_visuals()

func is_weaver() -> bool:
	return hero_type == "crimson_weaver"

func enable_city_mode(cam: Camera3D) -> void:
	is_city_mode = true
	camera_ref = cam
	add_to_group("players")

func _configure_collision_layers() -> void:
	if player_id == 1:
		collision_layer = 2
		collision_mask = 1 | 4
		if melee_hitbox:
			melee_hitbox.collision_layer = 8
			melee_hitbox.collision_mask = 1 | 4
	else:
		collision_layer = 4
		collision_mask = 1 | 2
		if melee_hitbox:
			melee_hitbox.collision_layer = 16
			melee_hitbox.collision_mask = 1 | 2

func set_opponent(opp: CharacterBody3D) -> void:
	opponent = opp

func get_player_id() -> int:
	return player_id

func _setup_materials() -> void:
	primary_material = StandardMaterial3D.new()
	secondary_material = StandardMaterial3D.new()
	accent_material = StandardMaterial3D.new()
	black_trim_material = StandardMaterial3D.new()
	flash_material = StandardMaterial3D.new()
	flash_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flash_material.albedo_color = Color.WHITE

	black_trim_material.albedo_color = Color(0.04, 0.04, 0.05)
	black_trim_material.roughness = 0.5

	if is_weaver():
		character_name = "CRIMSON WEAVER"
		primary_material.albedo_color = Color(0.88, 0.12, 0.14)
		primary_material.roughness = 0.4
		secondary_material.albedo_color = Color(0.08, 0.28, 0.78)
		secondary_material.roughness = 0.4
		accent_material.albedo_color = Color(0.98, 0.98, 1.0)
		accent_material.roughness = 0.2
		accent_material.emission_enabled = true
		accent_material.emission = Color(0.8, 0.9, 1.0)
		accent_material.emission_energy_multiplier = 1.2
	else:
		character_name = "SHADOW KNIGHT"
		primary_material.albedo_color = Color(0.16, 0.17, 0.20)
		primary_material.metallic = 0.85
		primary_material.roughness = 0.32
		secondary_material.albedo_color = Color(0.06, 0.06, 0.08)
		secondary_material.roughness = 0.7
		accent_material.albedo_color = Color(0.65, 0.88, 1.0)
		accent_material.emission_enabled = true
		accent_material.emission = Color(0.6, 0.85, 1.0)
		accent_material.emission_energy_multiplier = 4.0

func _apply_visuals() -> void:
	var weaver: bool = is_weaver()
	if body_mesh: body_mesh.material_override = primary_material
	if head_mesh: head_mesh.material_override = primary_material
	if eyes_mesh: eyes_mesh.material_override = accent_material
	if eye_border: eye_border.material_override = black_trim_material
	
	if spider_emblem:
		spider_emblem.visible = weaver
		for child in spider_emblem.get_children():
			if child is MeshInstance3D:
				child.material_override = accent_material
				
	if bat_crest:
		bat_crest.visible = not weaver
		bat_crest.material_override = black_trim_material
		
	if chest_plate:
		chest_plate.visible = not weaver
		chest_plate.material_override = primary_material
		
	if belt:
		belt.material_override = secondary_material if weaver else primary_material
		for pouch in belt.get_children():
			if pouch is MeshInstance3D:
				pouch.visible = not weaver
				var pouch_mat := StandardMaterial3D.new()
				pouch_mat.albedo_color = Color(0.42, 0.35, 0.22)
				pouch_mat.metallic = 0.3
				pouch.material_override = pouch_mat
		
	var l_arm_mesh: MeshInstance3D = left_arm.get_node_or_null("ArmMesh") as MeshInstance3D
	var r_arm_mesh: MeshInstance3D = right_arm.get_node_or_null("ArmMesh") as MeshInstance3D
	var l_leg_mesh: MeshInstance3D = left_leg.get_node_or_null("LegMesh") as MeshInstance3D
	var r_leg_mesh: MeshInstance3D = right_leg.get_node_or_null("LegMesh") as MeshInstance3D
	
	if l_arm_mesh: l_arm_mesh.material_override = secondary_material if weaver else primary_material
	if r_arm_mesh: r_arm_mesh.material_override = secondary_material if weaver else primary_material
	if l_leg_mesh: l_leg_mesh.material_override = secondary_material
	if r_leg_mesh: r_leg_mesh.material_override = secondary_material
	
	var pauldron_l: MeshInstance3D = left_arm.get_node_or_null("PauldronL") as MeshInstance3D
	var pauldron_r: MeshInstance3D = right_arm.get_node_or_null("PauldronR") as MeshInstance3D
	if pauldron_l:
		pauldron_l.visible = not weaver
		pauldron_l.material_override = primary_material
	if pauldron_r:
		pauldron_r.visible = not weaver
		pauldron_r.material_override = primary_material
		
	for arm in [left_arm, right_arm]:
		for child in arm.get_children():
			if child.name.begins_with("Fin"):
				child.visible = not weaver
				child.material_override = primary_material
	
	if cape_mesh:
		cape_mesh.visible = not weaver
		if not weaver:
			cape_mesh.material_override = secondary_material

	if horns_root:
		horns_root.visible = not weaver
		for horn in horns_root.get_children():
			if horn is MeshInstance3D:
				horn.material_override = primary_material

func _physics_process(delta: float) -> void:
	if is_dead:
		_apply_gravity(delta)
		move_and_slide()
		return

	_update_cooldowns(delta)
	
	if is_stunned:
		stun_timer -= delta
		if stun_timer <= 0.0:
			is_stunned = false
			
	if web_slow_timer > 0.0:
		web_slow_timer -= delta
		if web_slow_timer <= 0.0:
			is_web_slowed = false
			
	if emp_disrupt_timer > 0.0:
		emp_disrupt_timer -= delta
		if emp_disrupt_timer <= 0.0:
			is_emp_disrupted = false
			
	_apply_gravity(delta)

	if not is_stunned and not is_emp_disrupted:
		_handle_combat_input()
		_handle_traversal_input()
		_handle_movement_input(delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED * 4.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, SPEED * 4.0 * delta)

	move_and_slide()
	if not is_city_mode:
		_clamp_to_arena_bounds()
	_handle_facing(delta)
	_animate_procedural(delta)
	_update_key_states()

func _update_cooldowns(delta: float) -> void:
	if melee_cooldown_timer > 0.0:
		melee_cooldown_timer = max(0.0, melee_cooldown_timer - delta)
		cooldown_updated.emit("melee", melee_cooldown_timer, CombatScript.MELEE_COOLDOWN)
		
	if projectile_cooldown_timer > 0.0:
		projectile_cooldown_timer = max(0.0, projectile_cooldown_timer - delta)
		cooldown_updated.emit("projectile", projectile_cooldown_timer, CombatScript.PROJECTILE_COOLDOWN)
		
	if special_cooldown_timer > 0.0:
		special_cooldown_timer = max(0.0, special_cooldown_timer - delta)
		cooldown_updated.emit("special", special_cooldown_timer, CombatScript.SPECIAL_COOLDOWN)

	if traversal_cooldown_timer > 0.0:
		traversal_cooldown_timer = max(0.0, traversal_cooldown_timer - delta)
		cooldown_updated.emit("traversal", traversal_cooldown_timer, 1.4)

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		jump_count = 0

func _is_key_just_pressed(k: Key) -> bool:
	var curr: bool = Input.is_physical_key_pressed(k) or Input.is_key_pressed(k)
	var prev: bool = _prev_keys.get(k, false)
	return curr and not prev

func _update_key_states() -> void:
	var keys_to_track := [
		KEY_W, KEY_A, KEY_S, KEY_D, KEY_SPACE, KEY_SHIFT, KEY_F, KEY_G, KEY_H, KEY_R, KEY_E,
		KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_K, KEY_L, KEY_J, KEY_U, KEY_ENTER, KEY_CTRL
	]
	for k in keys_to_track:
		_prev_keys[k] = Input.is_physical_key_pressed(k) or Input.is_key_pressed(k)

func _handle_movement_input(delta: float) -> void:
	var move_vec: Vector2 = Vector2.ZERO
	var is_sprinting: bool = false
	var jump_pressed: bool = false
	
	if player_id == 1:
		if Input.is_action_pressed("p1_move_left") or Input.is_key_pressed(KEY_A):
			move_vec.x -= 1.0
		if Input.is_action_pressed("p1_move_right") or Input.is_key_pressed(KEY_D):
			move_vec.x += 1.0
		if Input.is_action_pressed("p1_move_up") or Input.is_key_pressed(KEY_W):
			move_vec.y -= 1.0
		if Input.is_action_pressed("p1_move_down") or Input.is_key_pressed(KEY_S):
			move_vec.y += 1.0
			
		jump_pressed = Input.is_action_just_pressed("p1_jump") or _is_key_just_pressed(KEY_SPACE)
		is_sprinting = Input.is_key_pressed(KEY_SHIFT) or Input.is_physical_key_pressed(KEY_SHIFT)
	else:
		if Input.is_action_pressed("p2_move_left") or Input.is_key_pressed(KEY_LEFT):
			move_vec.x -= 1.0
		if Input.is_action_pressed("p2_move_right") or Input.is_key_pressed(KEY_RIGHT):
			move_vec.x += 1.0
		if Input.is_action_pressed("p2_move_up") or Input.is_key_pressed(KEY_UP):
			move_vec.y -= 1.0
		if Input.is_action_pressed("p2_move_down") or Input.is_key_pressed(KEY_DOWN):
			move_vec.y += 1.0
			
		jump_pressed = Input.is_action_just_pressed("p2_jump") or _is_key_just_pressed(KEY_SHIFT)
		is_sprinting = Input.is_key_pressed(KEY_CTRL) or Input.is_physical_key_pressed(KEY_CTRL)

	# Jump handling
	if jump_pressed:
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			jump_count = 1
			_spawn_ground_dust()
		elif jump_count < max_jumps and is_city_mode:
			velocity.y = JUMP_VELOCITY * 1.15
			jump_count += 1
			_perform_acrobatic_flip()

	# Movement calculation
	var cur_speed := (SPRINT_SPEED if is_sprinting else SPEED)
	if is_web_slowed:
		cur_speed *= 0.5
		
	move_vec = move_vec.normalized()
	
	if is_city_mode and camera_ref and is_instance_valid(camera_ref):
		var cam_basis: Basis = camera_ref.global_transform.basis
		var fwd := -cam_basis.z; fwd.y = 0.0; fwd = fwd.normalized()
		var rgt := cam_basis.x; rgt.y = 0.0; rgt = rgt.normalized()
		var target_vel := (rgt * move_vec.x - fwd * move_vec.y) * cur_speed
		if move_vec.length_squared() > 0.0:
			velocity.x = move_toward(velocity.x, target_vel.x, cur_speed * 8.0 * delta)
			velocity.z = move_toward(velocity.z, target_vel.z, cur_speed * 8.0 * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, SPEED * 6.0 * delta)
			velocity.z = move_toward(velocity.z, 0.0, SPEED * 6.0 * delta)
	else:
		if move_vec.length_squared() > 0.0:
			velocity.x = move_toward(velocity.x, move_vec.x * cur_speed, cur_speed * 8.0 * delta)
			velocity.z = move_toward(velocity.z, move_vec.y * cur_speed, cur_speed * 8.0 * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, SPEED * 6.0 * delta)
			velocity.z = move_toward(velocity.z, 0.0, SPEED * 6.0 * delta)

func _handle_combat_input() -> void:
	if is_attacking:
		return

	if player_id == 1:
		var punch_pressed: bool = Input.is_action_just_pressed("p1_punch") or _is_key_just_pressed(KEY_F) or (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and is_city_mode)
		var proj_pressed: bool = Input.is_action_just_pressed("p1_projectile") or _is_key_just_pressed(KEY_G)
		var spec_pressed: bool = Input.is_action_just_pressed("p1_special") or _is_key_just_pressed(KEY_H)
		
		if punch_pressed and melee_cooldown_timer <= 0.0:
			perform_melee_punch()
		elif proj_pressed and projectile_cooldown_timer <= 0.0:
			perform_projectile()
		elif spec_pressed and special_cooldown_timer <= 0.0:
			perform_special()
	else:
		var punch_pressed: bool = Input.is_action_just_pressed("p2_punch") or _is_key_just_pressed(KEY_K)
		var proj_pressed: bool = Input.is_action_just_pressed("p2_projectile") or _is_key_just_pressed(KEY_L)
		var spec_pressed: bool = Input.is_action_just_pressed("p2_special") or _is_key_just_pressed(KEY_J)
		
		if punch_pressed and melee_cooldown_timer <= 0.0:
			perform_melee_punch()
		elif proj_pressed and projectile_cooldown_timer <= 0.0:
			perform_projectile()
		elif spec_pressed and special_cooldown_timer <= 0.0:
			perform_special()

func _handle_traversal_input() -> void:
	var trav_pressed: bool = false
	if player_id == 1:
		trav_pressed = _is_key_just_pressed(KEY_R) or (Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and is_city_mode)
	else:
		trav_pressed = _is_key_just_pressed(KEY_U)
		
	if trav_pressed and traversal_cooldown_timer <= 0.0:
		perform_traversal_ability()

func perform_traversal_ability() -> void:
	traversal_cooldown_timer = 1.4
	if is_weaver():
		_perform_web_pull()
	else:
		_perform_grapple_dash()

func _perform_web_pull() -> void:
	var aim_dir := -transform.basis.z + Vector3(0, 0.45, 0)
	if camera_ref and is_instance_valid(camera_ref):
		aim_dir = -camera_ref.global_transform.basis.z + Vector3(0, 0.25, 0)
	aim_dir = aim_dir.normalized()
	
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(global_position + Vector3(0, 1.4, 0), global_position + aim_dir * 42.0)
	query.exclude = [self]
	var result := space_state.intersect_ray(query)
	
	var target_pt: Vector3 = global_position + aim_dir * 28.0 + Vector3(0, 12.0, 0)
	if result:
		target_pt = result.position
		
	# Draw visible web cable
	_draw_tether_beam(target_pt, Color(0.95, 0.98, 1.0))
	
	# Slingshot impulse
	var pull_dir := (target_pt - global_position).normalized()
	velocity = pull_dir * 26.0 + Vector3.UP * 12.0
	traversal_triggered.emit("web_pull", target_pt)

func _perform_grapple_dash() -> void:
	var aim_dir := -transform.basis.z + Vector3(0, 0.45, 0)
	if camera_ref and is_instance_valid(camera_ref):
		aim_dir = -camera_ref.global_transform.basis.z + Vector3(0, 0.25, 0)
	aim_dir = aim_dir.normalized()
	
	var target_pt: Vector3 = global_position + aim_dir * 26.0 + Vector3(0, 10.0, 0)
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(global_position + Vector3(0, 1.4, 0), global_position + aim_dir * 38.0)
	query.exclude = [self]
	var result := space_state.intersect_ray(query)
	if result:
		target_pt = result.position
		
	# Draw grapple steel line
	_draw_tether_beam(target_pt, Color(0.3, 0.75, 1.0))
	
	# Boost impulse
	var pull_dir := (target_pt - global_position).normalized()
	velocity = pull_dir * 24.0 + Vector3.UP * 10.0
	traversal_triggered.emit("grapple", target_pt)

func _draw_tether_beam(target_point: Vector3, color: Color) -> void:
	var line_mesh := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.05
	cyl.bottom_radius = 0.05
	
	var dist := (global_position + Vector3(0, 1.3, 0)).distance_to(target_point)
	cyl.height = dist
	line_mesh.mesh = cyl
	
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color
	line_mesh.material_override = mat
	
	var parent_node := get_parent()
	if parent_node:
		parent_node.add_child(line_mesh)
		var mid := ((global_position + Vector3(0, 1.3, 0)) + target_point) * 0.5
		line_mesh.global_position = mid
		line_mesh.look_at(target_point, Vector3.UP)
		line_mesh.rotate_object_local(Vector3.RIGHT, deg_to_rad(90))
		
		var tw := line_mesh.create_tween()
		tw.tween_interval(0.2)
		tw.tween_property(mat, "albedo_color:a", 0.0, 0.15)
		tw.tween_callback(line_mesh.queue_free)

func _handle_facing(delta: float) -> void:
	if not is_city_mode and opponent and is_instance_valid(opponent) and not opponent.is_dead:
		var target_pos: Vector3 = opponent.global_position
		target_pos.y = global_position.y
		var diff: Vector3 = target_pos - global_position
		if diff.length_squared() > 0.01:
			var target_rot_y: float = atan2(diff.x, diff.z)
			rotation.y = lerp_angle(rotation.y, target_rot_y, 14.0 * delta)
	elif Vector2(velocity.x, velocity.z).length_squared() > 0.4:
		var target_rot_y: float = atan2(-velocity.x, -velocity.z)
		rotation.y = lerp_angle(rotation.y, target_rot_y, 12.0 * delta)

func _animate_procedural(delta: float) -> void:
	var horiz_vel := Vector2(velocity.x, velocity.z).length()
	var moving: bool = horiz_vel > 0.3
	
	if is_attacking:
		return
		
	if not is_on_floor():
		if left_leg: left_leg.rotation.x = deg_to_rad(25.0)
		if right_leg: right_leg.rotation.x = deg_to_rad(-20.0)
		if left_arm: left_arm.rotation.x = deg_to_rad(-50.0)
		if right_arm: right_arm.rotation.x = deg_to_rad(-50.0)
		return
		
	if moving:
		var spd_mult := 12.0 if horiz_vel > 10.0 else 8.5
		var t := Time.get_ticks_msec() / 1000.0 * spd_mult
		var swing := sin(t) * 0.5
		if left_arm: left_arm.rotation.x = -swing
		if right_arm: right_arm.rotation.x = swing
		if left_leg: left_leg.rotation.x = swing
		if right_leg: right_leg.rotation.x = -swing
	else:
		if left_arm: left_arm.rotation.x = move_toward(left_arm.rotation.x, 0.0, delta * 6.0)
		if right_arm: right_arm.rotation.x = move_toward(right_arm.rotation.x, 0.0, delta * 6.0)
		if left_leg: left_leg.rotation.x = move_toward(left_leg.rotation.x, 0.0, delta * 6.0)
		if right_leg: right_leg.rotation.x = move_toward(right_leg.rotation.x, 0.0, delta * 6.0)

func perform_melee_punch() -> void:
	is_attacking = true
	has_hit_in_current_attack = false
	melee_cooldown_timer = CombatScript.MELEE_COOLDOWN
	
	if melee_collision:
		melee_collision.disabled = false
		
	if attack_anim_tween:
		attack_anim_tween.kill()
	attack_anim_tween = create_tween()
	
	var orig_rot: Vector3 = left_arm.rotation
	attack_anim_tween.tween_property(left_arm, "rotation:x", deg_to_rad(-95.0), 0.08)
	attack_anim_tween.tween_callback(_check_melee_overlaps)
	attack_anim_tween.tween_property(left_arm, "rotation", orig_rot, 0.12)
	attack_anim_tween.tween_callback(func():
		if melee_collision:
			melee_collision.disabled = true
		is_attacking = false
	)

func _check_melee_overlaps() -> void:
	if melee_hitbox == null or has_hit_in_current_attack:
		return
	for body in melee_hitbox.get_overlapping_bodies():
		_process_melee_hit(body)

func _on_melee_hitbox_body_entered(body: Node) -> void:
	_process_melee_hit(body)

func _process_melee_hit(body: Node) -> void:
	if body == self or has_hit_in_current_attack:
		return
	if body.has_method("take_damage") and body.has_method("get_player_id"):
		if body.get_player_id() != player_id:
			has_hit_in_current_attack = true
			var knock_dir: Vector3 = CombatScript.calculate_knockback(global_position, body.global_position, CombatScript.MELEE_KNOCKBACK, 4.0)
			body.take_damage(CombatScript.MELEE_DAMAGE, knock_dir, player_id)
			_spawn_hit_spark(body.global_position + Vector3(0, 1.0, 0))
	elif body.has_method("take_damage") and (body is CharacterBody3D or body.is_in_group("hostiles")):
		has_hit_in_current_attack = true
		var knock_dir: Vector3 = (body.global_position - global_position).normalized() + Vector3.UP * 0.25
		body.take_damage(CombatScript.MELEE_DAMAGE, knock_dir * CombatScript.MELEE_KNOCKBACK, player_id)
		_spawn_hit_spark(body.global_position + Vector3(0, 1.0, 0))

func perform_projectile() -> void:
	is_attacking = true
	projectile_cooldown_timer = CombatScript.PROJECTILE_COOLDOWN
	
	if attack_anim_tween:
		attack_anim_tween.kill()
	attack_anim_tween = create_tween()
	
	var orig_rot: Vector3 = right_arm.rotation
	attack_anim_tween.tween_property(right_arm, "rotation:x", deg_to_rad(-110.0), 0.1)
	attack_anim_tween.tween_callback(func():
		var type := "web" if is_weaver() else "shadow"
		_spawn_projectile_entity(type, CombatScript.PROJECTILE_DAMAGE, CombatScript.PROJECTILE_KNOCKBACK, 28.0)
	)
	attack_anim_tween.tween_property(right_arm, "rotation", orig_rot, 0.15)
	attack_anim_tween.tween_callback(func(): is_attacking = false)

func perform_special() -> void:
	is_attacking = true
	special_cooldown_timer = CombatScript.SPECIAL_COOLDOWN
	
	if attack_anim_tween:
		attack_anim_tween.kill()
	attack_anim_tween = create_tween()
	
	attack_anim_tween.tween_property(mesh_root, "position:y", 0.4, 0.15)
	attack_anim_tween.parallel().tween_property(left_arm, "rotation:x", deg_to_rad(-120.0), 0.15)
	attack_anim_tween.parallel().tween_property(right_arm, "rotation:x", deg_to_rad(-120.0), 0.15)
	
	attack_anim_tween.tween_callback(func():
		_spawn_special_burst()
	)
	attack_anim_tween.tween_property(mesh_root, "position:y", 0.0, 0.2)
	attack_anim_tween.parallel().tween_property(left_arm, "rotation:x", 0.0, 0.2)
	attack_anim_tween.parallel().tween_property(right_arm, "rotation:x", 0.0, 0.2)
	attack_anim_tween.tween_callback(func(): is_attacking = false)

func _spawn_projectile_entity(type: String, dmg: float, knock: float, spd: float) -> void:
	var proj_inst: Node = PROJECTILE_SCENE.instantiate()
	var parent_node: Node = get_parent()
	if parent_node:
		parent_node.add_child(proj_inst)
	
	var spawn_pos: Vector3 = projectile_spawn.global_position if projectile_spawn else global_position + Vector3(0, 1.1, 0.95)
	(proj_inst as Node3D).global_position = spawn_pos
	
	var fire_dir: Vector3 = -transform.basis.z
	if is_city_mode and camera_ref and is_instance_valid(camera_ref):
		fire_dir = -camera_ref.global_transform.basis.z
	elif opponent and is_instance_valid(opponent):
		var target: Vector3 = opponent.global_position + Vector3(0, 1.0, 0)
		fire_dir = (target - spawn_pos).normalized()
		
	if proj_inst.has_method("setup"):
		proj_inst.setup(player_id, type, fire_dir, dmg, knock, spd)

func _spawn_special_burst() -> void:
	var type: String = "special_web" if is_weaver() else "special_shadow"
	_spawn_projectile_entity(type, CombatScript.SPECIAL_DAMAGE, CombatScript.SPECIAL_KNOCKBACK, 18.0)
	
	# Radius area burst
	var radius: float = 7.5
	for node in get_tree().get_nodes_in_group("hostiles"):
		var h := node as CharacterBody3D
		if h and is_instance_valid(h) and h.global_position.distance_to(global_position) <= radius:
			var knock := (h.global_position - global_position).normalized() * CombatScript.SPECIAL_KNOCKBACK + Vector3.UP * 4.0
			if h.has_method("take_damage"):
				h.take_damage(CombatScript.SPECIAL_DAMAGE, knock, player_id)
			if is_weaver() and h.has_method("apply_web_restraint"):
				h.apply_web_restraint(3.0)
			elif not is_weaver() and h.has_method("apply_emp_disruption"):
				h.apply_emp_disruption(2.5)

	# Visual shockwave
	var shockwave := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.5
	torus.outer_radius = 1.0
	shockwave.mesh = torus
	
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.2, 0.85, 1.0) if is_weaver() else Color(0.3, 0.7, 1.0)
	shockwave.material_override = mat
	var parent_node := get_parent()
	if parent_node:
		parent_node.add_child(shockwave)
		shockwave.global_position = global_position + Vector3(0, 0.1, 0)
		var sw_tween := shockwave.create_tween()
		sw_tween.tween_property(shockwave, "scale", Vector3(7.5, 1.0, 7.5), 0.38)
		sw_tween.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.38)
		sw_tween.tween_callback(shockwave.queue_free)

func take_damage(amount: float, knockback: Vector3, attacker_id: int) -> void:
	if is_dead:
		return
	if attacker_id == player_id:
		return
		
	health = max(0.0, health - amount)
	velocity += knockback
	health_changed.emit(health, max_health)
	_flash_mesh()
	
	if health <= 0.0:
		_handle_death()
	else:
		is_stunned = true
		stun_timer = 0.25

func apply_web_slow(duration: float, factor: float = 0.5) -> void:
	is_web_slowed = true
	web_slow_timer = duration

func apply_emp_disruption(duration: float) -> void:
	is_emp_disrupted = true
	emp_disrupt_timer = duration

func _flash_mesh() -> void:
	if body_mesh:
		body_mesh.material_override = flash_material
		var tw := create_tween()
		tw.tween_interval(0.1)
		tw.tween_callback(func():
			if body_mesh and is_instance_valid(body_mesh):
				body_mesh.material_override = primary_material
		)

func _handle_death() -> void:
	is_dead = true
	player_defeated.emit(player_id)
	
	var tw := create_tween().set_parallel(true)
	tw.tween_property(mesh_root, "rotation:x", deg_to_rad(-85.0), 0.4).set_trans(Tween.TRANS_BOUNCE)
	tw.tween_property(mesh_root, "position:y", -0.4, 0.4)
	
	if is_city_mode:
		var respawn_tw := create_tween()
		respawn_tw.tween_interval(2.5)
		respawn_tw.tween_callback(func():
			respawn_at(respawn_position)
		)

func respawn_at(pos: Vector3) -> void:
	global_position = pos
	health = max_health
	is_dead = false
	is_stunned = false
	mesh_root.rotation.x = 0.0
	mesh_root.position.y = 0.0
	health_changed.emit(health, max_health)

func _spawn_hit_spark(pos: Vector3) -> void:
	var spark: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(0.3, 0.3, 0.3)
	spark.mesh = box
	
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(1.0, 0.9, 0.3)
	spark.material_override = mat
	
	var parent_node: Node = get_parent()
	if parent_node:
		parent_node.add_child(spark)
		spark.global_position = pos
		var tw: Tween = spark.create_tween()
		tw.tween_property(spark, "scale", Vector3.ZERO, 0.15)
		tw.tween_callback(spark.queue_free)

func _spawn_ground_dust() -> void:
	var dust := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.8
	cyl.bottom_radius = 0.8
	cyl.height = 0.05
	dust.mesh = cyl
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.8, 0.8, 0.8, 0.5)
	dust.material_override = mat
	var parent_node := get_parent()
	if parent_node:
		parent_node.add_child(dust)
		dust.global_position = global_position
		var tw := dust.create_tween()
		tw.tween_property(dust, "scale", Vector3(2.5, 1.0, 2.5), 0.25)
		tw.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.25)
		tw.tween_callback(dust.queue_free)

func _perform_acrobatic_flip() -> void:
	if mesh_root:
		var tw := mesh_root.create_tween()
		tw.tween_property(mesh_root, "rotation:x", deg_to_rad(-360.0), 0.35)
		tw.tween_callback(func(): mesh_root.rotation.x = 0.0)

func _clamp_to_arena_bounds() -> void:
	var bound_limit: float = 14.5
	global_position.x = clamp(global_position.x, -bound_limit, bound_limit)
	global_position.z = clamp(global_position.z, -bound_limit, bound_limit)
