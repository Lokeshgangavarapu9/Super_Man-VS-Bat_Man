class_name CityManager
extends Node3D

const PLAYER_SCENE = preload("res://scenes/player.tscn")
const CAMERA_SCENE = preload("res://scenes/third_person_camera.tscn")
const CityBuilderScript = preload("res://scripts/city_builder.gd")
const MissionManager = preload("res://scripts/mission_manager.gd")
const GameConfigScript = preload("res://scripts/game_config.gd")

# World References
@onready var world_env: WorldEnvironment = $WorldEnvironment
@onready var dir_light: DirectionalLight3D = $DirectionalLight3D
@onready var world_content: Node3D = $WorldContent
@onready var split_screen_container: HBoxContainer = $SplitScreenContainer
@onready var p1_subviewport: SubViewport = $SplitScreenContainer/P1ViewportContainer/SubViewport
@onready var p2_subviewport: SubViewport = $SplitScreenContainer/P2ViewportContainer/SubViewport
@onready var p2_container: SubViewportContainer = $SplitScreenContainer/P2ViewportContainer

# HUD References
@onready var hud: CanvasLayer = $HUD
@onready var p1_hud: Control = $HUD/MarginContainer/TopHeader/P1Box
@onready var p1_name_label: Label = $HUD/MarginContainer/TopHeader/P1Box/P1NameLabel
@onready var p1_health_bar: ProgressBar = $HUD/MarginContainer/TopHeader/P1Box/P1HealthBar
@onready var p1_health_trail: ProgressBar = $HUD/MarginContainer/TopHeader/P1Box/P1HealthBar/DamageTrail
@onready var p1_cooldowns: Label = $HUD/MarginContainer/TopHeader/P1Box/P1Cooldowns

@onready var p2_hud: Control = $HUD/MarginContainer/TopHeader/P2Box
@onready var p2_name_label: Label = $HUD/MarginContainer/TopHeader/P2Box/P2NameLabel
@onready var p2_health_bar: ProgressBar = $HUD/MarginContainer/TopHeader/P2Box/P2HealthBar
@onready var p2_health_trail: ProgressBar = $HUD/MarginContainer/TopHeader/P2Box/P2HealthBar/DamageTrail
@onready var p2_cooldowns: Label = $HUD/MarginContainer/TopHeader/P2Box/P2Cooldowns

@onready var token_counter_label: Label = $HUD/MarginContainer/TopHeader/CenterBox/TokenLabel
@onready var sector_label: Label = $HUD/MarginContainer/TopHeader/CenterBox/SectorLabel

@onready var objective_panel: PanelContainer = $HUD/ObjectiveCard
@onready var objective_title: Label = $HUD/ObjectiveCard/Margin/VBox/ObjectiveTitle
@onready var objective_desc: Label = $HUD/ObjectiveCard/Margin/VBox/ObjectiveDesc
@onready var objective_status: Label = $HUD/ObjectiveCard/Margin/VBox/ObjectiveStatus

@onready var interaction_prompt: Label = $HUD/InteractionPrompt
@onready var banner_label: Label = $HUD/CenterBanner/BannerLabel

@onready var pause_menu: Control = $HUD/PauseMenu
@onready var pause_resume_btn: Button = $HUD/PauseMenu/Panel/VBox/ResumeBtn
@onready var pause_restart_btn: Button = $HUD/PauseMenu/Panel/VBox/RestartBtn
@onready var pause_menu_btn: Button = $HUD/PauseMenu/Panel/VBox/MainMenuBtn

var mission_manager: MissionManager = null
var player1: CharacterBody3D = null
var player2: CharacterBody3D = null
var p1_camera: Node3D = null
var p2_camera: Node3D = null
var city_builder: Node = null

var is_paused: bool = false
var nearby_station: String = ""

func _ready() -> void:
	add_to_group("city_manager")
	
	# Create mission manager
	mission_manager = MissionManager.new()
	mission_manager.name = "MissionManager"
	add_child(mission_manager)
	mission_manager.mission_started.connect(_on_mission_started)
	mission_manager.mission_objective_updated.connect(_on_objective_updated)
	mission_manager.mission_completed.connect(_on_mission_completed)
	mission_manager.mission_failed.connect(_on_mission_failed)
	
	# Build city geometry and spawn citizens/traffic
	city_builder = CityBuilderScript.new()
	city_builder.name = "CityBuilder"
	add_child(city_builder)
	city_builder.build_city(world_content, mission_manager)
	
	# Spawn characters
	_setup_game_mode()
	_setup_hud()
	_setup_pause_menu()
	
	notify_event("WELCOME TO COASTAL CITY SANDBOX!")

