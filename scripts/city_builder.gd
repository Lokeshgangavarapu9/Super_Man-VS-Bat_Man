class_name CityBuilder
extends Node

const VEHICLE_SCENE = preload("res://scenes/vehicle.tscn")
const CITIZEN_SCENE = preload("res://scenes/npc.tscn")
const HOSTILE_SCENE = preload("res://scenes/hostile_npc.tscn")
const TOKEN_SCENE = preload("res://scenes/collectible.tscn")
const MissionManager = preload("res://scripts/mission_manager.gd")

var city_root: Node3D = null
var mission_mgr: MissionManager = null
var time_trial_checkpoints: Array[Node3D] = []

func build_city(parent: Node3D, mission_manager: MissionManager) -> void:
	city_root = parent
	mission_mgr = mission_manager
	
	_build_ground_and_roads()
	_build_waterfront()
	_build_central_plaza()
	_build_buildings()
	_build_checkpoints()
	_spawn_collectibles()
	_spawn_traffic()
	_spawn_npcs()

func _build_ground_and_roads() -> void:
	# Master ground platform
	var ground := StaticBody3D.new()
	ground.name = "Ground"
	ground.collision_layer = 1
	ground.collision_mask = 1 | 2 | 4
	
	var col := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(180, 2, 180)
	col.shape = box_shape
	col.position = Vector3(0, -1, 0)
	ground.add_child(col)
	
	var ground_mesh := MeshInstance3D.new()
	var ground_box := BoxMesh.new()
	ground_box.size = Vector3(180, 2, 180)
	ground_mesh.mesh = ground_box
	ground_mesh.position = Vector3(0, -1, 0)
	
	var ground_mat := StandardMaterial3D.new()
	ground_mat.albedo_color = Color(0.14, 0.16, 0.18) # Dark asphalt/concrete
	ground_mat.roughness = 0.8
	ground_mesh.material_override = ground_mat
	ground.add_child(ground_mesh)
	
	city_root.add_child(ground)
	
	# Road markings (Main Blvd & Avenues)
	_create_road_surface(Vector3(0, 0.02, 40), Vector3(160, 0.02, 14), Color(0.12, 0.13, 0.15)) # Ocean Blvd
	_create_road_surface(Vector3(0, 0.02, -55), Vector3(160, 0.02, 14), Color(0.12, 0.13, 0.15)) # North Ave
	_create_road_surface(Vector3(-35, 0.02, -7), Vector3(12, 0.02, 110), Color(0.12, 0.13, 0.15)) # Ave West
	_create_road_surface(Vector3(35, 0.02, -7), Vector3(12, 0.02, 110), Color(0.12, 0.13, 0.15)) # Ave East

	# Painted centerlines
	_create_road_surface(Vector3(0, 0.03, 40), Vector3(150, 0.02, 0.3), Color(1.0, 0.8, 0.2)) # Yellow divider
	_create_road_surface(Vector3(0, 0.03, -55), Vector3(150, 0.02, 0.3), Color(1.0, 0.8, 0.2))

	# City perimeter collision boundaries to prevent falling into void
	_build_perimeter_boundaries()

func _build_perimeter_boundaries() -> void:
	var bounds := [
		{"pos": Vector3(-90, 6, 0), "size": Vector3(2, 16, 180)},  # West boundary
		{"pos": Vector3(90, 6, 0), "size": Vector3(2, 16, 180)},   # East boundary
		{"pos": Vector3(0, 6, -90), "size": Vector3(180, 16, 2)},  # North boundary
		{"pos": Vector3(0, 6, 92), "size": Vector3(180, 16, 2)},   # South ocean barrier
	]
	for i in range(bounds.size()):
		var b: Dictionary = bounds[i]
		var wall := StaticBody3D.new()
		wall.name = "PerimeterBarrier_%d" % i
		wall.add_to_group("perimeter_barriers")
		wall.collision_layer = 1
		wall.collision_mask = 2 | 4 | 8
		wall.position = b["pos"]
		var col := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = b["size"]
		col.shape = box
		wall.add_child(col)
		city_root.add_child(wall)

func _create_road_surface(pos: Vector3, size: Vector3, color: Color) -> void:
	var mesh_inst := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh_inst.mesh = box
	mesh_inst.position = pos
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.6
	mesh_inst.material_override = mat
	city_root.add_child(mesh_inst)

