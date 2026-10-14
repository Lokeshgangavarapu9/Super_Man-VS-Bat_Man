class_name CharacterPreview
extends SubViewportContainer

@export var auto_rotate: bool = true
@export var rotate_speed: float = 0.8
@export var hero_type: String = "crimson_weaver"

@onready var sub_viewport: SubViewport = $SubViewport
@onready var hero_mount: Node3D = $SubViewport/HeroMount
@onready var fallback_label: Label = $FallbackLabel

const PLAYER_SCENE = preload("res://scenes/player.tscn")
var current_hero_node: Node3D = null

func _ready() -> void:
	stretch = true
	if fallback_label:
		fallback_label.visible = false
	update_preview(hero_type)

func _process(delta: float) -> void:
	if auto_rotate and hero_mount:
		hero_mount.rotate_y(rotate_speed * delta)

func set_hero(new_hero_type: String) -> void:
	hero_type = new_hero_type
	update_preview(hero_type)

func update_preview(type_name: String) -> void:
	if not is_inside_tree() or not sub_viewport:
		return
		
	# Clear existing model immediately
	if hero_mount:
		for child in hero_mount.get_children():
			if child != $SubViewport/HeroMount/Pedestal and child != $SubViewport/HeroMount/PedestalRing:
				hero_mount.remove_child(child)
				child.queue_free()
	current_hero_node = null
		
	if not PLAYER_SCENE:
		if fallback_label:
			fallback_label.visible = true
			fallback_label.text = "[MODEL RESOURCE ERROR]"
		return

	var inst := PLAYER_SCENE.instantiate() as CharacterBody3D
	if not inst:
		if fallback_label:
			fallback_label.visible = true
			fallback_label.text = "[PREVIEW LOAD FAILED]"
		return
		
	inst.name = "PreviewHero"
	inst.hero_type = type_name
	inst.set_physics_process(false)
	inst.set_process_input(false)
	inst.set_process_unhandled_input(false)
	
	hero_mount.add_child(inst)
	current_hero_node = inst
	inst.position = Vector3(0, 0, 0)
	inst.rotation = Vector3.ZERO
	if inst.has_method("set_hero_type"):
		inst.set_hero_type(type_name)
	
	if fallback_label:
		fallback_label.visible = false
