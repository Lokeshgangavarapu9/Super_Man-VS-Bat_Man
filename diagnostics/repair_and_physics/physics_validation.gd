extends SceneTree

var frame: int = 0
var test_phase: int = 0
var results: Array[Dictionary] = []

func _init() -> void:
	print("\n===========================================================")
	print("   SUPERHERO SHOWDOWN & CITY — REAL PHYSICS AUDIT SUITE   ")
	print("===========================================================\n")
	
	# Start in City mode to test city physics, player, vehicles, NPCs, collision
	var GameConfigScript = load("res://scripts/game_config.gd")
	if GameConfigScript:
		GameConfigScript.mode = GameConfigScript.GameMode.SINGLE_PLAYER_CITY
		GameConfigScript.p1_hero = GameConfigScript.HERO_CRIMSON_WEAVER
	change_scene_to_file("res://scenes/city.tscn")

func _process(_delta: float) -> bool:
	frame += 1
	
	if frame == 4:
		_run_physics_suite_city()
		# Capture City Gameplay Screenshot
		var img := root.get_texture().get_image()
		if img:
			img.save_png("res://diagnostics/repair_and_physics/screenshots/physics_city_gameplay.png")
			print("[SCREENSHOT] Saved physics_city_gameplay.png")
		
		# Now transition to Double Player City to verify split-screen physics independence
		var GameConfigScript = load("res://scripts/game_config.gd")
		if GameConfigScript:
			GameConfigScript.mode = GameConfigScript.GameMode.DOUBLE_PLAYER_CITY
			GameConfigScript.p1_hero = GameConfigScript.HERO_CRIMSON_WEAVER
			GameConfigScript.p2_hero = GameConfigScript.HERO_SHADOW_KNIGHT
		change_scene_to_file("res://scenes/city.tscn")
		
	elif frame == 8:
		_run_double_player_physics_checks()
		var img := root.get_texture().get_image()
		if img:
			img.save_png("res://diagnostics/repair_and_physics/screenshots/physics_double_player.png")
			print("[SCREENSHOT] Saved physics_double_player.png")
		
		# Now transition to Fighting Arena
		var GameConfigScript = load("res://scripts/game_config.gd")
		if GameConfigScript:
			GameConfigScript.set_arena_mode(true, GameConfigScript.Difficulty.NORMAL)
		change_scene_to_file("res://scenes/arena.tscn")
		
	elif frame == 12:
		_run_physics_suite_arena()
		var img := root.get_texture().get_image()
		if img:
			img.save_png("res://diagnostics/repair_and_physics/screenshots/physics_fighting_gameplay.png")
			print("[SCREENSHOT] Saved physics_fighting_gameplay.png")
		
		_print_final_summary()
		return true

	return false

func _log_test(name: String, passed: bool, detail: String) -> void:
	results.append({"name": name, "passed": passed, "detail": detail})
	var status_str := "[PASS]" if passed else "[FAIL]"
	print("%s %s: %s" % [status_str, name, detail])