func _build_waterfront() -> void:
	# Ocean water plane (South district)
	var water_mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(180, 50)
	water_mesh.mesh = plane
	water_mesh.position = Vector3(0, -0.2, 75)
	
	var water_mat := StandardMaterial3D.new()
	water_mat.albedo_color = Color(0.08, 0.35, 0.65, 0.85)
	water_mat.metallic = 0.8
	water_mat.roughness = 0.15
	water_mat.emission_enabled = true
	water_mat.emission = Color(0.05, 0.2, 0.4)
	water_mat.emission_energy_multiplier = 0.8
	water_mesh.material_override = water_mat
	city_root.add_child(water_mesh)
	
	# Sand Beach
	var beach := MeshInstance3D.new()
	var beach_box := BoxMesh.new()
	beach_box.size = Vector3(180, 0.4, 12)
	beach.mesh = beach_box
	beach.position = Vector3(0, 0.05, 52)
	var sand_mat := StandardMaterial3D.new()
	sand_mat.albedo_color = Color(0.85, 0.78, 0.6)
	sand_mat.roughness = 0.95
	beach.material_override = sand_mat
	city_root.add_child(beach)
	
	# Pier Promenade & Boardwalk
	var pier := StaticBody3D.new()
	pier.collision_layer = 1
	var pier_col := CollisionShape3D.new()
	var pier_shape := BoxShape3D.new()
	pier_shape.size = Vector3(16, 1.2, 40)
	pier_col.shape = pier_shape
	pier.add_child(pier_col)
	pier.position = Vector3(0, 0.6, 68)
	
	var pier_mesh := MeshInstance3D.new()
	var pbox := BoxMesh.new()
	pbox.size = Vector3(16, 1.2, 40)
	pier_mesh.mesh = pbox
	var pier_mat := StandardMaterial3D.new()
	pier_mat.albedo_color = Color(0.35, 0.25, 0.18) # Wood timber
	pier_mat.roughness = 0.7
	pier_mesh.material_override = pier_mat
	pier.add_child(pier_mesh)
	city_root.add_child(pier)

func _build_central_plaza() -> void:
	# Plaza paved area (X: -24 to 24, Z: -18 to 18)
	var plaza_mesh := MeshInstance3D.new()
	var pbox := BoxMesh.new()
	pbox.size = Vector3(48, 0.15, 36)
	plaza_mesh.mesh = pbox
	plaza_mesh.position = Vector3(0, 0.08, 0)
	var pmat := StandardMaterial3D.new()
	pmat.albedo_color = Color(0.24, 0.26, 0.3)
	pmat.roughness = 0.5
	plaza_mesh.material_override = pmat
	city_root.add_child(plaza_mesh)
	
	# Central fountain centerpiece
	var fountain := StaticBody3D.new()
	fountain.collision_layer = 1
	var fcol := CollisionShape3D.new()
	var fshape := CylinderShape3D.new()
	fshape.radius = 4.2
	fshape.height = 1.4
	fcol.shape = fshape
	fountain.add_child(fcol)
	fountain.position = Vector3(0, 0.7, 0)
	
	var fmesh := MeshInstance3D.new()
	var fcyl := CylinderMesh.new()
	fcyl.top_radius = 4.2
	fcyl.bottom_radius = 4.2
	fcyl.height = 1.4
	fmesh.mesh = fcyl
	var fmat := StandardMaterial3D.new()
	fmat.albedo_color = Color(0.3, 0.35, 0.42)
	fmesh.material_override = fmat
	fountain.add_child(fmesh)
	
	# Fountain water
	var fwater := MeshInstance3D.new()
	var wcyl := CylinderMesh.new()
	wcyl.top_radius = 3.8
	wcyl.bottom_radius = 3.8
	wcyl.height = 0.3
	fwater.mesh = wcyl
	fwater.position = Vector3(0, 0.6, 0)
	var wmat := StandardMaterial3D.new()
	wmat.albedo_color = Color(0.2, 0.7, 1.0, 0.85)
	wmat.emission_enabled = true
	wmat.emission = Color(0.1, 0.5, 0.8)
	fwater.material_override = wmat
	fountain.add_child(fwater)
	
	city_root.add_child(fountain)
	
	# Plaza Trees & Benches
	var tree_coords := [
		Vector3(-18, 0, -12), Vector3(-18, 0, 12),
		Vector3(18, 0, -12), Vector3(18, 0, 12),
		Vector3(-10, 0, -14), Vector3(10, 0, -14),
		Vector3(-10, 0, 14), Vector3(10, 0, 14)
	]
	for pos in tree_coords:
		_create_tree(pos)
		_create_street_lamp(pos + Vector3(2.5, 0, 0))

