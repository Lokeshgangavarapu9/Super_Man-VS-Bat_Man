class_name MainMenu
extends Control

const GameConfigScript = preload("res://scripts/game_config.gd")

# Primary 4 Buttons
@onready var primary_menu: VBoxContainer = $PrimaryMenu
@onready var city_btn: Button = $PrimaryMenu/CityBtn
@onready var fighting_btn: Button = $PrimaryMenu/FightingBtn
@onready var settings_btn: Button = $PrimaryMenu/SettingsBtn
@onready var exit_btn: Button = $PrimaryMenu/ExitBtn

# City Submenu
@onready var city_submenu: PanelContainer = $CitySubmenu
@onready var city_single_btn: Button = $CitySubmenu/VBox/CitySingleBtn
@onready var city_double_btn: Button = $CitySubmenu/VBox/CityDoubleBtn
@onready var city_back_btn: Button = $CitySubmenu/VBox/CityBackBtn

# Single Player Hero Selection
@onready var single_player_modal: PanelContainer = $SinglePlayerModal
@onready var sp_live_preview: CharacterPreview = $SinglePlayerModal/VBox/ContentRow/PreviewBox/LivePreview3D
@onready var sp_pick_weaver_btn: Button = $SinglePlayerModal/VBox/ContentRow/DetailsBox/SelectorButtons/PickWeaverBtn
@onready var sp_pick_knight_btn: Button = $SinglePlayerModal/VBox/ContentRow/DetailsBox/SelectorButtons/PickKnightBtn
@onready var sp_hero_name: Label = $SinglePlayerModal/VBox/ContentRow/DetailsBox/HeroName
@onready var sp_hero_theme: Label = $SinglePlayerModal/VBox/ContentRow/DetailsBox/HeroTheme
@onready var sp_hero_lore: Label = $SinglePlayerModal/VBox/ContentRow/DetailsBox/HeroLore
@onready var sp_traversal_info: Label = $SinglePlayerModal/VBox/ContentRow/DetailsBox/AbilitiesBox/TraversalInfo
@onready var sp_combat_info: Label = $SinglePlayerModal/VBox/ContentRow/DetailsBox/AbilitiesBox/CombatInfo
@onready var sp_start_city_btn: Button = $SinglePlayerModal/VBox/ActionRow/StartCityBtn
@onready var sp_back_btn: Button = $SinglePlayerModal/VBox/ActionRow/SpBackBtn

# Double Player Hero Selection
@onready var double_player_modal: PanelContainer = $DoublePlayerModal
@onready var dp_p1_preview: CharacterPreview = $DoublePlayerModal/VBox/Columns/P1Column/P1Preview
@onready var dp_p2_preview: CharacterPreview = $DoublePlayerModal/VBox/Columns/P2Column/P2Preview
@onready var dp_p1_weaver_btn: Button = $DoublePlayerModal/VBox/Columns/P1Column/P1Buttons/P1WeaverBtn
@onready var dp_p1_knight_btn: Button = $DoublePlayerModal/VBox/Columns/P1Column/P1Buttons/P1KnightBtn
@onready var dp_p2_weaver_btn: Button = $DoublePlayerModal/VBox/Columns/P2Column/P2Buttons/P2WeaverBtn
@onready var dp_p2_knight_btn: Button = $DoublePlayerModal/VBox/Columns/P2Column/P2Buttons/P2KnightBtn
@onready var dp_launch_btn: Button = $DoublePlayerModal/VBox/DpActionRow/Launch2PBtn
@onready var dp_back_btn: Button = $DoublePlayerModal/VBox/DpActionRow/DpBackBtn

# Fighting Game Submenu
@onready var fighting_submenu: PanelContainer = $FightingSubmenu
@onready var fight_cpu_btn: Button = $FightingSubmenu/VBox/SpFightBox/FightCpuBtn
@onready var diff_easy_btn: Button = $FightingSubmenu/VBox/SpFightBox/DiffRow/DiffEasy
@onready var diff_normal_btn: Button = $FightingSubmenu/VBox/SpFightBox/DiffRow/DiffNormal
@onready var diff_hard_btn: Button = $FightingSubmenu/VBox/SpFightBox/DiffRow/DiffHard
@onready var fight_2p_btn: Button = $FightingSubmenu/VBox/Fight2PBtn
@onready var fighting_back_btn: Button = $FightingSubmenu/VBox/FightingBackBtn

