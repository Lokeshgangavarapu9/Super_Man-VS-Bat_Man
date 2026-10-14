extends SceneTree

var step: int = 0
var current_test_node: Node = null

func _init() -> void:
	print("--- DIAGNOSIS: CAPTURING BEFORE STATE ---")

func _process(_delta: float) -> bool:
	step += 1
	if step == 2:
		_capture_main_menu()
	elif step == 5:
		_capture_city_gameplay()
	elif step == 8:
		_capture_fighting_game()
	elif step == 10:
		print("--- DIAGNOSIS: BEFORE STATE CAPTURED ---")
		return true
	return false

func _capture_main_menu() -> void:
	print("Capturing before_main_menu.png...")
	change_scene_to_file("res://scenes/main_menu.tscn")

func _capture_city_gameplay() -> void:
	# Save main menu screenshot
	var img = root.get_texture().get_image()
	if img:
		img.save_png("res://diagnostics/visual_regression/screenshots/before_main_menu.png")
	
	print("Capturing before_city_gameplay.png...")
	var GameConfigScript = load("res://scripts/game_config.gd")
	if GameConfigScript:
		GameConfigScript.mode = GameConfigScript.GameMode.SINGLE_PLAYER_CITY
		GameConfigScript.p1_hero = GameConfigScript.HERO_CRIMSON_WEAVER
	change_scene_to_file("res://scenes/city.tscn")

func _capture_fighting_game() -> void:
	# Save city screenshot
	var img = root.get_texture().get_image()
	if img:
		img.save_png("res://diagnostics/visual_regression/screenshots/before_city_gameplay.png")
		
	print("Capturing before_fighting_game.png...")
	var GameConfigScript = load("res://scripts/game_config.gd")
	if GameConfigScript:
		GameConfigScript.mode = GameConfigScript.GameMode.ARENA_CPU
	change_scene_to_file("res://scenes/arena.tscn")
