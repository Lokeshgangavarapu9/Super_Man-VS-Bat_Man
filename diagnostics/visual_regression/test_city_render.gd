extends SceneTree

var step: int = 0

func _init() -> void:
	print("--- TESTING CITY 3D RENDERING ---")
	var GameConfigScript = load("res://scripts/game_config.gd")
	if GameConfigScript:
		GameConfigScript.mode = GameConfigScript.GameMode.SINGLE_PLAYER_CITY
		GameConfigScript.p1_hero = GameConfigScript.HERO_CRIMSON_WEAVER
	change_scene_to_file("res://scenes/city.tscn")

func _process(_delta: float) -> bool:
	step += 1
	if step == 5:
		var img = root.get_texture().get_image()
		if img:
			img.save_png("res://diagnostics/visual_regression/screenshots/after_city_gameplay.png")
			print("Saved after_city_gameplay.png!")
		return true
	return false
