class_name Level
extends Node2D

## Reusable foundation for playable levels. Scenes define their own objective
## and call level_pass() when that objective has been completed.
@export_file("*.tscn") var completion_scene_path: String = ""
@export var maximum_score_health := 3

@onready var player: CharacterBody2D = $player
@onready var curtain: Area2D = $curtain
@onready var control: Node2D = $CanvasLayer/control

var checkpoint := Vector2.ZERO
var current_scene_path := ""
var _is_completing := false

func _ready() -> void:
	current_scene_path = scene_file_path

func set_checkpoint(new_checkpoint: Vector2) -> void:
	checkpoint = new_checkpoint

func reset_player_to_checkpoint() -> void:
	player.global_position = checkpoint

func _on_killzone_body_entered(body: Node2D) -> void:
	if body == player:
		reset_player_to_checkpoint()

func _on_player_player_died() -> void:
	player.health = 3
	reset_player_to_checkpoint()

## Call this from any level-specific goal: a door, boss defeat, item pickup,
## timer, dialogue choice, or a custom trigger.
func level_pass() -> void:
	if _is_completing or completion_scene_path.is_empty():
		return
	_is_completing = true
	await curtain.play_animation(curtain.FADEIN)

	var save_data: Dictionary = Global.load_data()
	var player_data: Dictionary = save_data.get("player", {})
	_before_level_completed(player_data)
	_update_completion_score(save_data, player_data)
	save_data["player"] = player_data
	Global.save_data(save_data)
	get_tree().change_scene_to_file(completion_scene_path)

## Override in a level when it needs to persist extra completion state.
func _before_level_completed(_player_data: Dictionary) -> void:
	pass

func _update_completion_score(save_data: Dictionary, player_data: Dictionary) -> void:
	var levels_completed: Dictionary = save_data.get("levels_completed", {})
	var level_record: Dictionary = levels_completed.get(current_scene_path, {})
	var previous_score: int = int(level_record.get("score", 0))
	var score: int = mini(int(player.health), maximum_score_health)

	if score > previous_score:
		level_record["score"] = score
		var knowledge_scraps: int = int(player_data.get("knowledge_scraps", 0)) + score - previous_score
		player_data["knowledge_scraps"] = knowledge_scraps
		Global.notify_player_coin_changed(knowledge_scraps)
	else:
		level_record["score"] = previous_score

	levels_completed[current_scene_path] = level_record
	save_data["levels_completed"] = levels_completed