# Settings Modal
@onready var settings_modal: PanelContainer = $SettingsModal
@onready var master_vol_slider: HSlider = $SettingsModal/VBox/Grid/MasterVolSlider
@onready var sfx_vol_slider: HSlider = $SettingsModal/VBox/Grid/SfxVolSlider
@onready var traffic_toggle_btn: Button = $SettingsModal/VBox/Grid/TrafficToggleBtn
@onready var pop_toggle_btn: Button = $SettingsModal/VBox/Grid/PopToggleBtn
@onready var sens_slider: HSlider = $SettingsModal/VBox/Grid/SensSlider
@onready var settings_back_btn: Button = $SettingsModal/VBox/SettingsBackBtn

# Styles for active vs inactive buttons
var style_active: StyleBoxFlat = null
var style_inactive: StyleBoxFlat = null

# State
var sp_chosen_hero: String = GameConfigScript.HERO_CRIMSON_WEAVER
var dp_p1_hero: String = GameConfigScript.HERO_CRIMSON_WEAVER
var dp_p2_hero: String = GameConfigScript.HERO_SHADOW_KNIGHT
var arena_diff: int = 1 # 0 = Easy, 1 = Normal, 2 = Hard

func _ready() -> void:
	GameConfigScript.load_game()
	_create_styles()
	_connect_signals()
	_show_primary_menu()
	
	_update_sp_selection_display()
	_update_dp_selection_display()
	_update_arena_diff_ui()
	_load_settings_values()
	
	if city_btn:
		city_btn.grab_focus()

func _create_styles() -> void:
	style_active = StyleBoxFlat.new()
	style_active.bg_color = Color(0.12, 0.22, 0.38, 0.95)
	style_active.border_width_left = 2
	style_active.border_width_top = 2
	style_active.border_width_right = 2
	style_active.border_width_bottom = 2
	style_active.border_color = Color(0.35, 0.8, 1.0, 1.0)
	style_active.corner_radius_top_left = 6
	style_active.corner_radius_top_right = 6
	style_active.corner_radius_bottom_right = 6
	style_active.corner_radius_bottom_left = 6
	
	style_inactive = StyleBoxFlat.new()
	style_inactive.bg_color = Color(0.08, 0.09, 0.13, 0.8)
	style_inactive.border_width_left = 1
	style_inactive.border_width_top = 1
	style_inactive.border_width_right = 1
	style_inactive.border_width_bottom = 1
	style_inactive.border_color = Color(0.2, 0.25, 0.35, 0.6)
	style_inactive.corner_radius_top_left = 6
	style_inactive.corner_radius_top_right = 6
	style_inactive.corner_radius_bottom_right = 6
	style_inactive.corner_radius_bottom_left = 6

func _connect_signals() -> void:
	# Primary 4 Choices
	city_btn.pressed.connect(_on_city_pressed)
	fighting_btn.pressed.connect(_on_fighting_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)
	
	# City Submenu
	city_single_btn.pressed.connect(_on_city_single_pressed)
	city_double_btn.pressed.connect(_on_city_double_pressed)
	city_back_btn.pressed.connect(_show_primary_menu)
	
	# Single Player Selection
	sp_pick_weaver_btn.pressed.connect(func(): _select_sp_hero(GameConfigScript.HERO_CRIMSON_WEAVER))
	sp_pick_knight_btn.pressed.connect(func(): _select_sp_hero(GameConfigScript.HERO_SHADOW_KNIGHT))
	sp_start_city_btn.pressed.connect(_launch_single_player_city)
	sp_back_btn.pressed.connect(_on_city_pressed)
	
	# Double Player Selection
	dp_p1_weaver_btn.pressed.connect(func(): _select_dp_p1_hero(GameConfigScript.HERO_CRIMSON_WEAVER))
	dp_p1_knight_btn.pressed.connect(func(): _select_dp_p1_hero(GameConfigScript.HERO_SHADOW_KNIGHT))
	dp_p2_weaver_btn.pressed.connect(func(): _select_dp_p2_hero(GameConfigScript.HERO_CRIMSON_WEAVER))
	dp_p2_knight_btn.pressed.connect(func(): _select_dp_p2_hero(GameConfigScript.HERO_SHADOW_KNIGHT))
	dp_launch_btn.pressed.connect(_launch_double_player_city)
	dp_back_btn.pressed.connect(_on_city_pressed)
	
	# Fighting Game Submenu
	fight_cpu_btn.pressed.connect(_launch_fighting_cpu)
	diff_easy_btn.pressed.connect(func(): _set_arena_diff(0))
	diff_normal_btn.pressed.connect(func(): _set_arena_diff(1))
	diff_hard_btn.pressed.connect(func(): _set_arena_diff(2))
	fight_2p_btn.pressed.connect(_launch_fighting_2p)
	fighting_back_btn.pressed.connect(_show_primary_menu)
	
	# Settings Modal
	master_vol_slider.value_changed.connect(_on_master_vol_changed)
	sfx_vol_slider.value_changed.connect(_on_sfx_vol_changed)
	traffic_toggle_btn.pressed.connect(_on_toggle_traffic)
	pop_toggle_btn.pressed.connect(_on_toggle_population)
	sens_slider.value_changed.connect(_on_sens_changed)
	settings_back_btn.pressed.connect(_on_settings_back_pressed)

