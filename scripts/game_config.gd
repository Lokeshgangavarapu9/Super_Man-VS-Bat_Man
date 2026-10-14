class_name GameConfig
extends RefCounted

enum GameMode {
	SINGLE_PLAYER_CITY,     # Open-world City Sandbox (1P)
	DOUBLE_PLAYER_CITY,     # Open-world City Sandbox (2P Co-op / Free Roam)
	ARENA_PVP,              # Rooftop Arena 1v1 Local 2-Player
	ARENA_CPU,              # Rooftop Arena 1v1 vs CPU
	SINGLE_PLAYER,          # Legacy alias
	LOCAL_MULTIPLAYER       # Legacy alias
}

enum Difficulty {
	EASY,
	NORMAL,
	HARD
}

const HERO_CRIMSON_WEAVER: String = "crimson_weaver"
const HERO_SHADOW_KNIGHT: String = "shadow_knight"

# Mode & Difficulty
static var mode: GameMode = GameMode.SINGLE_PLAYER_CITY
static var difficulty: Difficulty = Difficulty.NORMAL

# Selected Heroes
static var p1_hero: String = HERO_CRIMSON_WEAVER
static var p2_hero: String = HERO_SHADOW_KNIGHT

# City Sandbox Settings
static var traffic_density: int = 2       # 0 = Off, 1 = Low, 2 = Medium, 3 = High
static var population_density: int = 2    # 0 = Low, 1 = Medium, 2 = High
static var camera_sensitivity: float = 0.003
static var day_night_cycle: bool = true
static var master_volume: float = 0.8
static var sfx_volume: float = 0.9
static var music_volume: float = 0.7

# Display & Graphics Settings
const RESOLUTIONS: Array[Vector2i] = [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(2560, 1440)]
static var window_mode: int = 0           # 0 = Windowed, 1 = Fullscreen, 2 = Borderless
static var resolution_index: int = 1      # 0 = 720p, 1 = 1080p, 2 = 1440p
static var vsync_enabled: bool = true
static var fps_limit: int = 60            # 0 = Uncapped, 30, 60, 120, 144
static var shadow_quality: int = 2        # 0 = Low, 1 = Medium, 2 = High
static var view_distance: float = 350.0   # meters
static var effects_quality: int = 2       # 0 = Low, 1 = Medium, 2 = High
static var post_processing: bool = true   # Fog & Glow

# Accessibility Settings
static var screen_shake_enabled: bool = true
static var colorblind_filter: int = 0     # 0 = None, 1 = Protanopia, 2 = Deuteranopia, 3 = Tritanopia
static var font_scale: float = 1.0

# Progress / Save Data
const SAVE_PATH: String = "user://superhero_sandbox_save.json"
static var collectibles_found: Array = []
static var missions_completed: Array = []
static var total_tokens: int = 0
static var has_continue_save: bool = false

static func apply_all_settings() -> void:
	apply_display_settings()
	apply_audio_settings()
	apply_graphics_settings()

static func can_control_window() -> bool:
	if DisplayServer.get_name() == "headless":
		return false
	var tree := Engine.get_main_loop() as SceneTree
	if not tree or not tree.root:
		return false
	if tree.root.is_embedded():
		return false
	return true

static func apply_display_settings() -> void:
	if can_control_window():
		match window_mode:
			0:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
				if resolution_index >= 0 and resolution_index < RESOLUTIONS.size():
					DisplayServer.window_set_size(RESOLUTIONS[resolution_index])
			1:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			2:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync_enabled else DisplayServer.VSYNC_DISABLED)
	
	Engine.max_fps = fps_limit

static func apply_audio_settings() -> void:
	var master_idx := AudioServer.get_bus_index("Master")
	if master_idx >= 0:
		AudioServer.set_bus_volume_db(master_idx, linear_to_db(clampf(master_volume, 0.0001, 1.0)))
	var sfx_idx := AudioServer.get_bus_index("SFX")
	if sfx_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(clampf(sfx_volume, 0.0001, 1.0)))
	var music_idx := AudioServer.get_bus_index("Music")
	if music_idx >= 0:
		AudioServer.set_bus_volume_db(music_idx, linear_to_db(clampf(music_volume, 0.0001, 1.0)))

static func apply_graphics_settings() -> void:
	match shadow_quality:
		0: # Low
			RenderingServer.directional_shadow_atlas_set_size(1024, true)
		1: # Medium
			RenderingServer.directional_shadow_atlas_set_size(2048, true)
		2: # High
			RenderingServer.directional_shadow_atlas_set_size(4096, true)


static func set_single_player_city(hero: String = HERO_CRIMSON_WEAVER) -> void:
	mode = GameMode.SINGLE_PLAYER_CITY
	p1_hero = hero

static func set_double_player_city(hero1: String, hero2: String) -> void:
	mode = GameMode.DOUBLE_PLAYER_CITY
	p1_hero = hero1
	p2_hero = hero2

