extends Node2D

@onready var player: CharacterBody2D = $CharacterBody2D
@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var dpad: Node2D = $CanvasLayer/Control/dpad
var next_scene = preload("res://scenes/jumpscare.tscn")

var data = Global.load_data()
var movement_data = []


func _ready() -> void:
	if data == {}:
		data = Global.GLOBAL_FILE_TEMPLATE
		Global.save_data(data)
	if not FileAccess.file_exists(Global.SAVE_PATH):
		Global.save_data(data)
	else:
		data = Global.load_data()
		data["current_scene"] = get_tree().current_scene.scene_file_path
		
		
	if not data.get("plater", {}).get("completed_tutorial", false):
		dpad.pos_lock_visible = false
		dpad.jump_visible = false
		dpad.crouch_visible = false
		dpad.fire_visible = false
		dpad.interract_visible = false
		dpad.apply_configuration()

func _on_entrance_of_main_game_enter_btn_pressed() -> void:
	data["completed_scenes"] = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_packed(next_scene)

func play_bgm_based_on_movement():
	match  movement_data:
		["entering_door", "exiting_door", "in_grass"]:
			audio_stream_player.stop()
		["in_grass", "not_in_grass", "entering_door"]:
			audio_stream_player.play()

func update_movement_data(data):
	if movement_data.size() >= 2:
		movement_data = movement_data.slice(-2)
	movement_data.append(data)
	


func _on_zone_12_body_entered(body: Node2D) -> void:
	if body == player:
		update_movement_data("entering_door")
		play_bgm_based_on_movement()


func _on_checking_if_on_grass_body_entered(body: Node2D) -> void:
	if body == player:
		update_movement_data("in_grass")
		play_bgm_based_on_movement()

func _on_zone_12_body_exited(body: Node2D) -> void:
	if body == player:
		update_movement_data("exiting_door")
		play_bgm_based_on_movement()

func _on_checking_if_on_grass_body_exited(body: Node2D) -> void:
	if body == player:
		update_movement_data("not_in_grass")
		play_bgm_based_on_movement()
