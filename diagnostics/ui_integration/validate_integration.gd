extends SceneTree

## Final validation: parse all scenes + new files to confirm no errors
func _init() -> void:
	print("\n=================================================")
	print("   FINAL UI INTEGRATION VALIDATION TEST")
	print("=================================================\n")

	var all_scenes := [
		"res://scenes/main_menu.tscn",
		"res://scenes/city.tscn",
		"res://scenes/arena.tscn",
		"res://scenes/player.tscn",
		"res://scenes/character_preview.tscn",
		"res://scenes/pause_menu.tscn",
		"res://scenes/npc.tscn",
		"res://scenes/hostile_npc.tscn",
		"res://scenes/vehicle.tscn",
		"res://scenes/projectile.tscn",
		"res://scenes/collectible.tscn",
		"res://scenes/third_person_camera.tscn",
	]

	var all_scripts := [
		"res://scripts/main_menu.gd",
		"res://scripts/pause_menu.gd",
		"res://scripts/character_preview.gd",
		"res://scripts/city_manager.gd",
		"res://scripts/city_builder.gd",
		"res://scripts/player.gd",
		"res://scripts/game_config.gd",
		"res://scripts/game_manager.gd",
		"res://scripts/combat.gd",
		"res://scripts/npc.gd",
		"res://scripts/hostile_npc.gd",
		"res://scripts/vehicle.gd",
		"res://scripts/projectile.gd",
		"res://scripts/collectible.gd",
		"res://scripts/mission_manager.gd",
		"res://scripts/third_person_camera.gd",
	]

	var pass_count := 0
	var fail_count := 0

	print("--- Scene Validation ---")
	for path in all_scenes:
		if ResourceLoader.exists(path):
			var res = load(path)
			if res != null:
				print("[PASS] " + path.get_file())
				pass_count += 1
			else:
				print("[FAIL] " + path.get_file() + " — load() returned null")
				fail_count += 1
		else:
			print("[FAIL] " + path.get_file() + " — file not found")
			fail_count += 1

	print("\n--- Script Validation ---")
	for path in all_scripts:
		if ResourceLoader.exists(path):
			var res = load(path)
			if res != null:
				print("[PASS] " + path.get_file())
				pass_count += 1
			else:
				print("[FAIL] " + path.get_file() + " — load() returned null")
				fail_count += 1
		else:
			print("[FAIL] " + path.get_file() + " — file not found")
			fail_count += 1

	print("\n--- File Existence Checks ---")
	var extra_files := [
		"res://THIRD_PARTY_NOTICES.md",
		"res://diagnostics/ui_integration/before_after.md",
		"res://diagnostics/ui_integration/files_imported.md",
		"res://diagnostics/ui_integration/runtime_errors.log",
		"res://diagnostics/visual_regression/README.md",
		"res://diagnostics/visual_regression/screenshots/after_main_menu.png",
		"res://diagnostics/visual_regression/screenshots/after_city_gameplay.png",
		"res://diagnostics/visual_regression/screenshots/after_character_selection.png",
		"res://diagnostics/visual_regression/screenshots/after_fighting_gameplay.png",
	]
	for path in extra_files:
		if FileAccess.file_exists(ProjectSettings.globalize_path(path)):
			print("[PASS] " + path.get_file() + " exists")
			pass_count += 1
		else:
			print("[FAIL] " + path.get_file() + " NOT FOUND")
			fail_count += 1

	print("\n=================================================")
	print("  RESULTS: %d PASSED | %d FAILED" % [pass_count, fail_count])
	if fail_count == 0:
		print("  ✓ ALL CHECKS PASSED")
	else:
		print("  ✗ %d CHECKS FAILED — review above" % fail_count)
	print("=================================================\n")
	quit()
