class_name PauseMenu
extends CanvasLayer

## Pause menu overlay — appears on ESC during any gameplay scene.
## Provides: Resume, Settings (inline), Main Menu, Exit.

signal resume_requested
signal open_settings_requested
signal quit_to_menu_requested

@onready var panel: PanelContainer = $Panel
@onready var resume_btn: Button = $Panel/VBox/ResumeBtn
@onready var settings_btn: Button = $Panel/VBox/SettingsBtn
@onready var main_menu_btn: Button = $Panel/VBox/MainMenuBtn
@onready var exit_btn: Button = $Panel/VBox/ExitBtn
@onready var settings_panel: PanelContainer = $SettingsPanel

# Settings nodes (inside SettingsPanel)
@onready var tab_audio_btn: Button = $SettingsPanel/VBox/TabRow/TabAudio
@onready var tab_display_btn: Button = $SettingsPanel/VBox/TabRow/TabDisplay
@onready var tab_controls_btn: Button = $SettingsPanel/VBox/TabRow/TabControls
@onready var audio_tab: VBoxContainer = $SettingsPanel/VBox/Content/AudioTab
@onready var display_tab: VBoxContainer = $SettingsPanel/VBox/Content/DisplayTab
@onready var controls_tab: VBoxContainer = $SettingsPanel/VBox/Content/ControlsTab
@onready var settings_close_btn: Button = $SettingsPanel/VBox/CloseSettingsBtn

@onready var master_slider: HSlider = $SettingsPanel/VBox/Content/AudioTab/MasterRow/MasterSlider
@onready var sfx_slider: HSlider = $SettingsPanel/VBox/Content/AudioTab/SfxRow/SfxSlider
@onready var sens_slider: HSlider = $SettingsPanel/VBox/Content/ControlsTab/SensRow/SensSlider

var active_tab: String = "audio"

func _ready() -> void:
	layer = 100
	visible = false
	if settings_panel:
		settings_panel.visible = false
	_connect_buttons()
	_apply_panel_style()

func _connect_buttons() -> void:
	if resume_btn:
		resume_btn.pressed.connect(_on_resume)
	if settings_btn:
		settings_btn.pressed.connect(_on_open_settings)
	if main_menu_btn:
		main_menu_btn.pressed.connect(_on_main_menu)
	if exit_btn:
		exit_btn.pressed.connect(get_tree().quit)
	if settings_close_btn:
		settings_close_btn.pressed.connect(_on_close_settings)
	if tab_audio_btn:
		tab_audio_btn.pressed.connect(func(): _switch_tab("audio"))
	if tab_display_btn:
		tab_display_btn.pressed.connect(func(): _switch_tab("display"))
	if tab_controls_btn:
		tab_controls_btn.pressed.connect(func(): _switch_tab("controls"))
	if master_slider:
		master_slider.value_changed.connect(func(v): GameConfig.master_volume = v)
	if sfx_slider:
		sfx_slider.value_changed.connect(func(v): GameConfig.sfx_volume = v)
	if sens_slider:
		sens_slider.value_changed.connect(func(v): GameConfig.camera_sensitivity = v)

func _apply_panel_style() -> void:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.06, 0.08, 0.14, 0.97)
	s.border_width_left = 2; s.border_width_top = 2
	s.border_width_right = 2; s.border_width_bottom = 2
	s.border_color = Color(0.3, 0.75, 1.0, 0.9)
	s.corner_radius_top_left = 12; s.corner_radius_top_right = 12
	s.corner_radius_bottom_right = 12; s.corner_radius_bottom_left = 12
	if panel:
		panel.add_theme_stylebox_override("panel", s)
	if settings_panel:
		var s2 := s.duplicate() as StyleBoxFlat
		s2.border_color = Color(1.0, 0.6, 0.1, 0.9)
		settings_panel.add_theme_stylebox_override("panel", s2)

func open() -> void:
	visible = true
	get_tree().paused = true
	if resume_btn:
		resume_btn.grab_focus()

func close() -> void:
	visible = false
	if settings_panel:
		settings_panel.visible = false
	get_tree().paused = false

func _on_resume() -> void:
	close()
	resume_requested.emit()

func _on_open_settings() -> void:
	if panel:
		panel.visible = false
	if settings_panel:
		settings_panel.visible = true
		_load_settings_values()
		_switch_tab(active_tab)
		if settings_close_btn:
			settings_close_btn.grab_focus()

func _on_close_settings() -> void:
	GameConfig.save_game()
	if settings_panel:
		settings_panel.visible = false
	if panel:
		panel.visible = true
	if resume_btn:
		resume_btn.grab_focus()

func _on_main_menu() -> void:
	close()
	get_tree().paused = false
	quit_to_menu_requested.emit()
	var err := get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	if err != OK:
		push_error("Failed to return to main menu: %s" % error_string(err))

func _switch_tab(tab: String) -> void:
	active_tab = tab
	if audio_tab:
		audio_tab.visible = (tab == "audio")
	if display_tab:
		display_tab.visible = (tab == "display")
	if controls_tab:
		controls_tab.visible = (tab == "controls")

func _load_settings_values() -> void:
	if master_slider:
		master_slider.value = GameConfig.master_volume
	if sfx_slider:
		sfx_slider.value = GameConfig.sfx_volume
	if sens_slider:
		sens_slider.value = GameConfig.camera_sensitivity

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if visible:
			if settings_panel and settings_panel.visible:
				_on_close_settings()
			else:
				_on_resume()
			get_viewport().set_input_as_handled()