func _setup_game_mode() -> void:
	var is_double_player: bool = (GameConfigScript.mode == GameConfigScript.GameMode.DOUBLE_PLAYER_CITY)
	
	# Setup Player 1
	player1 = PLAYER_SCENE.instantiate() as CharacterBody3D
	player1.name = "Player1"
	player1.player_id = 1
	player1.hero_type = GameConfigScript.p1_hero
	player1.position = Vector3(0, 1.2, 10)
	world_content.add_child(player1)
	
	p1_camera = CAMERA_SCENE.instantiate() as Node3D
	p1_camera.set("target", player1)
	
	var cam1 := p1_camera.get_node_or_null("SpringArm3D/Camera3D") as Camera3D
	if cam1:
		cam1.current = true
	player1.enable_city_mode(cam1)
	player1.health_changed.connect(_on_p1_health_changed)
	player1.cooldown_updated.connect(_on_p1_cooldown_updated)

	if is_double_player:
		# Double Player Split-Screen Setup
		split_screen_container.visible = true
		p2_container.visible = true
		
		var w3d: World3D = world_content.get_world_3d()
		if not w3d:
			w3d = get_viewport().world_3d
			
		if p1_subviewport:
			p1_subviewport.world_3d = w3d
			p1_subviewport.add_child(p1_camera)
		else:
			world_content.add_child(p1_camera)
			
		if p2_subviewport:
			p2_subviewport.world_3d = w3d
			
		player2 = PLAYER_SCENE.instantiate() as CharacterBody3D
		player2.name = "Player2"
		player2.player_id = 2
		player2.hero_type = GameConfigScript.p2_hero
		player2.position = Vector3(4.0, 1.2, 10)
		world_content.add_child(player2)
		
		p2_camera = CAMERA_SCENE.instantiate() as Node3D
		p2_camera.set("target", player2)
		if p2_subviewport:
			p2_subviewport.add_child(p2_camera)
		else:
			world_content.add_child(p2_camera)
			
		var cam2 := p2_camera.get_node_or_null("SpringArm3D/Camera3D") as Camera3D
		if cam2:
			cam2.current = true
		player2.enable_city_mode(cam2)
		player2.health_changed.connect(_on_p2_health_changed)
		player2.cooldown_updated.connect(_on_p2_cooldown_updated)
		
		p2_hud.visible = true
		p2_name_label.text = "P2: %s" % GameConfigScript.get_hero_display_name(GameConfigScript.p2_hero)
	else:
		# Single Player: Native main window viewport rendering
		split_screen_container.visible = false
		world_content.add_child(p1_camera)
		p2_container.visible = false
		p2_hud.visible = false
		
	p1_name_label.text = "P1: %s" % GameConfigScript.get_hero_display_name(GameConfigScript.p1_hero)

func _setup_hud() -> void:
	if pause_menu: pause_menu.visible = false
	if interaction_prompt: interaction_prompt.visible = false
	_update_token_display()
	
	if objective_panel:
		objective_panel.visible = true
		objective_title.text = "FREE ROAM"
		objective_desc.text = "Explore the city, test powers, collect tokens, or visit mission stations."
		objective_status.text = "Status: Exploring City District"

func _setup_pause_menu() -> void:
	if pause_resume_btn:
		pause_resume_btn.pressed.connect(toggle_pause)
	if pause_restart_btn:
		pause_restart_btn.pressed.connect(func():
			get_tree().paused = false
			get_tree().reload_current_scene()
		)
	if pause_menu_btn:
		pause_menu_btn.pressed.connect(func():
			get_tree().paused = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			var err := get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
			if err != OK:
				push_error("Failed to return to main menu from city: %s" % error_string(err))
		)

func _process(delta: float) -> void:
	# Update health trail smoothly
	if p1_health_trail and p1_health_bar:
		if p1_health_trail.value > p1_health_bar.value:
			p1_health_trail.value = move_toward(p1_health_trail.value, p1_health_bar.value, delta * 25.0)
		elif p1_health_trail.value < p1_health_bar.value:
			p1_health_trail.value = p1_health_bar.value
			
	if p2_health_trail and p2_health_bar and p2_hud.visible:
		if p2_health_trail.value > p2_health_bar.value:
			p2_health_trail.value = move_toward(p2_health_trail.value, p2_health_bar.value, delta * 25.0)
		elif p2_health_trail.value < p2_health_bar.value:
			p2_health_trail.value = p2_health_bar.value

	_check_mission_stations()

func _check_mission_stations() -> void:
	if not player1 or not is_instance_valid(player1):
		return
		
	var p1_pos: Vector3 = player1.global_position
	
	# Station 1: Plaza Defense Station (X=0, Z=0)
	var plaza_dist := p1_pos.distance_to(Vector3(0, 0, 0))
	# Station 2: Rooftop Time Trial Station on Sky-Piercer Helipad (X=0, Y=48, Z=-35)
	var rooftop_dist := p1_pos.distance_to(Vector3(0, 48.0, -35))
	
	if plaza_dist < 6.0 and mission_manager.active_mission == MissionManager.MissionType.NONE:
		nearby_station = "plaza"
		if interaction_prompt:
			interaction_prompt.visible = true
			interaction_prompt.text = "[E] START PLAZA SECURITY INTERVENTION"
	elif rooftop_dist < 8.0 and mission_manager.active_mission == MissionManager.MissionType.NONE:
		nearby_station = "rooftop"
		if interaction_prompt:
			interaction_prompt.visible = true
			interaction_prompt.text = "[E] START ROOFTOP PARKOUR TIME TRIAL"
	else:
		nearby_station = ""
		if interaction_prompt:
			interaction_prompt.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE):
		toggle_pause()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		_handle_interaction()

