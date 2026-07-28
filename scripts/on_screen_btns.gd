extends CanvasLayer

@export var tresure_visible := true
@onready var coin_label: Label = $"Control/coin label"
@onready var treasure: TouchScreenButton = $Control/treasure
@onready var treasure_box: NinePatchRect = $Control/treasure2
@onready var pause_box: NinePatchRect = $Control/treasure3
@onready var knowledge_scrape_value: Label = $"Control/treasure2/knowledge scrape value"
@onready var enchantments_empty_label: Label = $Control/treasure2/ScrollContainer2/HBoxContainer/Label
@onready var weapon_sprite: Sprite2D = $Control/treasure2/weapon
@onready var weapon_level: Label = $"Control/treasure2/weapon level"
@onready var heart_count: Label = $"Control/treasure2/heart count"
@onready var touch_screen_button: TouchScreenButton = $Control/treasure2/TouchScreenButton
@onready var enchantments_box: HBoxContainer = $Control/treasure2/ScrollContainer2/HBoxContainer
@onready var are_you_sure_to_quit: Node2D = $"Control/treasure3/are you sure to quit?"
@onready var are_you_sure_to_restart: Node2D = $"Control/treasure3/are you sure to restart?"
@onready var dpad: Node2D = $Control/dpad

@export var dpad_top_visible := true
@export var dpad_bottom_visible := true
@export var dpad_left_visible := true
@export var dpad_right_visible := true
@export var dpad_pos_lock_visible := true
@export var dpad_jump_visible := true
@export var dpad_crouch_visible := true
@export var dpad_fire_visible := true
@export var dpad_interract_visible := true
@export var dpad_dpad_passby_press := true

@export var dpad_custom_top_action := ""
@export var dpad_custom_bottom_action := ""
@export var dpad_custom_left_action := ""
@export var dpad_custom_right_action := ""
@export var dpad_custom_pos_lock_action := ""
@export var dpad_custom_jump_action := ""
@export var dpad_custom_crouch_action := ""
@export var dpad_custom_fire_action := ""
@export var dpad_custom_interract_action := ""

var item_showcase = preload("res://scenes/items_showcase.tscn")

signal button_pressed(button_type: String)

func _ready():
	Global.Player_coin_changed.connect(_on_coin_changed)
	
	var coin = Global.load_data().get("player", {}).get("knowledge_scraps", 0)
	_on_coin_changed(coin)
	var btns = [
		$"Control/treasure3/Text Button", \
		$"Control/treasure3/Text Button2", $"Control/treasure3/Text Button3", \
		$"Control/treasure3/are you sure to restart?/Text Button4", \
		$"Control/treasure3/are you sure to restart?/Text Button5", \
		$"Control/treasure3/are you sure to quit?/Text Button4", \
		$"Control/treasure3/are you sure to quit?/Text Button5"
	]
	for btn in btns:
		btn.button_clicked.connect(_on_text_btn_pressed)
	if not tresure_visible:
		treasure.queue_free()
		
	dpad.top_visible = dpad_top_visible
	dpad.bottom_visible = dpad_bottom_visible
	dpad.left_visible = dpad_left_visible
	dpad.right_visible = dpad_right_visible
	dpad.pos_lock_visible = dpad_pos_lock_visible
	dpad.jump_visible = dpad_jump_visible
	dpad.crouch_visible = dpad_crouch_visible
	dpad.fire_visible = dpad_fire_visible
	dpad.interract_visible = dpad_interract_visible
	dpad.dpad_passby_press = dpad_dpad_passby_press

	dpad.custom_top_action = dpad_custom_top_action
	dpad.custom_bottom_action = dpad_custom_bottom_action
	dpad.custom_left_action = dpad_custom_left_action
	dpad.custom_right_action = dpad_custom_right_action
	dpad.custom_pos_lock_action = dpad_custom_pos_lock_action
	dpad.custom_jump_action = dpad_custom_jump_action
	dpad.custom_crouch_action = dpad_custom_crouch_action
	dpad.custom_fire_action = dpad_custom_fire_action
	dpad.custom_interract_action = dpad_custom_interract_action
	
	dpad._ready()

func _on_coin_changed(amount):
	coin_label.text = str(amount)
	var label_settings = coin_label.label_settings
	if amount == 0:
		label_settings.set_font_color(Color(1, 0, 0, 1))
	else:
		label_settings.set_font_color(Color(1, 1, 1, 1))
	coin_label.label_settings = label_settings



func show_box(box):
	if box == "treasure":
		var data = Global.load_data()
		var _player = data.get("player", {})
		var hearts = _player.get("max_hearts", 3)
		var _knowledge_scrape = _player.get("knowledge_scrape", 0)
		var weapon = _player.get("active_weapon", {"name": "pensil", "damage": 1, "icon_path": "res://assets/pensil.png", "scene_path": "res://scenes/pensil.tscn"})
		var enchantments = _player.get("enchantments_purchased", [])
		#if enchantments == null:
			#enchantments = []
			#for i in range(10):
				#enchantments.append({"name": "Item Name", "sprite_path": "res://assets/knowledge scraps.png"})
		
		
		heart_count.text = str(hearts)
		weapon_sprite.texture = ImageTexture.create_from_image(Image.load_from_file(weapon["icon_path"]))
		weapon_sprite.scale = Vector2(72, 72)/weapon_sprite.texture.get_size()
		weapon_level.text = str(weapon["damage"])
		knowledge_scrape_value.text = str(hearts)
		
		if enchantments != null and enchantments != []:
			for child in enchantments_box.get_children():
				child.queue_free()
			for enchantment in enchantments:
				var node = item_showcase.instantiate()
				node.sprite_path = enchantment["sprite_path"]
				node.text = enchantment["name"]
				node._scale = Vector2.ONE*0.2
				enchantments_box.add_child(node)
			await get_tree().process_frame
			enchantments_box.queue_sort()
		treasure_box.show()
	if box == "pause":
		pause_box.show()

func hide_box(box):
	if box == "treasure":
		treasure_box.hide()
	if box == "pause":
		pause_box.hide()
	if box == "restart":
		are_you_sure_to_restart.hide()
	if box == "quit":
		are_you_sure_to_quit.hide()



func _on_treasure_released() -> void:
	button_pressed.emit("treasure")


func _on_cross_released() -> void:
	button_pressed.emit("treasure_close")

func _on_text_btn_pressed(id):
	if id == 1:
		button_pressed.emit("continue")
	elif  id == 2:
		are_you_sure_to_restart.show()
	elif id == 3:
		are_you_sure_to_quit.show()
	elif id == 4:
		button_pressed.emit("restart")
	elif id == 5:
		are_you_sure_to_restart.hide()
	elif id == 6:
		button_pressed.emit("quit")
	elif id == 7:
		are_you_sure_to_quit.hide()
	


func _on_touch_screen_button_2_released() -> void:
	button_pressed.emit("pause")