static func set_arena_mode(is_cpu: bool = true, diff: Difficulty = Difficulty.NORMAL) -> void:
	if is_cpu:
		mode = GameMode.ARENA_CPU
		difficulty = diff
	else:
		mode = GameMode.ARENA_PVP

# Legacy compatibility methods
static func set_single_player(diff: Difficulty = Difficulty.NORMAL) -> void:
	mode = GameMode.ARENA_CPU
	difficulty = diff

static func set_multiplayer() -> void:
	mode = GameMode.ARENA_PVP

static func is_cpu_active() -> bool:
	return mode == GameMode.ARENA_CPU or mode == GameMode.SINGLE_PLAYER

static func get_difficulty_name() -> String:
	match difficulty:
		Difficulty.EASY:
			return "EASY"
		Difficulty.NORMAL:
			return "NORMAL"
		Difficulty.HARD:
			return "HARD"
		_:
			return "NORMAL"

static func get_hero_display_name(hero_id: String) -> String:
	match hero_id:
		HERO_CRIMSON_WEAVER:
			return "CRIMSON WEAVER"
		HERO_SHADOW_KNIGHT:
			return "SHADOW KNIGHT"
		_:
			return "UNKNOWN HERO"

static func get_hero_bio(hero_id: String) -> Dictionary:
	match hero_id:
		HERO_CRIMSON_WEAVER:
			return {
				"name": "CRIMSON WEAVER",
				"title": "Acrobatic Coastal Guardian",
				"theme": "Red Web Suit, High Mobility & Web Tethering",
				"traversal": "Web-Pull Slingshot, Rooftop Vaulting & Sprint",
				"attacks": "Acrobatic Strikes, Wrist Web Shooters (Root/Slow), 360 Web Burst",
				"color": Color(0.9, 0.15, 0.18)
			}
		HERO_SHADOW_KNIGHT:
			return {
				"name": "SHADOW KNIGHT",
				"title": "Armored Dark-Tech Vigilante",
				"theme": "Gunmetal Alloy Armor, Tactical Gadgets & Slit Visor",
				"traversal": "Tactical Grapple Cable & Combat Roll / Boost",
				"attacks": "Heavy Armored Punches, Batarang Blades, Shadow EMP Pulse",
				"color": Color(0.2, 0.7, 1.0)
			}
		_:
			return {}

static func save_game() -> void:
	var data: Dictionary = {
		"collectibles": collectibles_found,
		"missions": missions_completed,
		"tokens": total_tokens,
		"p1_hero": p1_hero,
		"p2_hero": p2_hero,
		"traffic": traffic_density,
		"pop": population_density,
		"master_vol": master_volume,
		"sfx_vol": sfx_volume,
		"music_vol": music_volume,
		"window_mode": window_mode,
		"res_idx": resolution_index,
		"vsync": vsync_enabled,
		"fps_limit": fps_limit,
		"shadow_quality": shadow_quality,
		"view_dist": view_distance,
		"effects_quality": effects_quality,
		"post_proc": post_processing,
		"shake_enabled": screen_shake_enabled,
		"colorblind": colorblind_filter,
		"font_scale": font_scale,
		"camera_sens": camera_sensitivity
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		has_continue_save = true

static func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		has_continue_save = false
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	var text := file.get_as_text()
	var test_json = JSON.parse_string(text)
	if test_json is Dictionary:
		collectibles_found = test_json.get("collectibles", [])
		missions_completed = test_json.get("missions", [])
		total_tokens = int(test_json.get("tokens", 0))
		p1_hero = test_json.get("p1_hero", HERO_CRIMSON_WEAVER)
		p2_hero = test_json.get("p2_hero", HERO_SHADOW_KNIGHT)
		traffic_density = int(test_json.get("traffic", 2))
		population_density = int(test_json.get("pop", 2))
		master_volume = float(test_json.get("master_vol", 0.8))
		sfx_volume = float(test_json.get("sfx_vol", 0.9))
		music_volume = float(test_json.get("music_vol", 0.7))
		window_mode = int(test_json.get("window_mode", 0))
		resolution_index = int(test_json.get("res_idx", 1))
		vsync_enabled = bool(test_json.get("vsync", true))
		fps_limit = int(test_json.get("fps_limit", 60))
		shadow_quality = int(test_json.get("shadow_quality", 2))
		view_distance = float(test_json.get("view_dist", 350.0))
		effects_quality = int(test_json.get("effects_quality", 2))
		post_processing = bool(test_json.get("post_proc", true))
		screen_shake_enabled = bool(test_json.get("shake_enabled", true))
		colorblind_filter = int(test_json.get("colorblind", 0))
		font_scale = float(test_json.get("font_scale", 1.0))
		camera_sensitivity = float(test_json.get("camera_sens", 0.003))
		has_continue_save = true
		apply_all_settings()
		return true
	return false
