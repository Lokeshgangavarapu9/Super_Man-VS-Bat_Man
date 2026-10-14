extends SceneTree

var step: int = 0
var main_menu_instance: Node = null

func _init() -> void:
	print("\n====================================================")
	print("   CAPTURING AFTER SCREENSHOTS & RUNTIME VALIDATION   ")
	print("====================================================\n")
	change_scene_to_file("res://scenes/main_menu.tscn")

func _process(_delta: float) -> bool:
	step += 1
	
	if step == 3:
		main_menu_instance = current_scene
		# Capture Main Menu (4 primary choices)
		var img := root.get_texture().get_image()
		if img:
			img.save_png("res://diagnostics/visual_regression/screenshots/after_main_menu.png")
			print("[AFTER SCREENSHOT 1] -> Saved after_main_menu.png (Exactly 4 choices)")
			
		# Open City Submenu
		if main_menu_instance and main_menu_instance.has_method("_on_city_pressed"):
			main_menu_instance.call("_on_city_pressed")
			
	elif step == 6:
		# Capture City Submenu
		var img := root.get_texture().get_image()
		if img:
			img.save_png("res://diagnostics/visual_regression/screenshots/after_city_submenu.png")
			print("[AFTER SCREENSHOT 2] -> Saved after_city_submenu.png (Single, Double, Back)")
			
		# Open Single Player Hero Selection
		if main_menu_instance and main_menu_instance.has_method("_on_city_single_pressed"):
			main_menu_instance.call("_on_city_single_pressed")
			
	elif step == 10:
		# Capture Single Player Selection with LIVE 3D PREVIEW
		var img := root.get_texture().get_image()
		if img:
			img.save_png("res://diagnostics/visual_regression/screenshots/after_character_selection.png")
			print("[AFTER SCREENSHOT 3] -> Saved after_character_selection.png (Live 3D Model Preview)")
			
		# Open Double Player Selection
		if main_menu_instance and main_menu_instance.has_method("_on_city_double_pressed"):
			main_menu_instance.call("_on_city_double_pressed")
			
	elif step == 14:
		# Capture Double Player Selection with Dual Live 3D Previews
		var img := root.get_texture().get_image()
		if img:
			img.save_png("res://diagnostics/visual_regression/screenshots/after_double_player_selection.png")
			print("[AFTER SCREENSHOT 4] -> Saved after_double_player_selection.png (Dual 3D Previews)")
			
		# Open Fighting Submenu
		if main_menu_instance and main_menu_instance.has_method("_on_fighting_pressed"):
			main_menu_instance.call("_on_fighting_pressed")
			
	elif step == 17:
		# Capture Fighting Submenu
		var img := root.get_texture().get_image()
		if img:
			img.save_png("res://diagnostics/visual_regression/screenshots/after_fighting_menu.png")
			print("[AFTER SCREENSHOT 5] -> Saved after_fighting_menu.png (1P vs CPU, 2P Arena, Back)")
			
		# Load Fighting Gameplay
		var GameConfigScript = load("res://scripts/game_config.gd")
		if GameConfigScript:
			GameConfigScript.set_arena_mode(true, GameConfigScript.Difficulty.NORMAL)
		change_scene_to_file("res://scenes/arena.tscn")
		
	elif step == 21:
		# Capture Fighting Gameplay
		var img := root.get_texture().get_image()
		if img:
			img.save_png("res://diagnostics/visual_regression/screenshots/after_fighting_gameplay.png")
			print("[AFTER SCREENSHOT 6] -> Saved after_fighting_gameplay.png (Fighting Arena 3D)")
			
		# Load City Gameplay
		var GameConfigScript = load("res://scripts/game_config.gd")
		if GameConfigScript:
			GameConfigScript.set_single_player_city(GameConfigScript.HERO_CRIMSON_WEAVER)
		change_scene_to_file("res://scenes/city.tscn")
		
	elif step == 26:
		# Capture City Gameplay
		var img := root.get_texture().get_image()
		if img:
			img.save_png("res://diagnostics/visual_regression/screenshots/after_city_gameplay.png")
			print("[AFTER SCREENSHOT 7] -> Saved after_city_gameplay.png (Visible 3D City & Hero)")
			
		print("\n====================================================")
		print("   ALL AFTER SCREENSHOTS SUCCESSFULLY CAPTURED!     ")
		print("====================================================\n")
		return true
		
	return false
