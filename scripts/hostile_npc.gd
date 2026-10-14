class_name HostileNPC
extends CharacterBody3D

signal hostile_defeated(hostile: HostileNPC)

enum State {
	PATROL,
	ALERT_CHASE,
	ATTACK,
	STUNNED,
	DEFEATED
}

@export var max_health: float = 40.0
@export var speed: float = 4.2
@export var attack_damage: float = 8.0
@export var detection_radius: float = 14.0
@export var attack_radius: float = 1.8

@onready var mesh_root: Node3D = $MeshRoot
@onready var body_mesh: MeshInstance3D = $MeshRoot/Torso
@onready var head_mesh: MeshInstance3D = $MeshRoot/Head
@onready var left_arm: Node3D = $MeshRoot/LeftArm
@onready var right_arm: Node3D = $MeshRoot/RightArm
@onready var left_leg: Node3D = $MeshRoot/LeftLeg
@onready var right_leg: Node3D = $MeshRoot/RightLeg
@onready var web_restraint_mesh: MeshInstance3D = $MeshRoot/WebRestraint
@onready var emp_sparks: Node3D = $MeshRoot/EmpSparks

var health: float = 40.0
var current_state: State = State.PATROL
var patrol_center: Vector3 = Vector3.ZERO
var patrol_target: Vector3 = Vector3.ZERO
var target_player: CharacterBody3D = null
var attack_cooldown: float = 0.0
var walk_cycle: float = 0.0
var stun_timer: float = 0.0
var web_slow_timer: float = 0.0
var is_dead: bool = false

func _ready() -> void:
	health = max_health
	patrol_center = global_position
	_pick_new_patrol_point()
	
	if web_restraint_mesh:
		web_restraint_mesh.visible = false
	if emp_sparks:
		emp_sparks.visible = false
		
	# Dark syndicate punk styling
	if body_mesh:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.2, 0.08, 0.1) # Dark Syndicate Red/Black
		mat.roughness = 0.5
		body_mesh.material_override = mat

func _pick_new_patrol_point() -> void:
	var offset := Vector3(randf_range(-8.0, 8.0), 0, randf_range(-8.0, 8.0))
	patrol_target = patrol_center + offset

func take_damage(amount: float, knockback: Vector3 = Vector3.ZERO, _source_id: int = 0) -> void:
	if is_dead:
		return
		
	health = max(0.0, health - amount)
	velocity += knockback
	
	# Flash red
	_flash_hit()
	
	if health <= 0.0:
		_die()
	else:
		current_state = State.STUNNED
		stun_timer = 0.35

func apply_web_restraint(duration: float = 2.0) -> void:
	if is_dead: return
	web_slow_timer = duration
	if web_restraint_mesh:
		web_restraint_mesh.visible = true
	# Inform nearby citizens to flee
	_notify_nearby_danger()

func apply_emp_disruption(duration: float = 1.8) -> void:
	if is_dead: return
	current_state = State.STUNNED
	stun_timer = duration
	if emp_sparks:
		emp_sparks.visible = true
	var tw := create_tween()
	tw.tween_interval(duration)
	tw.tween_callback(func():
		if emp_sparks and is_instance_valid(emp_sparks):
			emp_sparks.visible = false
	)
	_notify_nearby_danger()

func _flash_hit() -> void:
	if body_mesh:
		var orig_mat: Material = body_mesh.material_override
		var flash_mat := StandardMaterial3D.new()
		flash_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		flash_mat.albedo_color = Color.WHITE
		body_mesh.material_override = flash_mat
		var tw := create_tween()
		tw.tween_interval(0.1)
		tw.tween_callback(func():
			if body_mesh and is_instance_valid(body_mesh):
				body_mesh.material_override = orig_mat
		)

func _die() -> void:
	is_dead = true
	current_state = State.DEFEATED
	hostile_defeated.emit(self)
	
	# Spawn collectible reward
	_spawn_token_reward()
	
	# Collapse defeat animation
	var tw := create_tween().set_parallel(true)
	tw.tween_property(mesh_root, "rotation:x", deg_to_rad(-85.0), 0.35).set_trans(Tween.TRANS_BOUNCE)
	tw.tween_property(mesh_root, "position:y", -0.4, 0.35)
	
	# Fade out after 4 seconds
	var fade_tw := create_tween()
	fade_tw.tween_interval(3.5)
	fade_tw.tween_property(self, "modulate:a", 0.0, 0.8)
	fade_tw.tween_callback(queue_free)

func _spawn_token_reward() -> void:
	var token_scn: PackedScene = load("res://scenes/collectible.tscn")
	if token_scn:
		var token: Node3D = token_scn.instantiate() as Node3D
		if token:
			get_parent().add_child(token)
			token.global_position = global_position + Vector3(0, 0.8, 0)

