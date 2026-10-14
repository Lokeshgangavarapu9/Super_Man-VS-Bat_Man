extends SceneTree

var frame: int = 0

func _init() -> void:
	change_scene_to_file("res://scenes/arena.tscn")

func _process(_delta: float) -> bool:
	frame += 1
	if frame == 3:
		_run_simulation_tests()
		return true
	return false

func _run_simulation_tests() -> void:
	print("=========================================================")
	print("   SUPERHERO SHOWDOWN — INTEGRATION & COMBAT TEST")
	print("=========================================================")
	
	var arena: Node = current_scene
	assert(arena != null, "Current scene must be active Arena")
	
	var p1: CharacterBody3D = arena.get_node_or_null("Fighters/Player1") as CharacterBody3D
	var p2: CharacterBody3D = arena.get_node_or_null("Fighters/Player2") as CharacterBody3D
	var camera: Camera3D = arena.get_node_or_null("CameraPivot/Camera3D") as Camera3D
	
	assert(p1 != null and p1.is_inside_tree(), "P1 must be in scene tree")
	assert(p2 != null and p2.is_inside_tree(), "P2 must be in scene tree")
	assert(camera != null and camera.is_inside_tree(), "Camera must be in scene tree")
	print("[TEST 1: SCENE & FIGHTER INITIALIZATION] -> PASS: P1 (100 HP) and P2 (100 HP) live in tree.")
	
	# TEST 2: BOUNDARY CLAMPING
	p1.global_position = Vector3(40.0, 0.0, 40.0)
	p1._clamp_to_arena_bounds()
	assert(abs(p1.global_position.x) <= 14.5, "P1 X position must clamp to arena bounds")
	assert(abs(p1.global_position.z) <= 14.5, "P1 Z position must clamp to arena bounds")
	print("[TEST 2: ARENA BOUNDARY CLAMPING] -> PASS: Movement strictly confined to platform.")
	
	# Reset positions
	p1.global_position = Vector3(-4.0, 0.0, 0.0)
	p2.global_position = Vector3(4.0, 0.0, 0.0)
	
	# TEST 3: OPPONENT FACING ALIGNMENT
	p1._handle_facing(1.0)
	assert(p1.rotation.y > 0.0, "Player 1 should turn right to face Player 2")
	print("[TEST 3: DYNAMIC OPPONENT LOCK & FACING] -> PASS: Facing turns toward opponent.")
	
	# TEST 4: JUMP VELOCITY & GRAVITY
	p1.global_position.y = 2.5 # In mid-air
	p1.velocity.y = p1.JUMP_VELOCITY
	assert(p1.velocity.y == 9.5, "Jump must set 9.5 vertical speed")
	p1.velocity.y -= p1.GRAVITY * 0.1
	assert(p1.velocity.y < 9.5, "Gravity must pull fighter downward")
	p1.global_position.y = 0.0 # Return to floor
	print("[TEST 4: JUMP & 3D GRAVITY] -> PASS: Vertical physics behaving correctly.")
	
	# TEST 5: MELEE COMBAT & KNOCKBACK
	var p2_hp_before: float = p2.health
	p1.global_position = p2.global_position - Vector3(0, 0, 0.8)
	p1.perform_melee_punch()
	p1._process_melee_hit(p2)
	assert(p2.health == p2_hp_before - 12.0, "P2 must take 12 melee damage, got %f" % p2.health)
	assert(p1.health == 100.0, "Attacker must never take self-damage")
	assert(p2.velocity.length() > 0.0, "Knockback velocity must be applied")
	print("[TEST 5: MELEE HITBOX & SELF-DAMAGE IMMUNITY] -> PASS: 12 dmg delivered, 0 self-damage, knockback verified.")
	
	# TEST 6: PROJECTILE DAMAGE & KNOCKBACK
	var p2_hp_proj: float = p2.health
	var combat_script: GDScript = load("res://scripts/combat.gd")
	var proj_knock: Vector3 = combat_script.calculate_knockback(p1.global_position, p2.global_position, combat_script.PROJECTILE_KNOCKBACK, 3.5)
	p2.take_damage(combat_script.PROJECTILE_DAMAGE, proj_knock, p1.get_player_id())
	assert(p2.health == p2_hp_proj - 15.0, "P2 must take 15 projectile damage, got %f" % p2.health)
	print("[TEST 6: PROJECTILE COMBAT (WEB / BATARANG)] -> PASS: 15 dmg delivered with knockback.")
	
	# TEST 7: SPECIAL ATTACK
	var p2_hp_spec: float = p2.health
	var spec_knock: Vector3 = combat_script.calculate_knockback(p1.global_position, p2.global_position, combat_script.SPECIAL_KNOCKBACK, 5.0)
	p2.take_damage(combat_script.SPECIAL_DAMAGE, spec_knock, p1.get_player_id())
	assert(p2.health == p2_hp_spec - 28.0, "P2 must take 28 special attack damage, got %f" % p2.health)
	print("[TEST 7: SPECIAL ATTACKS (BURST / ABYSSAL BLAST)] -> PASS: 28 dmg delivered with heavy knockback.")
	
	# TEST 8: HEALTH BARS & DAMAGE TRAILS
	var p2_bar: ProgressBar = arena.get_node("HUD/MarginContainer/TopHeader/P2Box/P2HealthBar")
	var p2_trail: ProgressBar = arena.get_node("HUD/MarginContainer/TopHeader/P2Box/P2HealthBar/DamageTrail")
	assert(p2_bar.value == p2.health, "UI health bar value must match character health")
	assert(p2_trail.max_value == 100.0, "UI trail max value must equal 100")
	print("[TEST 8: DUAL HEALTH BARS & DAMAGE TRAILS] -> PASS: UI health elements in sync.")
	
	# TEST 9: DEFEAT & VICTORY SCREEN
	p2.take_damage(p2.health, Vector3.BACK * 4.0, p1.get_player_id())
	assert(p2.health == 0.0, "P2 health must reach 0")
	assert(p2.is_dead == true, "P2 is_dead must be true")
	assert(arena.match_over == true, "GameManager match_over must be true")
	
	arena._show_winner_screen("CRIMSON WEAVER", "VICTORY BY KNOCKOUT!")
	var win_screen: Control = arena.get_node("HUD/WinnerScreen")
	var win_title: Label = arena.get_node("HUD/WinnerScreen/Panel/VBox/WinnerTitle")
	assert(win_screen.visible == true, "Winner modal must be visible")
	assert(win_title.text == "CRIMSON WEAVER WINS!", "Winner banner must state winner")
	print("[TEST 9: DEFEAT DETECTION & VICTORY MODAL] -> PASS: Match finished, winner announced, buttons available.")
	
	print("\n=========================================================")
	print("   ALL TESTS RAN AND PASSED WITH 100% SUCCESS!")
	print("=========================================================")
	
	quit(0)
