class_name GameManager
extends Node3D

@export var match_duration: float = 99.0

# Player references
@onready var player1: CharacterBody3D = $Fighters/Player1
@onready var player2: CharacterBody3D = $Fighters/Player2
@onready var arena_camera: Camera3D = $CameraPivot/Camera3D
@onready var camera_pivot: Node3D = $CameraPivot

# UI references
@onready var p1_health_bar: ProgressBar = $HUD/MarginContainer/TopHeader/P1Box/P1HealthBar
@onready var p1_health_trail: ProgressBar = $HUD/MarginContainer/TopHeader/P1Box/P1HealthBar/DamageTrail
@onready var p1_name_label: Label = $HUD/MarginContainer/TopHeader/P1Box/P1NameLabel
@onready var p1_cd_label: Label = $HUD/MarginContainer/TopHeader/P1Box/P1Cooldowns

@onready var p2_health_bar: ProgressBar = $HUD/MarginContainer/TopHeader/P2Box/P2HealthBar
@onready var p2_health_trail: ProgressBar = $HUD/MarginContainer/TopHeader/P2Box/P2HealthBar/DamageTrail
@onready var p2_name_label: Label = $HUD/MarginContainer/TopHeader/P2Box/P2NameLabel
@onready var p2_cd_label: Label = $HUD/MarginContainer/TopHeader/P2Box/P2Cooldowns

@onready var timer_label: Label = $HUD/MarginContainer/TopHeader/CenterBox/TimerLabel
@onready var banner_label: Label = $HUD/CenterBanner/BannerLabel
@onready var top_pause_button: Button = $HUD/MarginContainer/TopHeader/CenterBox/PauseButton
@onready var p2_controls_label: Label = $HUD/BottomControls/HBoxContainer/P2Controls

@onready var winner_screen: Control = $HUD/WinnerScreen
@onready var winner_title: Label = $HUD/WinnerScreen/Panel/VBox/WinnerTitle
@onready var winner_subtitle: Label = $HUD/WinnerScreen/Panel/VBox/WinnerSubtitle
@onready var restart_button: Button = $HUD/WinnerScreen/Panel/VBox/BtnBox/RestartButton
@onready var menu_button: Button = $HUD/WinnerScreen/Panel/VBox/BtnBox/MenuButton
@onready var exit_button: Button = $HUD/WinnerScreen/Panel/VBox/BtnBox/ExitButton

# Pause Menu
@onready var pause_menu: Control = $HUD/PauseMenu
@onready var pause_panel: Panel = $HUD/PauseMenu/Panel
@onready var pause_mode_info: Label = $HUD/PauseMenu/Panel/VBox/ModeInfo
@onready var pause_resume_btn: Button = $HUD/PauseMenu/Panel/VBox/ResumeButton
@onready var pause_restart_btn: Button = $HUD/PauseMenu/Panel/VBox/RestartButton
@onready var pause_menu_btn: Button = $HUD/PauseMenu/Panel/VBox/MainMenuButton

var round_time_remaining: float = 99.0
var match_over: bool = false
var is_game_paused: bool = false
var camera_shake_intensity: float = 0.0