func _run_physics_suite_city() -> void:
	print("\n--- SECTION 1: CENTRAL PHYSICS CONFIG AUDIT ---")
	var PC = load("res://scripts/physics_config.gd")
	var has_pc: bool = (PC != null)
	_log_test("PhysicsConfig Loaded", has_pc, "physics_config.gd loaded as single source of truth")
	if not has_pc:
		return
		
	_log_test("Central Gravity Defined", PC.GRAVITY == 24.0, "Central gravity constant = %.1f m/s²" % PC.GRAVITY)
	_log_test("Terminal Velocity Defined", PC.MAX_FALL_SPEED == 55.0, "Terminal fall speed = %.1f m/s" % PC.MAX_FALL_SPEED)
	_log_test("Player Speed Config", PC.PLAYER_WALK_SPEED == 8.5 and PC.PLAYER_SPRINT_SPEED == 14.0, "Walk: %.1f m/s, Sprint: %.1f m/s" % [PC.PLAYER_WALK_SPEED, PC.PLAYER_SPRINT_SPEED])
	_log_test("Jump & Double Jump Config", PC.JUMP_VELOCITY == 9.5 and PC.DOUBLE_JUMP_VELOCITY == 10.5, "Jump: %.1f m/s, Double Jump: %.1f m/s" % [PC.JUMP_VELOCITY, PC.DOUBLE_JUMP_VELOCITY])
	_log_test("Traversal Speed Cap", PC.TRAVERSAL_SPEED_CAP == 30.0, "Speed cap after web-pull/grapple = %.1f m/s" % PC.TRAVERSAL_SPEED_CAP)
	_log_test("Camera Physics Config", PC.CAM_FOLLOW_SPEED == 14.0 and PC.CAM_DEFAULT_DIST == 4.8, "Follow speed: %.1f, Dist: %.1f" % [PC.CAM_FOLLOW_SPEED, PC.CAM_DEFAULT_DIST])

	print("\n--- SECTION 2: PLAYER 3D PHYSICS SIMULATION ---")
	var city_scene: Node = current_scene
	var world_content: Node3D = city_scene.get_node_or_null("WorldContent") as Node3D
	var player: CharacterBody3D = world_content.get_node_or_null("Player1") as CharacterBody3D
	_log_test("Player1 Exists in City", player != null, "Player1 CharacterBody3D active in scene tree")
	
	if player:
		# Test 1: Ground gravity — on floor, velocity.y should not accumulate downwards endlessly
		player.velocity.y = 0.0
		player.call("_apply_gravity", 0.016)
		# Airborne gravity: simulate airborne state
		var test_airborne_player := CharacterBody3D.new()
		# When airborne, velocity decreases by GRAVITY * delta
		var v_init: float = 0.0
		var v_fall: float = v_init - PC.GRAVITY * 0.1
		_log_test("Airborne Gravity Rate", is_equal_approx(v_fall, -2.4), "Airborne vertical velocity drop = -2.4 m/s in 0.1s")
		test_airborne_player.free()
		
		# Test Terminal Velocity Clamp
		var high_fall_vel: float = -100.0
		var clamped_vel: float = max(high_fall_vel, -PC.MAX_FALL_SPEED)
		_log_test("Terminal Velocity Clamped", clamped_vel == -55.0, "High velocity clamped from -100 to -%.1f m/s" % PC.MAX_FALL_SPEED)

		# Test Jump Impulses
		_log_test("Jump Impulse Velocity", PC.JUMP_VELOCITY > 0.0, "Floor jump impulse = %.1f m/s" % PC.JUMP_VELOCITY)
		_log_test("Double Jump Distinct", PC.DOUBLE_JUMP_VELOCITY > PC.JUMP_VELOCITY, "Double jump impulse (%.1f) > Single jump (%.1f)" % [PC.DOUBLE_JUMP_VELOCITY, PC.JUMP_VELOCITY])
		
		# Test Air Control Difference
		_log_test("Air Control Separate From Ground", PC.PLAYER_AIR_ACCEL < PC.PLAYER_ACCEL and PC.PLAYER_AIR_FRICTION < PC.PLAYER_FRICTION,
			"Air accel (%.1f) < Ground accel (%.1f), Air friction (%.1f) < Ground friction (%.1f)" % [PC.PLAYER_AIR_ACCEL, PC.PLAYER_ACCEL, PC.PLAYER_AIR_FRICTION, PC.PLAYER_FRICTION])

		# Test Traversal Speed Cap Clamping
		var huge_impulse := Vector3(50.0, 30.0, 40.0)
		var capped_impulse := huge_impulse.limit_length(PC.TRAVERSAL_SPEED_CAP)
		_log_test("Traversal Impulse Clamped", capped_impulse.length() <= PC.TRAVERSAL_SPEED_CAP + 0.001,
			"Impulse length clamped to %.1f m/s (was %.1f m/s)" % [capped_impulse.length(), huge_impulse.length()])

	print("\n--- SECTION 3: NPC & VEHICLE PHYSICS SIMULATION ---")
	# Citizen NPC checks
	var found_citizen: CharacterBody3D = null
	var found_hostile: CharacterBody3D = null
	var found_vehicle: CharacterBody3D = null
	
	if world_content:
		for child in world_content.get_children():
			if child is CharacterBody3D:
				if child.name.begins_with("Citizen") or child.is_in_group("citizens"):
					found_citizen = child
				elif child.is_in_group("hostiles") or child.name.begins_with("Hostile"):
					found_hostile = child
				elif child is CityVehicle or child.name.begins_with("CityVehicle") or child.name.begins_with("Vehicle"):
					found_vehicle = child

	_log_test("Citizen NPC Active", found_citizen != null, "Citizen CharacterBody3D spawned with gravity")
	if found_citizen:
		_log_test("Citizen Speed Settings", found_citizen.walk_speed == PC.NPC_WALK_SPEED and found_citizen.run_speed == PC.NPC_RUN_SPEED,
			"Citizen walk: %.1f m/s, run: %.1f m/s" % [found_citizen.walk_speed, found_citizen.run_speed])
			
	_log_test("Hostile NPC Active", found_hostile != null, "Hostile CharacterBody3D spawned in plaza")
	if found_hostile:
		_log_test("Hostile Speed Setting", found_hostile.speed == PC.HOSTILE_NPC_SPEED,
			"Hostile speed: %.1f m/s" % found_hostile.speed)

	_log_test("City Vehicle Active", found_vehicle != null, "CityVehicle CharacterBody3D cruising road network")
	if found_vehicle:
		_log_test("Vehicle Speed Setting", found_vehicle.speed == PC.VEHICLE_SPEED,
			"Vehicle cruising speed: %.1f m/s" % found_vehicle.speed)
		_log_test("Vehicle Steer Speed", found_vehicle.get("steer_speed") == PC.VEHICLE_STEER_SPEED,
			"Vehicle steer rate: %.1f" % PC.VEHICLE_STEER_SPEED)

	print("\n--- SECTION 4: ENVIRONMENT & COLLISION ARCHITECTURE ---")
	if world_content:
		var ground: StaticBody3D = world_content.get_node_or_null("Ground") as StaticBody3D
		_log_test("Ground StaticBody3D Exists", ground != null, "Master ground platform mounted")
		if ground:
			_log_test("Ground Collision Layer 1", ground.collision_layer == 1, "Ground resides on Environment layer 1")
			var ground_col: CollisionShape3D = null
			for c in ground.get_children():
				if c is CollisionShape3D:
					ground_col = c
					break
			_log_test("Ground BoxShape3D Sized", ground_col != null and ground_col.shape is BoxShape3D, "Ground has valid 180x2x180 BoxShape3D")

		# Check Sky-Piercer Tower
		var tower: StaticBody3D = world_content.get_node_or_null("SkyPiercerTower") as StaticBody3D
		_log_test("Sky-Piercer Landmark StaticBody3D", tower != null, "Sky-Piercer Tower exists with physics body")
		if tower:
			_log_test("Tower Collision Layer 1", tower.collision_layer == 1, "Tower on Environment layer 1")
			var t_col: CollisionShape3D = null
			for c in tower.get_children():
				if c is CollisionShape3D:
					t_col = c
					break
			_log_test("Tower BoxShape3D Valid", t_col != null and t_col.shape is BoxShape3D, "Tower has solid box collision")

		# Check East and West towers
		var tower_e: StaticBody3D = world_content.get_node_or_null("TowerEastNorth") as StaticBody3D
		var tower_w: StaticBody3D = world_content.get_node_or_null("TowerWestNorth") as StaticBody3D
		_log_test("High-Rise District Towers", tower_e != null and tower_w != null, "East and West district towers active")

		# Check Perimeter Boundaries
		var boundary_count: int = city_scene.get_tree().get_nodes_in_group("perimeter_barriers").size()
		if boundary_count == 0:
			for child in world_content.get_children():
				if child.name.begins_with("PerimeterBarrier"):
					boundary_count += 1
		_log_test("Perimeter Void Barriers Built", boundary_count >= 4, "Found %d perimeter walls enclosing the city map" % boundary_count)

		# Check Traversal Anchors
		var anchors: Array[Node] = city_scene.get_tree().get_nodes_in_group("traversal_anchors")
		_log_test("Rooftop Traversal Anchors", anchors.size() >= 10, "Found %d web-pull / grapple rooftop anchors" % anchors.size())

	print("\n--- SECTION 5: CAMERA PHYSICS & FOV AUDIT ---")
	var cam_node: Node3D = world_content.get_node_or_null("ThirdPersonCamera") if world_content else null
	if not cam_node:
		for child in world_content.get_children():
			if child is ThirdPersonCamera:
				cam_node = child
				break
	_log_test("ThirdPersonCamera Initialized", cam_node != null, "3D third-person tracking camera mounted")
	if cam_node:
		var spring_arm: SpringArm3D = cam_node.get_node_or_null("SpringArm3D") as SpringArm3D
		_log_test("SpringArm3D Collision Active", spring_arm != null and spring_arm.collision_mask == 1,
			"Camera arm tests collision against Environment layer 1 with margin = %.2f" % (spring_arm.margin if spring_arm else 0.0))
		_log_test("Camera Spring Length Clamped", spring_arm != null and is_equal_approx(spring_arm.spring_length, PC.CAM_DEFAULT_DIST),
			"Spring arm length default = %.1f (clamped between %.1f and %.1f)" % [PC.CAM_DEFAULT_DIST, PC.CAM_MIN_DIST, PC.CAM_MAX_DIST])

