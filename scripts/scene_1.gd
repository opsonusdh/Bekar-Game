extends Node2D

var data = {}
var player_in_door1 = false
var player_in_door2 = false
@onready var player: CharacterBody2D = $CharacterBody1D
@onready var touch_screen_button: TouchScreenButton = $TouchScreenButton
@onready var curtain: Area2D = $curtain
@onready var on_screen_btns: CanvasLayer = $on_screen_btns
@onready var interractable_area_2d: Area2D = $areas/Interractable_Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	data = Global.load_data()
	data["current_scene"] = get_tree().current_scene.scene_file_path
	
	var _player = data.get("player", {})
	if not _player.get("completed_tutorial", false):
		on_screen_btns.dpad_top_visible = false
		on_screen_btns.dpad_pos_lock_visible = false
		on_screen_btns.dpad_jump_visible = false
		on_screen_btns.dpad_crouch_visible = false
		on_screen_btns.dpad_fire_visible = false
		on_screen_btns.dpad_interract_visible = false
		on_screen_btns._ready()
	elif _player.get("completed_btn_desc", false) and _player.get("completed_tutorial", false):
		pass
	Global.save_data(data)
	await curtain.play_animation(curtain.FADEOUT)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player:
		touch_screen_button.show()
		player_in_door1 = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		touch_screen_button.hide()
		player_in_door1 = false

func _process(delta):
	if Input.is_action_just_pressed("interract"):
		if player_in_door1:
			await curtain.play_animation(curtain.FADEIN)
			get_tree().change_scene_to_file("res://scenes/scene_1_1.tscn")
		elif player_in_door2:
			get_tree().change_scene_to_file("res://scenes/scene_1_2.tscn")


func _on_on_screen_btns_button_pressed(button_type: String) -> void:
	if button_type in ["treasure", "pause"]:
		await on_screen_btns.show_box(button_type)
		get_tree().paused = true
	elif button_type == "treasure_close":
		on_screen_btns.hide_box("treasure")
		get_tree().paused = false
	elif button_type == "continue":
		get_tree().paused = false
		on_screen_btns.hide_box("pause")
	elif button_type == "restart":
		get_tree().reload_current_scene()
		get_tree().paused = false
		on_screen_btns.hide_box("restart")
		on_screen_btns.hide_box("pause")
	elif button_type == "quit":
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/loading.tscn")


func _on_interractable_area_2d_body_entered(body: Node2D) -> void:
	if body == player:
		interractable_area_2d.highlight(true)
		player_in_door2 = true

func _on_interractable_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		interractable_area_2d.highlight(false)
		player_in_door2 = false
