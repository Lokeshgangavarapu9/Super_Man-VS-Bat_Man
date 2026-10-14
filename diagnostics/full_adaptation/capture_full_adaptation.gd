extends SceneTree

var step: int = 0
var main_menu_instance: Node = null
var GameConfigScript = preload("res://scripts/game_config.gd")
var PC = preload("res://scripts/physics_config.gd")

func _init() -> void:
	print("\n========================================================")
	print("  FULL ADAPTATION VISUAL VALIDATION & CAPTURE SUITE    ")
	print("========================================================\n")
	DirAccess.make_dir_recursive_absolute("res://diagnostics/full_adaptation/screenshots")
	change_scene_to_file("res://scenes/main_menu.tscn")

func _process(_delta: float) -> bool:
	step += 1
	
	if step == 3:
		main_menu_instance = current_scene
		# 1. Capture Main Menu
		var img := root.get_texture().get_image()
		if img:
			img.save_png("res://diagnostics/full_adaptation/screenshots/1_main_menu.png")
			print("[ADAPTATION TEST 1] Saved 1_main_menu.png")
			
		# Open City Submenu
		if main_menu_instance and main_menu_instance.has_method("_on_city_pressed"):
			main_menu_instance.call("_on_city_pressed")
			
	elif step == 6:
		# 2. Capture City Submenu
		var img := root.get_texture().get_image()
		if img:
			img.save_png("res://diagnostics/full_adaptation/screenshots/2_city_submenu.png")
			print("[ADAPTATION TEST 2] Saved 2_city_submenu.png")
			
		# Open Single Player Hero Selection
		if main_menu_instance and main_menu_instance.has_method("_on_city_single_pressed"):
			main_menu_instance.call("_on_city_single_pressed")
			
	elif step == 10:
		# 3. Capture Single Player Hero Preview
		var img := root.get_texture().get_image()
		if img:
			img.save_png("res://diagnostics/full_adaptation/screenshots/3_single_player_preview.png")
			print("[ADAPTATION TEST 3] Saved 3_single_player_preview.png")
			
		# Open Double Player Hero Selection
		if main_menu_instance and main_menu_instance.has_method("_on_city_double_pressed"):
			main_menu_instance.call("_on_city_double_pressed")
			
	elif step == 14:
		# 4. Capture Double Player Dual Hero Previews
		var img := root.get_texture().get_image()
		if img:
			img.save_png("res://diagnostics/full_adaptation/screenshots/4_double_player_preview.png")
			print("[ADAPTATION TEST 4] Saved 4_double_player_preview.png")
			
		# Open Settings Modal
		if main_menu_instance and main_menu_instance.has_method("_on_settings_pressed"):
			main_menu_instance.call("_on_settings_pressed")
			
	elif step == 17:
		# 5. Capture 5-Tab Settings Modal
		var img := root.get_texture().get_image()
		if img:
			img.save_png("res://diagnostics/full_adaptation/screenshots/5_settings_tabs.png")
			print("[ADAPTATION TEST 5] Saved 5_settings_tabs.png")
			
		# Open Fighting Submenu
		if main_menu_instance and main_menu_instance.has_method("_on_fighting_pressed"):
			main_menu_instance.call("_on_fighting_pressed")
			
	elif step == 20:
		# 6. Capture Fighting Submenu
		var img := root.get_texture().get_image()
		if img:
			img.save_png("res://diagnostics/full_adaptation/screenshots/6_fighting_submenu.png")
			print("[ADAPTATION TEST 6] Saved 6_fighting_submenu.png")
			
		# Launch Fighting Game 1P vs CPU
		GameConfigScript.set_arena_mode(true, GameConfigScript.Difficulty.NORMAL)
		change_scene_to_file("res://scenes/arena.tscn")
		
	elif step == 25:
		# 7. Capture Fighting Arena
		var img := root.get_texture().get_image()
		if img:
			img.save_png("res://diagnostics/full_adaptation/screenshots/7_fighting_arena.png")
			print("[ADAPTATION TEST 7] Saved 7_fighting_arena.png")
			
		# Launch Single Player City
		GameConfigScript.set_single_player_city(GameConfigScript.HERO_CRIMSON_WEAVER)
		change_scene_to_file("res://scenes/city.tscn")
		
	elif step == 32:
		# 8. Capture City Single Player Gameplay
		var img := root.get_texture().get_image()
		if img:
			img.save_png("res://diagnostics/full_adaptation/screenshots/8_city_single_player.png")
			print("[ADAPTATION TEST 8] Saved 8_city_single_player.png")
			
		# Launch Double Player City
		GameConfigScript.set_double_player_city(GameConfigScript.HERO_CRIMSON_WEAVER, GameConfigScript.HERO_SHADOW_KNIGHT)
		change_scene_to_file("res://scenes/city.tscn")
		
	elif step == 38:
		# 9. Capture City Double Player Split Screen
		var img := root.get_texture().get_image()
		if img:
			img.save_png("res://diagnostics/full_adaptation/screenshots/9_city_double_player.png")
			print("[ADAPTATION TEST 9] Saved 9_city_double_player.png")
			
		print("\n========================================================")
		print("  ALL 9 VISUAL VERIFICATION SCREENSHOTS CAPTURED!       ")
		print("========================================================\n")
		return true
		
	return false