# --- NAVIGATION ROUTING ---
func _show_primary_menu() -> void:
	primary_menu.visible = true
	city_submenu.visible = false
	single_player_modal.visible = false
	double_player_modal.visible = false
	fighting_submenu.visible = false
	settings_modal.visible = false
	city_btn.grab_focus()

func _on_city_pressed() -> void:
	primary_menu.visible = false
	city_submenu.visible = true
	single_player_modal.visible = false
	double_player_modal.visible = false
	fighting_submenu.visible = false
	settings_modal.visible = false
	city_single_btn.grab_focus()

func _on_city_single_pressed() -> void:
	primary_menu.visible = false
	city_submenu.visible = false
	double_player_modal.visible = false
	fighting_submenu.visible = false
	settings_modal.visible = false
	single_player_modal.visible = true
	_update_sp_selection_display()
	sp_start_city_btn.grab_focus()

func _on_city_double_pressed() -> void:
	primary_menu.visible = false
	city_submenu.visible = false
	single_player_modal.visible = false
	fighting_submenu.visible = false
	settings_modal.visible = false
	double_player_modal.visible = true
	_update_dp_selection_display()
	dp_launch_btn.grab_focus()

func _on_fighting_pressed() -> void:
	primary_menu.visible = false
	fighting_submenu.visible = true
	city_submenu.visible = false
	single_player_modal.visible = false
	double_player_modal.visible = false
	settings_modal.visible = false
	fight_cpu_btn.grab_focus()

func _on_settings_pressed() -> void:
	primary_menu.visible = false
	settings_modal.visible = true
	city_submenu.visible = false
	single_player_modal.visible = false
	double_player_modal.visible = false
	fighting_submenu.visible = false
	_load_settings_values()
	settings_back_btn.grab_focus()

func _on_exit_pressed() -> void:
	get_tree().quit()

# --- SINGLE PLAYER HERO SELECTION ---
func _select_sp_hero(hero_id: String) -> void:
	sp_chosen_hero = hero_id
	_update_sp_selection_display()

func _update_sp_selection_display() -> void:
	var is_weaver := (sp_chosen_hero == GameConfigScript.HERO_CRIMSON_WEAVER)
	sp_pick_weaver_btn.add_theme_stylebox_override("normal", style_active if is_weaver else style_inactive)
	sp_pick_knight_btn.add_theme_stylebox_override("normal", style_inactive if is_weaver else style_active)
	
	if is_weaver:
		sp_hero_name.text = "CRIMSON WEAVER"
		sp_hero_name.add_theme_color_override("font_color", Color(0.95, 0.25, 0.25))
		sp_hero_theme.text = "Acrobatic Web-Slinger • Coastal Protector"
		sp_hero_lore.text = "Equipped with wrist-mounted web synthesizers. Uses slingshot impulse physics and acrobatic double flips to vault across coastal skyscrapers."
		sp_traversal_info.text = "TRAVERSAL: Web-Pull Slingshot (High Ledge Launch) & Double-Jump Flip"
		sp_combat_info.text = "SPECIAL ATTACK: 360° Web Burst (Restrains & slows hostile NPCs)"
	else:
		sp_hero_name.text = "SHADOW KNIGHT"
		sp_hero_name.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
		sp_hero_theme.text = "Dark-Tech Armored Vigilante • Syndicate Nemesis"
		sp_hero_lore.text = "High-tech armored suit with titanium grappling gear. Employs advanced surveillance and EMP shockwave gadgets to disrupt rogue street syndicates."
		sp_traversal_info.text = "TRAVERSAL: Tactical Grapple Dash (Rapid Rooftop Leap)"
		sp_combat_info.text = "SPECIAL ATTACK: Shadow EMP Pulse (Area energy shockwave with stun & knockback)"
		
	if sp_live_preview:
		sp_live_preview.set_hero(sp_chosen_hero)

