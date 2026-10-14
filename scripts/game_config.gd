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

# Progress / Save Data
const SAVE_PATH: String = "user://superhero_sandbox_save.json"
static var collectibles_found: Array = []
static var missions_completed: Array = []
static var total_tokens: int = 0
static var has_continue_save: bool = false

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
		"pop": population_density
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
		has_continue_save = true
		return true
	return false