func _ready() -> void:
	round_time_remaining = match_duration
	if winner_screen:
		winner_screen.visible = false
	if pause_menu:
		pause_menu.visible = false
	
	_setup_game_mode_indicators()
	
	if player1 and player2:
		if player1.has_method("set_opponent"):
			player1.set_opponent(player2)
		if player2.has_method("set_opponent"):
			player2.set_opponent(player1)
		
		if player1.has_signal("health_changed") and not player1.health_changed.is_connected(_on_p1_health_changed):
			player1.health_changed.connect(_on_p1_health_changed)
		if player2.has_signal("health_changed") and not player2.health_changed.is_connected(_on_p2_health_changed):
			player2.health_changed.connect(_on_p2_health_changed)
			
		if player1.has_signal("cooldown_updated") and not player1.cooldown_updated.is_connected(_on_p1_cooldown_updated):
			player1.cooldown_updated.connect(_on_p1_cooldown_updated)
		if player2.has_signal("cooldown_updated") and not player2.cooldown_updated.is_connected(_on_p2_cooldown_updated):
			player2.cooldown_updated.connect(_on_p2_cooldown_updated)
			
		if player1.has_signal("player_defeated") and not player1.player_defeated.is_connected(_on_player_defeated):
			player1.player_defeated.connect(_on_player_defeated)
		if player2.has_signal("player_defeated") and not player2.player_defeated.is_connected(_on_player_defeated):
			player2.player_defeated.connect(_on_player_defeated)

	# Winner buttons
	if restart_button and not restart_button.pressed.is_connected(_on_restart_pressed):
		restart_button.pressed.connect(_on_restart_pressed)
		_setup_button_effects(restart_button)
	if menu_button and not menu_button.pressed.is_connected(_on_menu_pressed):
		menu_button.pressed.connect(_on_menu_pressed)
		_setup_button_effects(menu_button)
	if exit_button and not exit_button.pressed.is_connected(_on_exit_pressed):
		exit_button.pressed.connect(_on_exit_pressed)
		_setup_button_effects(exit_button)
	
	# Pause buttons
	if top_pause_button and not top_pause_button.pressed.is_connected(toggle_pause):
		top_pause_button.pressed.connect(toggle_pause)
		_setup_button_effects(top_pause_button)
	if pause_resume_btn and not pause_resume_btn.pressed.is_connected(_on_pause_resume_pressed):
		pause_resume_btn.pressed.connect(_on_pause_resume_pressed)
		_setup_button_effects(pause_resume_btn)
	if pause_restart_btn and not pause_restart_btn.pressed.is_connected(_on_restart_pressed):
		pause_restart_btn.pressed.connect(_on_restart_pressed)
		_setup_button_effects(pause_restart_btn)
	if pause_menu_btn and not pause_menu_btn.pressed.is_connected(_on_menu_pressed):
		pause_menu_btn.pressed.connect(_on_menu_pressed)
		_setup_button_effects(pause_menu_btn)
	
	_update_p1_ui(100.0, 100.0)
	_update_p2_ui(100.0, 100.0)
	
	# Match trail immediately on initial start
	if p1_health_trail: p1_health_trail.value = 100.0
	if p2_health_trail: p2_health_trail.value = 100.0
	
	_play_round_start_announcement()

func _play_round_start_announcement() -> void:
	if banner_label == null:
		return
	banner_label.visible = true
	banner_label.text = "READY..."
	var tw: Tween = create_tween()
	tw.tween_interval(0.6)
	tw.tween_callback(func():
		if banner_label:
			banner_label.text = "FIGHT!"
	)
	tw.tween_interval(0.8)
	tw.tween_callback(func():
		if banner_label:
			banner_label.visible = false
	)

func _process(delta: float) -> void:
	if not match_over:
		round_time_remaining = max(0.0, round_time_remaining - delta)
		if timer_label:
			timer_label.text = str(int(ceil(round_time_remaining)))
		if round_time_remaining <= 0.0:
			_handle_time_out()

	_update_camera(delta)
	
	if p1_health_trail and p1_health_bar:
		if p1_health_trail.value > p1_health_bar.value:
			p1_health_trail.value = move_toward(p1_health_trail.value, p1_health_bar.value, delta * 30.0)
		elif p1_health_trail.value < p1_health_bar.value:
			p1_health_trail.value = p1_health_bar.value
			
	if p2_health_trail and p2_health_bar:
		if p2_health_trail.value > p2_health_bar.value:
			p2_health_trail.value = move_toward(p2_health_trail.value, p2_health_bar.value, delta * 30.0)
		elif p2_health_trail.value < p2_health_bar.value:
			p2_health_trail.value = p2_health_bar.value