func _create_tree(pos: Vector3) -> void:
	var tree := StaticBody3D.new()
	tree.collision_layer = 1
	var tcol := CollisionShape3D.new()
	var tshape := CylinderShape3D.new()
	tshape.radius = 0.5
	tshape.height = 4.0
	tcol.shape = tshape
	tree.add_child(tcol)
	tree.position = pos + Vector3(0, 2.0, 0)
	
	var trunk := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.4
	cyl.bottom_radius = 0.55
	cyl.height = 4.0
	trunk.mesh = cyl
	var tmat := StandardMaterial3D.new()
	tmat.albedo_color = Color(0.3, 0.2, 0.12)
	trunk.material_override = tmat
	tree.add_child(trunk)
	
	var leaves := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 1.8
	sphere.height = 3.0
	leaves.mesh = sphere
	leaves.position = Vector3(0, 2.4, 0)
	var lmat := StandardMaterial3D.new()
	lmat.albedo_color = Color(0.15, 0.55, 0.22)
	lmat.roughness = 0.9
	leaves.material_override = lmat
	tree.add_child(leaves)
	city_root.add_child(tree)

func _create_street_lamp(pos: Vector3) -> void:
	var lamp := StaticBody3D.new()
	lamp.collision_layer = 1
	lamp.position = pos
	
	var col := CollisionShape3D.new()
	var col_shape := CylinderShape3D.new()
	col_shape.radius = 0.25
	col_shape.height = 5.0
	col.shape = col_shape
	col.position = Vector3(0, 2.5, 0)
	lamp.add_child(col)
	
	var pole := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.08
	cyl.bottom_radius = 0.12
	cyl.height = 5.0
	pole.mesh = cyl
	pole.position = Vector3(0, 2.5, 0)
	var pmat := StandardMaterial3D.new()
	pmat.albedo_color = Color(0.2, 0.22, 0.25)
	pmat.metallic = 0.8
	pole.material_override = pmat
	lamp.add_child(pole)
	
	var bulb := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.4, 0.2, 0.4)
	bulb.mesh = box
	bulb.position = Vector3(0, 5.0, 0)
	var bmat := StandardMaterial3D.new()
	bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bmat.albedo_color = Color(1.0, 0.95, 0.75)
	bulb.material_override = bmat
	lamp.add_child(bulb)
	
	var light := OmniLight3D.new()
	light.position = Vector3(0, 4.8, 0)
	light.light_color = Color(1.0, 0.95, 0.8)
	light.light_energy = 2.2
	light.omni_range = 9.0
	lamp.add_child(light)
	
	city_root.add_child(lamp)

func _build_buildings() -> void:
	# 1. Sky-Piercer Landmark Tower (Center-North: X=0, Z=-35, H=48m)
	_create_building(Vector3(0, 24, -35), Vector3(22, 48, 22), Color(0.12, 0.15, 0.22), "SkyPiercerTower")
	# Helipad on Sky-Piercer
	_create_helipad(Vector3(0, 48.05, -35))
	# Antenna on Sky-Piercer (Reaches 58m)
	_create_antenna(Vector3(0, 53, -35), 10.0)

	# 2. East High-Rise District
	_create_building(Vector3(50, 16, -35), Vector3(20, 32, 20), Color(0.15, 0.18, 0.26), "TowerEastNorth")
	_create_building(Vector3(50, 13, 10), Vector3(20, 26, 20), Color(0.18, 0.16, 0.22), "TowerEastMid")
	_create_building(Vector3(50, 6, 30), Vector3(18, 12, 18), Color(0.22, 0.18, 0.15), "ShopsEastSouth")

	# 3. West Commercial & Rooftop District
	_create_building(Vector3(-50, 14, -35), Vector3(20, 28, 20), Color(0.14, 0.17, 0.24), "TowerWestNorth")
	_create_building(Vector3(-50, 12, 10), Vector3(20, 24, 20), Color(0.20, 0.17, 0.20), "TowerWestMid")
	_create_building(Vector3(-50, 5, 30), Vector3(18, 10, 18), Color(0.25, 0.16, 0.14), "ShopsWestSouth")
	
	# 4. North Commercial Strip
	_create_building(Vector3(0, 6, -72), Vector3(36, 12, 14), Color(0.16, 0.19, 0.23), "CommercialNorth")

