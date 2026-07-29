extends Node2D

var data = {}
@onready var are_you_sure_to_restart: Node2D = $"are you sure to restart?"
@onready var debug_button: Node2D = $"Text Button4"
@onready var camera: Camera2D = $Camera2D
@onready var v_box: VBoxContainer = $"Debug/Jump to Scene/ScrollContainer/VBoxContainer"
@onready var text_edit: TextEdit = $"Debug/Edit Game File/TextEdit"
@onready var report: Label = $"Debug/Edit Game File/Report"

var text_btn = preload("res://scenes/text_button.tscn")

func get_scene_files(path: String) -> Array[String]:
	var scenes: Array[String] = []

	var dir := DirAccess.open(path)
	if dir == null:
		push_error("Cannot open directory: " + path)
		return scenes

	dir.list_dir_begin()

	while true:
		var file := dir.get_next()
		if file == "":
			break

		if !dir.current_is_dir() and file.ends_with(".tscn"):
			scenes.append(path.path_join(file))

	dir.list_dir_end()

	return scenes

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	are_you_sure_to_restart.hide()
	if not Global.DEBUG:
		debug_button.hide()
	if not FileAccess.file_exists(Global.path):
		get_tree().change_scene_to_file("res://scenes/game entry.tscn")
	else:
		data = Global.load_data()
		print(data)
		if not data:
			Global.save_data({"player": {}})
			get_tree().change_scene_to_file("res://scenes/game entry.tscn")
		
		var btns = [$"Text Button", $"Text Button2", $"Text Button3", 
		$"are you sure to restart?/Text Button4", 
		$"are you sure to restart?/Text Button5", $"Text Button4", 
		$"Debug/Text Button6", $"Debug/Text Button7", $"Debug/Text Button8", 
		$"Debug/Jump to Scene/Text Button9", $"Debug/Edit Game File/Text Button10", 
		$"Debug/Edit Game File/Text Button11", $"Debug/Edit Game File/Text Button12"]
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
	elif id == 3 or id == 9 or id == 10:
		camera.position = Vector2(1939, -5)
	elif id == 4:
		data = {}
		Global.save_data(data)
		are_you_sure_to_restart.hide()
	elif id == 5:
		are_you_sure_to_restart.hide()
	elif id == 6:
		camera.position = Vector2(-2, 990)

		for child in v_box.get_children():
			child.queue_free()

		await get_tree().process_frame

		var _scenes = get_scene_files("res://scenes/")

		for scene_path in _scenes:
			var btn := Button.new()
			btn.text = scene_path.get_file().get_basename()

			btn.custom_minimum_size = Vector2(0, 36)
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

			btn.add_theme_color_override("font_color", Color.WHITE)
			btn.add_theme_color_override("font_hover_color", Color.YELLOW)
			btn.add_theme_color_override("font_pressed_color", Color.CYAN)
			btn.add_theme_font_size_override("font_size", 18)

			btn.pressed.connect(func():
				get_tree().change_scene_to_file(scene_path)
			)

			v_box.add_child(btn)

		await get_tree().process_frame
		v_box.queue_sort()
	
	elif id == 7 or id == 12:
		camera.global_position = Vector2(1808, 1004)
		data = Global.load_data()
		text_edit.text = JSON.stringify(data, "\t")
		
	elif id == 8:
		camera.position = Vector2(0, 0)
	elif id == 11:
		var text = text_edit.text
		var json = JSON.new()
		var error = json.parse(text)

		
		if error == OK:
			Global.save_data(json.data)
			report.text = "Game data saved successfully"
		else:
			report.text = "Error: " + json.get_error_message()