func _launch_single_player_city() -> void:
	GameConfigScript.set_single_player_city(sp_chosen_hero)
	get_tree().change_scene_to_file("res://scenes/city.tscn")

# --- DOUBLE PLAYER HERO SELECTION ---
func _select_dp_p1_hero(hero_id: String) -> void:
	dp_p1_hero = hero_id
	_update_dp_selection_display()

func _select_dp_p2_hero(hero_id: String) -> void:
	dp_p2_hero = hero_id
	_update_dp_selection_display()

func _update_dp_selection_display() -> void:
	var p1_is_weaver := (dp_p1_hero == GameConfigScript.HERO_CRIMSON_WEAVER)
	dp_p1_weaver_btn.add_theme_stylebox_override("normal", style_active if p1_is_weaver else style_inactive)
	dp_p1_knight_btn.add_theme_stylebox_override("normal", style_inactive if p1_is_weaver else style_active)
	if dp_p1_preview:
		dp_p1_preview.set_hero(dp_p1_hero)
		
	var p2_is_weaver := (dp_p2_hero == GameConfigScript.HERO_CRIMSON_WEAVER)
	dp_p2_weaver_btn.add_theme_stylebox_override("normal", style_active if p2_is_weaver else style_inactive)
	dp_p2_knight_btn.add_theme_stylebox_override("normal", style_inactive if p2_is_weaver else style_active)
	if dp_p2_preview:
		dp_p2_preview.set_hero(dp_p2_hero)

func _launch_double_player_city() -> void:
	GameConfigScript.set_double_player_city(dp_p1_hero, dp_p2_hero)
	get_tree().change_scene_to_file("res://scenes/city.tscn")

# --- FIGHTING ARENA LAUNCH ---
func _set_arena_diff(diff: int) -> void:
	arena_diff = diff
	_update_arena_diff_ui()

func _update_arena_diff_ui() -> void:
	diff_easy_btn.modulate = Color.WHITE if arena_diff == 0 else Color(0.5, 0.5, 0.5)
	diff_normal_btn.modulate = Color(0.4, 0.85, 1.0) if arena_diff == 1 else Color(0.5, 0.5, 0.5)
	diff_hard_btn.modulate = Color(1.0, 0.35, 0.35) if arena_diff == 2 else Color(0.5, 0.5, 0.5)

func _launch_fighting_cpu() -> void:
	var diff_enum := GameConfigScript.Difficulty.NORMAL
	if arena_diff == 0: diff_enum = GameConfigScript.Difficulty.EASY
	elif arena_diff == 2: diff_enum = GameConfigScript.Difficulty.HARD
	
	GameConfigScript.set_arena_mode(true, diff_enum)
	get_tree().change_scene_to_file("res://scenes/arena.tscn")

func _launch_fighting_2p() -> void:
	GameConfigScript.set_arena_mode(false)
	get_tree().change_scene_to_file("res://scenes/arena.tscn")

# --- SETTINGS LOGIC ---
func _load_settings_values() -> void:
	if master_vol_slider: master_vol_slider.value = GameConfigScript.master_volume
	if sfx_vol_slider: sfx_vol_slider.value = GameConfigScript.sfx_volume
	if sens_slider: sens_slider.value = GameConfigScript.camera_sensitivity
	_update_traffic_btn_text()
	_update_pop_btn_text()

func _on_master_vol_changed(val: float) -> void:
	GameConfigScript.master_volume = val

func _on_sfx_vol_changed(val: float) -> void:
	GameConfigScript.sfx_volume = val

func _on_sens_changed(val: float) -> void:
	GameConfigScript.camera_sensitivity = val

func _on_toggle_traffic() -> void:
	GameConfigScript.traffic_density = (GameConfigScript.traffic_density + 1) % 4
	_update_traffic_btn_text()

func _update_traffic_btn_text() -> void:
	var labels := ["OFF", "LOW (2)", "MEDIUM (4)", "HIGH (6)"]
	if traffic_toggle_btn:
		traffic_toggle_btn.text = labels[clamp(GameConfigScript.traffic_density, 0, 3)]

func _on_toggle_population() -> void:
	GameConfigScript.population_density = (GameConfigScript.population_density + 1) % 3
	_update_pop_btn_text()

func _update_pop_btn_text() -> void:
	var labels := ["LOW (6)", "MEDIUM (12)", "HIGH (20)"]
	if pop_toggle_btn:
		pop_toggle_btn.text = labels[clamp(GameConfigScript.population_density, 0, 2)]

func _on_settings_back_pressed() -> void:
	GameConfigScript.save_game()
	_show_primary_menu()
