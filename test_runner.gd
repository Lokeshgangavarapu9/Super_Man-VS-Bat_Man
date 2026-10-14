extends SceneTree

func _init() -> void:
	print("--- STARTING GODOT 4 VERIFICATION TEST ---")
	
	var scenes_to_test: Array[String] = [
		"res://scenes/main_menu.tscn",
		"res://scenes/city.tscn",
		"res://scenes/third_person_camera.tscn",
		"res://scenes/vehicle.tscn",
		"res://scenes/npc.tscn",
		"res://scenes/hostile_npc.tscn",
		"res://scenes/collectible.tscn",
		"res://scenes/projectile.tscn",
		"res://scenes/player.tscn",
		"res://scenes/arena.tscn"
	]
	
	for scn_path in scenes_to_test:
		print("Validating scene: %s" % scn_path)
		var scn: PackedScene = load(scn_path)
		if scn == null:
			printerr("FAILED to load scene: %s" % scn_path)
			quit(1)
			return
		var inst: Node = scn.instantiate()
		if inst == null:
			printerr("FAILED to instantiate scene: %s" % scn_path)
			quit(1)
			return
		root.add_child(inst)
		inst.queue_free()
		print("Scene %s parsed and instantiated successfully!" % scn_path)
		
	var scripts_to_test: Array[String] = [
		"res://scripts/combat.gd",
		"res://scripts/game_config.gd",
		"res://scripts/third_person_camera.gd",
		"res://scripts/projectile.gd",
		"res://scripts/player.gd",
		"res://scripts/vehicle.gd",
		"res://scripts/npc.gd",
		"res://scripts/hostile_npc.gd",
		"res://scripts/collectible.gd",
		"res://scripts/city_builder.gd",
		"res://scripts/mission_manager.gd",
		"res://scripts/city_manager.gd",
		"res://scripts/game_manager.gd",
		"res://scripts/main_menu.gd"
	]
	
	for scr_path in scripts_to_test:
		print("Validating script: %s" % scr_path)
		var scr: GDScript = load(scr_path)
		if scr == null:
			printerr("FAILED to load script: %s" % scr_path)
			quit(1)
			return
		print("Script %s compiled successfully!" % scr_path)
		
	print("--- ALL VERIFICATION TESTS PASSED SUCCESSFULLY! ---")
	quit(0)
