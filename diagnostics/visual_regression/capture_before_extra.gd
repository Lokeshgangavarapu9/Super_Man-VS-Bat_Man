extends SceneTree

var step: int = 0

func _init() -> void:
	print("--- CAPTURING BEFORE CHARACTER SELECTION & FIGHTING ---")

func _process(_delta: float) -> bool:
	step += 1
	if step == 2:
		change_scene_to_file("res://scenes/main_menu.tscn")
	elif step == 4:
		# Open Single Player character selection modal
		if current_scene and current_scene.has_node("SinglePlayerModal"):
			current_scene.get_node("SinglePlayerModal").visible = true
	elif step == 6:
		var img = root.get_texture().get_image()
		if img:
			img.save_png("res://diagnostics/visual_regression/screenshots/before_character_selection.png")
		# Open arena modal
		if current_scene and current_scene.has_node("SinglePlayerModal"):
			current_scene.get_node("SinglePlayerModal").visible = false
		if current_scene and current_scene.has_node("ArenaModal"):
			current_scene.get_node("ArenaModal").visible = true
	elif step == 8:
		var img = root.get_texture().get_image()
		if img:
			img.save_png("res://diagnostics/visual_regression/screenshots/before_fighting_menu.png")
		# Load arena
		var GameConfigScript = load("res://scripts/game_config.gd")
		if GameConfigScript:
			GameConfigScript.mode = GameConfigScript.GameMode.ARENA_CPU
		change_scene_to_file("res://scenes/arena.tscn")
	elif step == 11:
		var img = root.get_texture().get_image()
		if img:
			img.save_png("res://diagnostics/visual_regression/screenshots/before_fighting_gameplay.png")
		return true
	return false
