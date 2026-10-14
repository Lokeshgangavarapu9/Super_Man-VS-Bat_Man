class_name MissionManager
extends Node

signal mission_started(title: String, description: String)
signal mission_objective_updated(text: String)
signal mission_completed(title: String, reward_tokens: int)
signal mission_failed(reason: String)

enum MissionType {
	NONE,
	ROOFTOP_TIME_TRIAL,
	PLAZA_DEFENSE,
	COLLECTIBLE_HUNT
}

var active_mission: MissionType = MissionType.NONE
var mission_title: String = "FREE ROAM"
var mission_description: String = "Explore the coastal district, test traversal powers, or interact with mission stations."
var mission_timer: float = 0.0
var objective_progress: int = 0
var objective_total: int = 0
var checkpoint_nodes: Array[Node3D] = []

func _process(delta: float) -> void:
	if active_mission == MissionType.ROOFTOP_TIME_TRIAL:
		mission_timer -= delta
		mission_objective_updated.emit("Time Remaining: %.1fs | Checkpoints: %d/%d" % [max(0.0, mission_timer), objective_progress, objective_total])
		if mission_timer <= 0.0:
			fail_mission("TIME EXPIRED!")

func start_rooftop_trial(checkpoints: Array[Node3D]) -> void:
	active_mission = MissionType.ROOFTOP_TIME_TRIAL
	mission_title = "ROOFTOP PARKOUR TIME TRIAL"
	mission_description = "Race across coastal skyscrapers and hit all beacon checkpoints before time runs out!"
	mission_timer = 50.0
	checkpoint_nodes = checkpoints
	objective_progress = 0
	objective_total = checkpoints.size()
	
	for i in range(checkpoints.size()):
		var cp := checkpoints[i]
		if cp:
			cp.visible = (i == 0) # Only first checkpoint active initially
			
	mission_started.emit(mission_title, mission_description)

func reach_checkpoint(index: int) -> void:
	if active_mission != MissionType.ROOFTOP_TIME_TRIAL:
		return
	if index == objective_progress:
		objective_progress += 1
		if checkpoint_nodes.size() > index and checkpoint_nodes[index]:
			checkpoint_nodes[index].visible = false
			
		if objective_progress >= objective_total:
			complete_mission(30)
		else:
			if checkpoint_nodes.size() > objective_progress and checkpoint_nodes[objective_progress]:
				checkpoint_nodes[objective_progress].visible = true
			mission_objective_updated.emit("Checkpoint %d Cleared! Next beacon active." % objective_progress)

func start_plaza_defense() -> void:
	active_mission = MissionType.PLAZA_DEFENSE
	mission_title = "PLAZA SECURITY INTERVENTION"
	mission_description = "Neutralize the rogue syndicate operatives causing havoc in Central Plaza!"
	objective_progress = 0
	objective_total = 4
	mission_started.emit(mission_title, mission_description)
	mission_objective_updated.emit("Operatives Defeated: 0/4")

func record_hostile_defeated() -> void:
	if active_mission == MissionType.PLAZA_DEFENSE:
		objective_progress += 1
		mission_objective_updated.emit("Operatives Defeated: %d/%d" % [objective_progress, objective_total])
		if objective_progress >= objective_total:
			complete_mission(50)

func complete_mission(reward_tokens: int) -> void:
	var completed_title := mission_title
	active_mission = MissionType.NONE
	mission_title = "FREE ROAM"
	mission_description = "City sector secured. Explore coastal docks, discover hidden tokens, or challenge missions."
	
	var GameConfigScript = load("res://scripts/game_config.gd")
	if GameConfigScript:
		GameConfigScript.total_tokens += reward_tokens
		if not GameConfigScript.missions_completed.has(completed_title):
			GameConfigScript.missions_completed.append(completed_title)
		GameConfigScript.save_game()
		
	mission_completed.emit(completed_title, reward_tokens)

func fail_mission(reason: String) -> void:
	active_mission = MissionType.NONE
	mission_title = "FREE ROAM"
	mission_description = "Mission failed. Return to mission beacon to try again."
	for cp in checkpoint_nodes:
		if cp: cp.visible = false
	mission_failed.emit(reason)