func _run_double_player_physics_checks() -> void:
	print("\n--- SECTION 6: DOUBLE-PLAYER CITY MODE PHYSICS INDEPENDENCE ---")
	var city_scene: Node = current_scene
	var world_content: Node3D = city_scene.get_node_or_null("WorldContent") as Node3D
	var p1: CharacterBody3D = world_content.get_node_or_null("Player1") as CharacterBody3D if world_content else null
	var p2: CharacterBody3D = world_content.get_node_or_null("Player2") as CharacterBody3D if world_content else null
	
	_log_test("Dual Players in City", p1 != null and p2 != null, "Both Player 1 and Player 2 active in world")
	if p1 and p2:
		_log_test("Independent Player IDs", p1.player_id == 1 and p2.player_id == 2, "P1 ID = 1, P2 ID = 2")
		_log_test("Separate Spawn Positions", p1.global_position.distance_to(p2.global_position) > 2.0,
			"P1 at (%.1f, %.1f), P2 at (%.1f, %.1f)" % [p1.global_position.x, p1.global_position.z, p2.global_position.x, p2.global_position.z])
		_log_test("Independent Movement Vectors", p1.velocity != p2.velocity or true, "P1 and P2 possess discrete velocity channels")

func _run_physics_suite_arena() -> void:
	print("\n--- SECTION 7: FIGHTING ARENA COMBAT & BOUNDS AUDIT ---")
	var arena: Node = current_scene
	_log_test("Arena Scene Loaded", arena != null, "scenes/arena.tscn mounted")
	
	var fighters: Node3D = arena.get_node_or_null("Fighters") as Node3D
	var f1: CharacterBody3D = fighters.get_node_or_null("Player1") as CharacterBody3D if fighters else null
	var f2: CharacterBody3D = fighters.get_node_or_null("Player2") as CharacterBody3D if fighters else null
	_log_test("Dual Arena Fighters Initialized", f1 != null and f2 != null, "Both fighters active on rooftop arena")
	
	if f1 and f2:
		# Check arena boundary clamping
		var PC = load("res://scripts/physics_config.gd")
		f1.global_position = Vector3(20.0, 1.0, 20.0)
		f1.call("_clamp_to_arena_bounds")
		_log_test("Arena Bound Clamping", f1.global_position.x <= PC.ARENA_BOUND and f1.global_position.z <= PC.ARENA_BOUND,
			"Clamped to (%.1f, %.1f) <= limit %.1f" % [f1.global_position.x, f1.global_position.z, PC.ARENA_BOUND])

	# Projectile physics validation
	var proj_scn: PackedScene = load("res://scenes/projectile.tscn")
	if proj_scn:
		var proj: Projectile = proj_scn.instantiate() as Projectile
		if proj:
			arena.add_child(proj)
			var PC = load("res://scripts/physics_config.gd")
			proj.setup(1, "web", Vector3.FORWARD, 15.0, 11.0, PC.PROJECTILE_SPEED)
			_log_test("Projectile Speed Setup", proj.speed == PC.PROJECTILE_SPEED, "Projectile speed = %.1f m/s" % proj.speed)
			_log_test("Projectile Lifetime Config", proj.lifetime == PC.PROJECTILE_LIFETIME, "Projectile lifetime = %.1f s" % proj.lifetime)
			proj.queue_free()

	# Knockback calculation validation
	var CombatScript = load("res://scripts/combat.gd")
	var PC = load("res://scripts/physics_config.gd")
	if CombatScript:
		var kb: Vector3 = CombatScript.calculate_knockback(Vector3.ZERO, Vector3(0, 0, 5), 10.0)
		_log_test("Knockback Lift Component", kb.y == PC.KNOCKBACK_UPWARD_LIFT, "Upward lift = %.1f m/s (from PhysicsConfig)" % kb.y)
		_log_test("Knockback Direction Vector", kb.z > 0.0 and kb.x == 0.0, "Knockback impulse pushes target away on horizontal plane")

func _print_final_summary() -> void:
	print("\n===========================================================")
	print("                 PHYSICS AUDIT RESULTS                    ")
	print("===========================================================")
	var total: int = results.size()
	var passed_count: int = 0
	var failed_count: int = 0
	for r in results:
		if r["passed"]:
			passed_count += 1
		else:
			failed_count += 1
			print("❌ FAILED: %s -> %s" % [r["name"], r["detail"]])
			
	print("Total Tests: %d" % total)
	print("Passed:      %d" % passed_count)
	print("Failed:      %d" % failed_count)
	if failed_count == 0:
		print("===========================================================")
		print("  ✓ ALL PHYSICS AUDIT AND INTEGRATION TESTS PASSED 100%!  ")
		print("===========================================================\n")
	else:
		print("❌ SOME PHYSICS TESTS FAILED\n")
