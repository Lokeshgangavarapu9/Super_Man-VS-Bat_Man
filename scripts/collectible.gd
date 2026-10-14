class_name HeroCollectible
extends Area3D

@export var token_id: String = "token_default"
@export var token_value: int = 1
@export var spin_speed: float = 2.5

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var omni_light: OmniLight3D = $OmniLight3D

var start_y: float = 0.0
var elapsed: float = 0.0
var is_collected: bool = false

func _ready() -> void:
	start_y = position.y
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if is_collected:
		return
	elapsed += delta
	rotate_y(spin_speed * delta)
	position.y = start_y + sin(elapsed * 3.0) * 0.2

func _on_body_entered(body: Node3D) -> void:
	if is_collected:
		return
	if body is CharacterBody3D and (body.is_in_group("players") or body.name.begins_with("Player")):
		collect(body)

func collect(collector: Node3D) -> void:
	is_collected = true
	var GameConfigScript = load("res://scripts/game_config.gd")
	if GameConfigScript:
		GameConfigScript.total_tokens += token_value
		if not GameConfigScript.collectibles_found.has(token_id):
			GameConfigScript.collectibles_found.append(token_id)
		GameConfigScript.save_game()
		
	# Notify city HUD if possible
	var city := get_tree().get_first_node_in_group("city_manager")
	if city and city.has_method("notify_event"):
		city.notify_event("HERO TOKEN COLLECTED! (TOTAL: %d)" % [GameConfigScript.total_tokens])
		
	# Collection animation: rise up and shrink
	var tw := create_tween().set_parallel(true)
	tw.tween_property(self, "position:y", position.y + 1.6, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector3.ZERO, 0.35)
	tw.chain().tween_callback(queue_free)