func _update_camera(delta: float) -> void:
	if not player1 or not player2 or not is_instance_valid(player1) or not is_instance_valid(player2):
		return
		
	var pos1: Vector3 = player1.global_position
	var pos2: Vector3 = player2.global_position
	var midpoint: Vector3 = (pos1 + pos2) * 0.5
	var dist: float = pos1.distance_to(pos2)
	
	# Camera pivot follows players center
	camera_pivot.global_position = camera_pivot.global_position.lerp(midpoint + Vector3(0, 1.2, 0), delta * 5.0)
	
	# Scale distance and height dynamically
	var desired_distance: float = clamp(dist * 0.95 + 8.5, 9.0, 22.0)
	var desired_cam_pos: Vector3 = Vector3(0, desired_distance * 0.42 + 1.2, desired_distance)
	arena_camera.position = arena_camera.position.lerp(desired_cam_pos, delta * 4.0)
	
	# Align camera rotation to frame fighters
	var look_target: Vector3 = camera_pivot.global_position + Vector3(0, 0.4, 0)
	arena_camera.look_at(look_target, Vector3.UP)
	
	if camera_shake_intensity > 0.0:
		arena_camera.h_offset = randf_range(-camera_shake_intensity, camera_shake_intensity)
		arena_camera.v_offset = randf_range(-camera_shake_intensity, camera_shake_intensity)
		camera_shake_intensity = move_toward(camera_shake_intensity, 0.0, delta * 2.5)
	else:
		arena_camera.h_offset = 0.0
		arena_camera.v_offset = 0.0

func trigger_camera_shake(amount: float = 0.3) -> void:
	camera_shake_intensity = amount

func _on_p1_health_changed(current: float, maximum: float) -> void:
	_update_p1_ui(current, maximum)
	trigger_camera_shake(0.25)

func _on_p2_health_changed(current: float, maximum: float) -> void:
	_update_p2_ui(current, maximum)
	trigger_camera_shake(0.25)

func _update_p1_ui(current: float, maximum: float) -> void:
	if p1_health_bar:
		p1_health_bar.max_value = maximum
		p1_health_bar.value = current
	if p1_health_trail:
		p1_health_trail.max_value = maximum
	if p1_name_label:
		p1_name_label.text = "P1: CRIMSON WEAVER (%d/100)" % int(current)

func _update_p2_ui(current: float, maximum: float) -> void:
	if p2_health_bar:
		p2_health_bar.max_value = maximum
		p2_health_bar.value = current
	if p2_health_trail:
		p2_health_trail.max_value = maximum
	if p2_name_label:
		p2_name_label.text = "P2: SHADOW KNIGHT (%d/100)" % int(current)

var p1_cooldowns: Dictionary = {"projectile": 0.0, "special": 0.0}
var p2_cooldowns: Dictionary = {"projectile": 0.0, "special": 0.0}

func _on_p1_cooldown_updated(ability: String, remaining: float, _total: float) -> void:
	p1_cooldowns[ability] = remaining
	if p1_cd_label:
		var web_txt: String = "READY" if float(p1_cooldowns["projectile"]) <= 0.0 else "%.1fs" % float(p1_cooldowns["projectile"])
		var spec_txt: String = "READY" if float(p1_cooldowns["special"]) <= 0.0 else "%.1fs" % float(p1_cooldowns["special"])
		p1_cd_label.text = "[F] Punch: READY | [G] Web: %s | [H] Special: %s" % [web_txt, spec_txt]

func _on_p2_cooldown_updated(ability: String, remaining: float, _total: float) -> void:
	p2_cooldowns[ability] = remaining
	if p2_cd_label:
		var bat_txt: String = "READY" if float(p2_cooldowns["projectile"]) <= 0.0 else "%.1fs" % float(p2_cooldowns["projectile"])
		var spec_txt: String = "READY" if float(p2_cooldowns["special"]) <= 0.0 else "%.1fs" % float(p2_cooldowns["special"])
		p2_cd_label.text = "[K] Punch: READY | [L] Batarang: %s | [J] Special: %s" % [bat_txt, spec_txt]

func _on_player_defeated(defeated_id: int) -> void:
	if match_over:
		return
	match_over = true
	trigger_camera_shake(0.6)
	
	if banner_label:
		banner_label.visible = true
		banner_label.text = "K.O.!"
	
	var winner_id: int = 2 if defeated_id == 1 else 1
	var winner_name: String = "SHADOW KNIGHT" if winner_id == 2 else "CRIMSON WEAVER"
	
	if is_inside_tree():
		var tw: Tween = create_tween()
		if tw:
			tw.tween_interval(1.2)
			tw.tween_callback(func():
				if banner_label:
					banner_label.visible = false
				_show_winner_screen(winner_name, "VICTORY BY KNOCKOUT!")
			)

