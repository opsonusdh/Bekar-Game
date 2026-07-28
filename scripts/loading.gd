extends Node2D

var data = {}
@onready var are_you_sure_to_restart: Node2D = $"are you sure to restart?"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	are_you_sure_to_restart.hide()
	if not FileAccess.file_exists(Global.path):
		get_tree().change_scene_to_file("res://scenes/game entry.tscn")
	else:
		data = Global.load_data()
		print(data)
		if not data:
			Global.save_data({"player": {}})
			get_tree().change_scene_to_file("res://scenes/game entry.tscn")
		
		var btns = [$"Text Button", $"Text Button2", $"Text Button3", $"are you sure to restart?/Text Button4", $"are you sure to restart?/Text Button5"]
		for btn in btns:
			btn.button_clicked.connect(_on_any_button_clicked)



func _on_any_button_clicked(id: int):
	if id == 0:
		if data:
			get_tree().change_scene_to_file(data["current_scene"])
		else:
			get_tree().change_scene_to_file("res://scenes/game entry.tscn")
	elif id == 1:
		are_you_sure_to_restart.show()
	elif id == 2:
		get_tree().quit()
	elif id == 3:
		data = {}
		Global.save_data(data)
		are_you_sure_to_restart.hide()
	elif id == 4:
		are_you_sure_to_restart.hide()