func _create_building(pos: Vector3, size: Vector3, color: Color, b_name: String) -> void:
	var b := StaticBody3D.new()
	b.name = b_name
	b.collision_layer = 1
	b.collision_mask = 1 | 2 | 4
	b.position = pos
	
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	b.add_child(col)
	
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = 0.5
	mat.roughness = 0.35
	mesh.material_override = mat
	b.add_child(mesh)
	
	# Rooftop Border & AC Units
	var roof_y := size.y * 0.5
	var ac_unit := MeshInstance3D.new()
	var ac_box := BoxMesh.new()
	ac_box.size = Vector3(2.5, 1.4, 2.5)
	ac_unit.mesh = ac_box
	ac_unit.position = Vector3(size.x * 0.25, roof_y + 0.7, size.z * 0.25)
	var ac_mat := StandardMaterial3D.new()
	ac_mat.albedo_color = Color(0.3, 0.32, 0.35)
	ac_unit.material_override = ac_mat
	b.add_child(ac_unit)
	
	# Glowing Traversal Anchor on roof corner (Helps Web-Pull and Grapple)
	_create_traversal_anchor(b, Vector3(-size.x * 0.45, roof_y + 0.4, -size.z * 0.45))
	_create_traversal_anchor(b, Vector3(size.x * 0.45, roof_y + 0.4, size.z * 0.45))
	
	city_root.add_child(b)

func _create_helipad(pos: Vector3) -> void:
	var hpad := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 5.0
	cyl.bottom_radius = 5.0
	cyl.height = 0.08
	hpad.mesh = cyl
	hpad.position = pos
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.85, 0.75, 0.15)
	mat.roughness = 0.5
	hpad.material_override = mat
	city_root.add_child(hpad)

func _create_antenna(pos: Vector3, h: float) -> void:
	var ant := StaticBody3D.new()
	ant.collision_layer = 1
	ant.position = pos
	
	var col := CollisionShape3D.new()
	var col_shape := CylinderShape3D.new()
	col_shape.radius = 0.35
	col_shape.height = h
	col.shape = col_shape
	ant.add_child(col)
	var m := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.12
	cyl.bottom_radius = 0.35
	cyl.height = h
	m.mesh = cyl
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.2, 0.2)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.2, 0.2)
	mat.emission_energy_multiplier = 3.0
	m.material_override = mat
	ant.add_child(m)
	city_root.add_child(ant)

func _create_traversal_anchor(parent: Node3D, local_pos: Vector3) -> void:
	var anchor := Area3D.new()
	anchor.add_to_group("traversal_anchors")
	anchor.position = local_pos
	
	var m := MeshInstance3D.new()
	var sph := SphereMesh.new()
	sph.radius = 0.45
	sph.height = 0.9
	m.mesh = sph
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.2, 0.85, 1.0, 0.85)
	m.material_override = mat
	anchor.add_child(m)
	parent.add_child(anchor)

func _build_checkpoints() -> void:
	time_trial_checkpoints.clear()
	var cp_positions := [
		Vector3(0, 49.5, -35),   # CP 0: Sky-Piercer Helipad
		Vector3(50, 33.5, -35),  # CP 1: Tower East North
		Vector3(50, 27.5, 10),   # CP 2: Tower East Mid
		Vector3(50, 11.5, 30)    # CP 3: Shops East South
	]
	
	for i in range(cp_positions.size()):
		var cp := Area3D.new()
		cp.name = "Checkpoint_%d" % i
		cp.collision_layer = 1
		cp.collision_mask = 2 | 4
		cp.position = cp_positions[i]
		
		var col := CollisionShape3D.new()
		var sph := SphereShape3D.new()
		sph.radius = 3.2
		col.shape = sph
		cp.add_child(col)
		
		var ring := MeshInstance3D.new()
		var torus := TorusMesh.new()
		torus.inner_radius = 2.4
		torus.outer_radius = 3.0
		ring.mesh = torus
		ring.rotate_x(deg_to_rad(90))
		var mat := StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.albedo_color = Color(1.0, 0.85, 0.2)
		ring.material_override = mat
		cp.add_child(ring)
		
		var idx := i
		cp.body_entered.connect(func(body: Node3D):
			if body is CharacterBody3D and (body.is_in_group("players") or body.name.begins_with("Player")):
				if mission_mgr:
					mission_mgr.reach_checkpoint(idx)
		)
		
		cp.visible = false
		time_trial_checkpoints.append(cp)
		city_root.add_child(cp)