func _handle_time_out() -> void:
	if match_over:
		return
	match_over = true
	if banner_label:
		banner_label.visible = true
		banner_label.text = "TIME'S UP!"
	
	var tw: Tween = create_tween()
	tw.tween_interval(1.2)
	tw.tween_callback(func():
		if banner_label:
			banner_label.visible = false
		var p1_hp: float = player1.get("health") if player1 else 0.0
		var p2_hp: float = player2.get("health") if player2 else 0.0
		if p1_hp > p2_hp:
			_show_winner_screen("CRIMSON WEAVER", "VICTORY BY DECISION (HIGHER HP)")
		elif p2_hp > p1_hp:
			_show_winner_screen("SHADOW KNIGHT", "VICTORY BY DECISION (HIGHER HP)")
		else:
			_show_winner_screen("DRAW", "MUTUAL STALEMATE!")
	)

func _show_winner_screen(winner_text: String, reason: String) -> void:
	if winner_screen == null:
		return
	winner_screen.visible = true
	if winner_text == "DRAW":
		winner_title.text = "DRAW MATCH!"
		winner_title.modulate = Color(1.0, 0.8, 0.2)
	else:
		winner_title.text = "%s WINS!" % winner_text
		if winner_text == "CRIMSON WEAVER":
			winner_title.modulate = Color(0.35, 0.75, 1.0)
		else:
			winner_title.modulate = Color(1.0, 0.85, 0.3)
			
	if winner_subtitle:
		winner_subtitle.text = reason
	if restart_button:
		restart_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_ESCAPE or event.keycode == KEY_P)):
		toggle_pause()

func toggle_pause() -> void:
	if match_over:
		return
	is_game_paused = !is_game_paused
	get_tree().paused = is_game_paused
	if pause_menu:
		pause_menu.visible = is_game_paused
		if is_game_paused and pause_resume_btn:
			pause_resume_btn.grab_focus()

func _on_pause_resume_pressed() -> void:
	if is_game_paused:
		toggle_pause()

func _setup_game_mode_indicators() -> void:
	var is_cpu: bool = GameConfig.is_cpu_active()
	var diff_str: String = GameConfig.get_difficulty_name()
	if pause_mode_info:
		if is_cpu:
			pause_mode_info.text = "MODE: SINGLE PLAYER (CPU - %s)" % diff_str
		else:
			pause_mode_info.text = "MODE: LOCAL MULTIPLAYER (PVP)"
			
	if p2_controls_label:
		if is_cpu:
			p2_controls_label.text = "P2: [CPU OPPONENT - %s DIFFICULTY]" % diff_str
			p2_controls_label.modulate = Color(1.0, 0.75, 0.4, 0.85)
		else:
			p2_controls_label.text = "P2: Arrow Keys Move | R-Shift Jump | K Punch | L Batarang | J Shadow Blast"
			p2_controls_label.modulate = Color(1.0, 0.85, 0.6, 0.8)

func _setup_button_effects(btn: Button) -> void:
	if btn == null:
		return
	btn.pivot_offset = btn.custom_minimum_size * 0.5
	if not btn.mouse_entered.is_connected(_btn_hover.bind(btn)):
		btn.mouse_entered.connect(_btn_hover.bind(btn))
	if not btn.mouse_exited.is_connected(_btn_unhover.bind(btn)):
		btn.mouse_exited.connect(_btn_unhover.bind(btn))

func _btn_hover(btn: Button) -> void:
	var tw := btn.create_tween()
	tw.set_parallel(true)
	tw.tween_property(btn, "scale", Vector2(1.05, 1.05), 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(btn, "modulate", Color(1.15, 1.15, 1.2), 0.12)

func _btn_unhover(btn: Button) -> void:
	var tw := btn.create_tween()
	tw.set_parallel(true)
	tw.tween_property(btn, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(btn, "modulate", Color.WHITE, 0.12)

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	get_tree().paused = false
	var err := get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	if err != OK:
		push_error("Failed to return to main menu from arena: %s" % error_string(err))

func _on_exit_pressed() -> void:
	get_tree().quit()