func _notify_nearby_danger() -> void:
	for node in get_tree().get_nodes_in_group("citizens"):
		var citizen: CharacterBody3D = node as CharacterBody3D
		if citizen and is_instance_valid(citizen):
			if citizen.global_position.distance_to(global_position) < 18.0:
				if citizen.has_method("trigger_panic"):
					citizen.call("trigger_panic", global_position)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 22.0 * delta
		
	if is_dead:
		velocity.x = move_toward(velocity.x, 0.0, delta * 6.0)
		velocity.z = move_toward(velocity.z, 0.0, delta * 6.0)
		move_and_slide()
		return
		
	if attack_cooldown > 0.0:
		attack_cooldown = max(0.0, attack_cooldown - delta)
		
	if web_slow_timer > 0.0:
		web_slow_timer -= delta
		if web_slow_timer <= 0.0 and web_restraint_mesh:
			web_restraint_mesh.visible = false
			
	if stun_timer > 0.0:
		stun_timer -= delta
		velocity.x = move_toward(velocity.x, 0.0, delta * 8.0)
		velocity.z = move_toward(velocity.z, 0.0, delta * 8.0)
		move_and_slide()
		return
		
	_find_nearest_player()
	
	match current_state:
		State.PATROL:
			_process_patrol(delta)
		State.ALERT_CHASE:
			_process_chase(delta)
		State.ATTACK:
			_process_attack(delta)
			
	move_and_slide()
	_animate_limbs(delta)

func _find_nearest_player() -> void:
	var closest_dist := detection_radius
	target_player = null
	for node in get_tree().get_nodes_in_group("players"):
		var p: CharacterBody3D = node as CharacterBody3D
		if p and is_instance_valid(p) and not p.get("is_dead"):
			var d := global_position.distance_to(p.global_position)
			if d < closest_dist:
				closest_dist = d
				target_player = p

func _process_patrol(delta: float) -> void:
	if target_player:
		current_state = State.ALERT_CHASE
		_notify_nearby_danger()
		return
		
	var dist := global_position.distance_to(patrol_target)
	if dist < 1.5:
		_pick_new_patrol_point()
		
	var dir := (patrol_target - global_position).normalized()
	dir.y = 0.0
	if dir.length_squared() > 0.001:
		var target_rot := atan2(-dir.x, -dir.z)
		rotation.y = lerp_angle(rotation.y, target_rot, delta * 4.0)
		velocity.x = dir.x * (speed * 0.5)
		velocity.z = dir.z * (speed * 0.5)

func _process_chase(delta: float) -> void:
	if not target_player or not is_instance_valid(target_player) or target_player.get("is_dead"):
		current_state = State.PATROL
		return
		
	var dist := global_position.distance_to(target_player.global_position)
	if dist > detection_radius * 1.5:
		current_state = State.PATROL
		return
		
	if dist <= attack_radius:
		current_state = State.ATTACK
		return
		
	var dir := (target_player.global_position - global_position).normalized()
	dir.y = 0.0
	var target_rot := atan2(-dir.x, -dir.z)
	rotation.y = lerp_angle(rotation.y, target_rot, delta * 8.0)
	
	var cur_speed := speed * (0.35 if web_slow_timer > 0.0 else 1.0)
	velocity.x = dir.x * cur_speed
	velocity.z = dir.z * cur_speed

func _process_attack(delta: float) -> void:
	if not target_player or not is_instance_valid(target_player):
		current_state = State.PATROL
		return
		
	var dist := global_position.distance_to(target_player.global_position)
	if dist > attack_radius * 1.3:
		current_state = State.ALERT_CHASE
		return
		
	velocity.x = move_toward(velocity.x, 0.0, delta * 8.0)
	velocity.z = move_toward(velocity.z, 0.0, delta * 8.0)
	
	# Face player
	var dir := (target_player.global_position - global_position).normalized()
	rotation.y = atan2(-dir.x, -dir.z)
	
	if attack_cooldown <= 0.0:
		attack_cooldown = 1.4
		_perform_hostile_punch()

func _perform_hostile_punch() -> void:
	if right_arm:
		var tw := right_arm.create_tween()
		tw.tween_property(right_arm, "rotation:x", deg_to_rad(-85.0), 0.12)
		tw.tween_property(right_arm, "rotation:x", 0.0, 0.18)
		
	if target_player and is_instance_valid(target_player) and not target_player.get("is_dead"):
		var knock_dir := (target_player.global_position - global_position).normalized() + Vector3.UP * 0.2
		if target_player.has_method("take_damage"):
			target_player.take_damage(attack_damage, knock_dir * 5.0, 99)

func _animate_limbs(delta: float) -> void:
	var horiz_vel := Vector2(velocity.x, velocity.z).length()
	if horiz_vel > 0.4:
		walk_cycle += delta * 7.0
		var swing := sin(walk_cycle) * 0.45
		if left_arm: left_arm.rotation.x = -swing
		if right_arm and attack_cooldown <= 0.8: right_arm.rotation.x = swing
		if left_leg: left_leg.rotation.x = swing
		if right_leg: right_leg.rotation.x = -swing
	else:
		if left_arm: left_arm.rotation.x = move_toward(left_arm.rotation.x, 0.0, delta * 4.0)
		if right_arm and attack_cooldown <= 0.8: right_arm.rotation.x = move_toward(right_arm.rotation.x, 0.0, delta * 4.0)
		if left_leg: left_leg.rotation.x = move_toward(left_leg.rotation.x, 0.0, delta * 4.0)
		if right_leg: right_leg.rotation.x = move_toward(right_leg.rotation.x, 0.0, delta * 4.0)