func _handle_interaction() -> void:
	if nearby_station == "plaza":
		mission_manager.start_plaza_defense()
		notify_event("MISSION ACTIVE: DEFEAT THE PLAZA GANG OPERATIVES!")
	elif nearby_station == "rooftop":
		mission_manager.start_rooftop_trial(city_builder.time_trial_checkpoints)
		notify_event("MISSION ACTIVE: HIT ALL ROOFTOP BEACONS!")

func toggle_pause() -> void:
	is_paused = !is_paused
	get_tree().paused = is_paused
	if pause_menu:
		pause_menu.visible = is_paused
		if is_paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			if pause_resume_btn: pause_resume_btn.grab_focus()
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_p1_health_changed(curr: float, max_h: float) -> void:
	if p1_health_bar:
		p1_health_bar.max_value = max_h
		p1_health_bar.value = curr
	if p1_health_trail:
		p1_health_trail.max_value = max_h

func _on_p2_health_changed(curr: float, max_h: float) -> void:
	if p2_health_bar:
		p2_health_bar.max_value = max_h
		p2_health_bar.value = curr
	if p2_health_trail:
		p2_health_trail.max_value = max_h

var p1_cds: Dictionary = {"projectile": 0.0, "special": 0.0, "traversal": 0.0}
var p2_cds: Dictionary = {"projectile": 0.0, "special": 0.0, "traversal": 0.0}

func _on_p1_cooldown_updated(ability: String, remaining: float, _total: float) -> void:
	p1_cds[ability] = remaining
	if p1_cooldowns:
		var r_txt := "READY" if p1_cds.get("projectile", 0.0) <= 0.0 else "%.1fs" % p1_cds["projectile"]
		var s_txt := "READY" if p1_cds.get("special", 0.0) <= 0.0 else "%.1fs" % p1_cds["special"]
		var t_txt := "READY" if p1_cds.get("traversal", 0.0) <= 0.0 else "%.1fs" % p1_cds["traversal"]
		p1_cooldowns.text = "[F] Strike | [G] Ranged: %s | [H] Special: %s | [R/RMB] Traversal: %s" % [r_txt, s_txt, t_txt]

func _on_p2_cooldown_updated(ability: String, remaining: float, _total: float) -> void:
	p2_cds[ability] = remaining
	if p2_cooldowns:
		var r_txt := "READY" if p2_cds.get("projectile", 0.0) <= 0.0 else "%.1fs" % p2_cds["projectile"]
		var s_txt := "READY" if p2_cds.get("special", 0.0) <= 0.0 else "%.1fs" % p2_cds["special"]
		var t_txt := "READY" if p2_cds.get("traversal", 0.0) <= 0.0 else "%.1fs" % p2_cds["traversal"]
		p2_cooldowns.text = "[K] Strike | [L] Ranged: %s | [J] Special: %s | [U] Traversal: %s" % [r_txt, s_txt, t_txt]

func _update_token_display() -> void:
	if token_counter_label:
		token_counter_label.text = "TOKENS: %d" % GameConfigScript.total_tokens

func notify_event(msg: String) -> void:
	_update_token_display()
	if banner_label:
		banner_label.visible = true
		banner_label.text = msg
		banner_label.modulate.a = 1.0
		var tw := create_tween()
		tw.tween_interval(2.2)
		tw.tween_property(banner_label, "modulate:a", 0.0, 0.5)
		tw.tween_callback(func(): banner_label.visible = false)

func _on_mission_started(title: String, desc: String) -> void:
	if objective_panel:
		objective_title.text = title
		objective_desc.text = desc
		objective_status.text = "Mission in progress..."

func _on_objective_updated(text: String) -> void:
	if objective_status:
		objective_status.text = text

func _on_mission_completed(title: String, tokens: int) -> void:
	notify_event("★ %s COMPLETED! (+%d TOKENS) ★" % [title, tokens])
	if objective_title: objective_title.text = "FREE ROAM"
	if objective_desc: objective_desc.text = "Sector secured! Explore the city or trigger another challenge."
	if objective_status: objective_status.text = "All objectives fulfilled."

func _on_mission_failed(reason: String) -> void:
	notify_event("MISSION FAILED: %s" % reason)
	if objective_title: objective_title.text = "FREE ROAM"
	if objective_status: objective_status.text = "Mission failed."