func _spawn_collectibles() -> void:
	var token_positions := [
		Vector3(0, 1.8, 76),       # Pier waterfront
		Vector3(-35, 1.2, 52),     # Beach sand
		Vector3(0, 2.6, 0),        # Central fountain
		Vector3(-50, 29.5, -35),   # Tower West North Roof
		Vector3(-50, 11.5, 30),    # Shops West Roof
		Vector3(0, 54.0, -35)      # Top of Sky-Piercer Spire
	]
	
	for i in range(token_positions.size()):
		var token: Node3D = TOKEN_SCENE.instantiate() as Node3D
		if token:
			token.position = token_positions[i]
			token.set("token_id", "token_city_%d" % i)
			city_root.add_child(token)

func _spawn_traffic() -> void:
	var GameConfigScript = load("res://scripts/game_config.gd")
	var density: int = GameConfigScript.traffic_density if GameConfigScript else 2
	if density == 0:
		return
		
	var car_count: int = [0, 4, 8, 12][clamp(density, 0, 3)]
	
	# Road circuit: Main Ocean Blvd -> Ave East -> North Ave -> Ave West -> loop
	var route: Array[Vector3] = [
		Vector3(-60, 0.2, 40),
		Vector3(35, 0.2, 40),
		Vector3(35, 0.2, -55),
		Vector3(-35, 0.2, -55),
		Vector3(-35, 0.2, 40)
	]
	
	var car_colors := [
		Color(0.85, 0.2, 0.2), Color(0.2, 0.5, 0.9), Color(0.9, 0.75, 0.1),
		Color(0.2, 0.2, 0.25), Color(0.9, 0.9, 0.95), Color(0.1, 0.65, 0.35)
	]
	
	for i in range(car_count):
		var car: CharacterBody3D = VEHICLE_SCENE.instantiate() as CharacterBody3D
		if car:
			car.set("vehicle_color", car_colors[i % car_colors.size()])
			city_root.add_child(car)
			var offset_idx: int = int(i * (float(route.size()) / float(max(1, car_count)))) % route.size()
			car.call("set_route", route)
			car.set("current_waypoint_idx", offset_idx)
			car.global_position = route[offset_idx] + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1))

func _spawn_npcs() -> void:
	var GameConfigScript = load("res://scripts/game_config.gd")
	var density: int = GameConfigScript.population_density if GameConfigScript else 1
	var cit_count: int = [6, 12, 20][clamp(density, 0, 2)]
	
	# Sidewalk routes around plaza and waterfront
	var plaza_sidewalk: Array[Vector3] = [
		Vector3(-20, 0.1, -14), Vector3(20, 0.1, -14),
		Vector3(20, 0.1, 14), Vector3(-20, 0.1, 14)
	]
	var pier_sidewalk: Array[Vector3] = [
		Vector3(-6, 1.2, 50), Vector3(-6, 1.2, 80),
		Vector3(6, 1.2, 80), Vector3(6, 1.2, 50)
	]
	
	for i in range(cit_count):
		var cit: CharacterBody3D = CITIZEN_SCENE.instantiate() as CharacterBody3D
		if cit:
			cit.add_to_group("citizens")
			city_root.add_child(cit)
			var route := plaza_sidewalk if (i % 2 == 0) else pier_sidewalk
			cit.call("set_route", route)
			var start_idx := i % route.size()
			cit.global_position = route[start_idx] + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1))

	# Spawn Hostile Gang Operatives in Central Plaza and alleyways (4 initial hostiles)
	var hostile_spots := [
		Vector3(-8, 0.2, -6),
		Vector3(8, 0.2, -6),
		Vector3(-8, 0.2, 6),
		Vector3(8, 0.2, 6)
	]
	for pos in hostile_spots:
		var hostile: CharacterBody3D = HOSTILE_SCENE.instantiate() as CharacterBody3D
		if hostile:
			city_root.add_child(hostile)
			hostile.global_position = pos
			if mission_mgr and hostile.has_signal("hostile_defeated"):
				hostile.hostile_defeated.connect(func(_h):
					mission_mgr.record_hostile_defeated()
				)
