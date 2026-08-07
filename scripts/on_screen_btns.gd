extends CanvasLayer

@export var tresure_visible := true
@onready var coin_label: Label = $"Control2/Control/coin label"
@onready var treasure: TouchScreenButton = $Control2/Control/treasure
@onready var treasure_box: NinePatchRect = $Control2/Control/treasure2
@onready var pause_box: NinePatchRect = $Control2/Control/treasure3
@onready var knowledge_scrape_value: Label = $"Control2/Control/treasure2/knowledge scrape value"
@onready var enchantments_empty_label: Label = $Control2/Control/treasure2/ScrollContainer2/HBoxContainer/Label
@onready var heart_count: Label = $"Control2/Control/treasure2/heart count"
@onready var touch_screen_button: TouchScreenButton = $Control2/Control/treasure2/cross
@onready var enchantments_box: HBoxContainer = $Control2/Control/treasure2/ScrollContainer2/HBoxContainer
@onready var are_you_sure_to_quit: Node2D = $"Control2/Control/treasure3/are you sure to quit?"
@onready var are_you_sure_to_restart: Node2D = $"Control2/Control/treasure3/are you sure to restart?"
@onready var dpad: Node2D = $Control2/Control/dpad
@onready var pause_button: TouchScreenButton = $Control2/Control/TouchScreenButton2
@onready var weapon_showcase: NinePatchRect = $"Control2/Control/treasure2/weapon/weapon showcase"
@onready var pensil: TouchScreenButton = $"Control2/Control/treasure2/weapon/weapon showcase/pensil"
@onready var ball_pen: TouchScreenButton = $"Control2/Control/treasure2/weapon/weapon showcase/ball pen"
@onready var fountain_pen: TouchScreenButton = $"Control2/Control/treasure2/weapon/weapon showcase/fountain pen"
@onready var weapon_button: TouchScreenButton = $"Control2/Control/treasure2/weapon/weapon button"

@export var dpad_top_visible := true
@export var dpad_bottom_visible := true
@export var dpad_left_visible := true
@export var dpad_right_visible := true
@export var dpad_pos_lock_visible := true
@export var dpad_jump_visible := true
@export var dpad_crouch_visible := true
@export var dpad_fire_visible := true
@export var dpad_interract_visible := true
@export var dpad_swap_visible := false
@export var dpad_passby_press := true

@export var dpad_custom_top_action := ""
@export var dpad_custom_bottom_action := ""
@export var dpad_custom_left_action := ""
@export var dpad_custom_right_action := ""
@export var dpad_custom_pos_lock_action := ""
@export var dpad_custom_jump_action := ""
@export var dpad_custom_crouch_action := ""
@export var dpad_custom_fire_action := ""
@export var dpad_custom_interract_action := ""
@export var dpad_custom_swap_action := ""

var item_showcase = preload("res://scenes/items_showcase.tscn")
var layout_save_button: Button
var data = Global.load_data()
var _player = data.get("player", {})
var hearts = int(_player.get("max_hearts", 3))
var knowledge_scrape = int(_player.get("knowledge_scrape", 0))
var active_weapon = _player.get("active_weapon", "pensil")
var weapon = Global.WEAPONS.get(active_weapon)
var obtained_weapon =  _player.get("obtained_weapons", [])
var enchantments = _player.get("enchantments_purchased", [])
var showcase_visible = false
var showcase_nodes: Dictionary = {}

signal button_pressed(button_type: String)

func _ready():
	Global.Player_coin_changed.connect(_on_coin_changed)
	Global.showcase_item_touched.connect(_on_showcase_touched)
	
	var coin = int(Global.load_data().get("player", {}).get("knowledge_scraps", 0))
	_on_coin_changed(coin)
	var btns = [
		$"Control2/Control/treasure3/Text Button", \
		$"Control2/Control/treasure3/Text Button2", $"Control2/Control/treasure3/Text Button3", \
		$"Control2/Control/treasure3/are you sure to restart?/Text Button4", \
		$"Control2/Control/treasure3/are you sure to restart?/Text Button5", \
		$"Control2/Control/treasure3/are you sure to quit?/Text Button4", \
		$"Control2/Control/treasure3/are you sure to quit?/Text Button5", \
		$"Control2/Control/treasure3/Text Button4"
	]
	for btn in btns:
		btn.button_clicked.connect(_on_text_btn_pressed)
	if not tresure_visible:
		treasure.queue_free()
		
	apply_configuration()
	get_viewport().size_changed.connect(_position_hud_buttons)
	call_deferred("_position_hud_buttons")

func _get_ignored_item_ids() -> Array:
	var connections = Global.POTIONS_AND_ENCHANTMENTS.get("connections", {})
	return Array(connections.get("ignore", []))


func _is_ignored_item(item_id: String) -> bool:
	return _get_ignored_item_ids().has(item_id)


func _sanitize_enchantment_config(config: Array) -> Array:
	var sanitized: Array = []
	for item_id in config:
		var id_string := String(item_id)
		if _is_ignored_item(id_string):
			continue
		sanitized.append(id_string)
	return sanitized


func _get_current_enchantment_config() -> Array:
	if _player.get("current_enchantment_config", null) is Array:
		return _sanitize_enchantment_config(Array(_player["current_enchantment_config"]))
	_player["current_enchantment_config"] = []
	return []


func _get_enchantment_category(item_id: String) -> String:
	if _is_ignored_item(item_id):
		return ""
	var connections = Global.POTIONS_AND_ENCHANTMENTS.get("connections", {})
	for category_name in ["weapon_enhancements", "advanced_enhancements"]:
		var category_config = connections.get(category_name, {})
		var connected_ids: Array = category_config.get("connected", [])
		if connected_ids.has(item_id):
			return category_name
	return ""


func _refresh_showcase_selection_ui() -> void:
	var current_config: Array = _get_current_enchantment_config()
	for item_id in showcase_nodes.keys():
		var node = showcase_nodes.get(item_id)
		if not is_instance_valid(node):
			continue
		var item_name = item_id
		for item in Global.POTIONS_AND_ENCHANTMENTS["ordinary"]:
			if item["id"] == item_id:
				item_name = item["name"]
				break
		var is_ignored := _is_ignored_item(item_id)
		var is_selected := current_config.has(item_id) or is_ignored
		if is_selected:
			node.set_display_text(item_name + " ✓")
		else:
			node.set_display_text(item_name)
		node.set_interactive(not is_ignored)


func _on_showcase_touched(id: String):
	if _is_ignored_item(id):
		return

	data = Global.load_data()
	_player = data.get("player", {})
	var current_enchantment_config: Array = _get_current_enchantment_config()
	var category := _get_enchantment_category(id)

	if current_enchantment_config.has(id):
		current_enchantment_config.erase(id)
	else:
		if category != "":
			var category_config = Global.POTIONS_AND_ENCHANTMENTS["connections"].get(category, {})
			var max_items: int = int(category_config.get("max", 0))
			var category_count := 0
			for item_id in current_enchantment_config:
				if _get_enchantment_category(String(item_id)) == category:
					category_count += 1
			if category_count >= max_items and max_items > 0:
				for index in range(current_enchantment_config.size() - 1, -1, -1):
					if _get_enchantment_category(String(current_enchantment_config[index])) == category:
						current_enchantment_config.remove_at(index)
						break
			current_enchantment_config.append(id)
		else:
			current_enchantment_config.append(id)

	current_enchantment_config = _sanitize_enchantment_config(current_enchantment_config)
	_player["current_enchantment_config"] = current_enchantment_config
	data["player"] = _player
	Global.save_data(data)
	_refresh_showcase_selection_ui()
	

func apply_configuration() -> void:
	dpad.top_visible = dpad_top_visible
	dpad.bottom_visible = dpad_bottom_visible
	dpad.left_visible = dpad_left_visible
	dpad.right_visible = dpad_right_visible
	dpad.pos_lock_visible = dpad_pos_lock_visible
	dpad.jump_visible = dpad_jump_visible
	dpad.crouch_visible = dpad_crouch_visible
	dpad.fire_visible = dpad_fire_visible
	dpad.interract_visible = dpad_interract_visible
	dpad.swap_visible = dpad_swap_visible
	dpad.dpad_passby_press = dpad_passby_press

	dpad.custom_top_action = dpad_custom_top_action
	dpad.custom_bottom_action = dpad_custom_bottom_action
	dpad.custom_left_action = dpad_custom_left_action
	dpad.custom_right_action = dpad_custom_right_action
	dpad.custom_pos_lock_action = dpad_custom_pos_lock_action
	dpad.custom_jump_action = dpad_custom_jump_action
	dpad.custom_crouch_action = dpad_custom_crouch_action
	dpad.custom_fire_action = dpad_custom_fire_action
	dpad.custom_interract_action = dpad_custom_interract_action
	dpad.custom_swap_action = dpad_custom_swap_action
	dpad.apply_configuration()


func _toggle_layout_editing() -> void:
	if dpad.is_layout_editing():
		return
	dpad.set_layout_editing(true)
	pause_box.hide()
	_show_layout_save_button()

func _show_layout_save_button() -> void:
	if not is_instance_valid(layout_save_button):
		layout_save_button = Button.new()
		layout_save_button.text = "SAVE CONTROLS"
		layout_save_button.tooltip_text = "Save the new touch-control positions."
		layout_save_button.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
		layout_save_button.position = Vector2(-78, -54)
		layout_save_button.size = Vector2(156, 34)
		layout_save_button.pressed.connect(_finish_layout_editing)
		$Control2.add_child(layout_save_button)
	layout_save_button.show()

func _finish_layout_editing() -> void:
	dpad.set_layout_editing(false)
	if is_instance_valid(layout_save_button):
		layout_save_button.hide()
	get_tree().paused = false

func _position_hud_buttons() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var size_factor: float = minf(viewport_size.x / 1152.0, viewport_size.y / 648.0)
	var margin := 24.0 * clampf(size_factor, 0.72, 1.0)
	# These two utility buttons were authored at fixed pixels near the top-right.
	if is_instance_valid(pause_button):
		pause_button.global_position = Vector2(viewport_size.x - margin * 2.4, margin)
	if is_instance_valid(treasure):
		treasure.global_position = Vector2(viewport_size.x - margin * 5.4, margin)

func _on_coin_changed(amount):
	coin_label.text = str(int(amount))
	var label_settings = coin_label.label_settings
	if amount == 0:
		label_settings.set_font_color(Global.INSUFFICIENT_BALANCE_COLOR)
	else:
		label_settings.set_font_color(Color(1, 1, 1, 1))
	coin_label.label_settings = label_settings


func change_weapon_button_icon_to(_name):
	weapon = Global.WEAPONS.get(_name)
	var tex := AtlasTexture.new()
	tex.atlas = load(weapon["icon_path"])
	
	tex.region = weapon["region"]
	if tex:
		weapon_button.texture_normal = tex
	else:
		push_warning("Could not load weapon icon: %s" % weapon["icon_path"])

func show_box(box):
	if box == "treasure":
		if dpad.is_layout_editing():
			return
		data = Global.load_data()
		_player = data.get("player", {})
		hearts = int(_player.get("max_hearts", 3))
		knowledge_scrape = int(_player.get("knowledge_scrape", 0))
		active_weapon = _player.get("active_weapon", "pensil")
		enchantments = _player.get("enchantments_purchased", [])
		obtained_weapon =  _player.get("obtained_weapons", [])
		
		heart_count.text = str(hearts)
		change_weapon_button_icon_to(active_weapon)
		
		knowledge_scrape_value.text = str(knowledge_scrape)
		
		weapon_showcase.hide()
		ball_pen.set_process_input(obtained_weapon.has("ball_pen"))
		if !obtained_weapon.has("ball_pen"):
			ball_pen.modulate = Color(1, 1, 1, 0.5)
		if !obtained_weapon.has("fountain_pen"):
			fountain_pen.modulate = Color(1, 1, 1, 0.5)
		if !obtained_weapon.has("pensil"):
			pensil.modulate = Color(1, 1, 1, 0.5)
			
		if enchantments != null and enchantments != []:
			for child in enchantments_box.get_children():
				child.queue_free()
			showcase_nodes.clear()
			var current_config: Array = _get_current_enchantment_config()
			for enchantment in enchantments:
				print(enchantment)
				for i in Global.POTIONS_AND_ENCHANTMENTS["ordinary"]:
					if i["id"] == enchantment:
						var node = item_showcase.instantiate()
						var tex := AtlasTexture.new()
						var _region = i["region"]
						var icon_path = "res://assets/potions and enchantments and weapons.png"
						tex.atlas = load(icon_path)
						tex.region = _region
						if tex:
							node.tex = tex
							var is_ignored := _is_ignored_item(String(i["id"]))
							var is_selected := current_config.has(i["id"]) or is_ignored
							if is_selected:
								node.set_display_text(i["name"] + " ✓")
							else:
								node.set_display_text(i["name"])
							node.set_interactive(not is_ignored)
							node.id = i["id"]
							enchantments_box.add_child(node)
							showcase_nodes[i["id"]] = node
						break
			if is_instance_valid(get_tree()):
				await get_tree().process_frame
			enchantments_box.queue_sort()
		treasure_box.show()
	if box == "pause":
		if dpad.is_layout_editing():
			return
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
	if dpad.is_layout_editing():
		return
	button_pressed.emit("treasure")


func _on_cross_released() -> void:
	button_pressed.emit("treasure_close")

func _on_text_btn_pressed(id):
	# Pause-menu actions are unavailable while a player is dragging touch controls.
	if dpad.is_layout_editing():
		return
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
	elif id == 8:
		_toggle_layout_editing()
	


func _on_touch_screen_button_2_released() -> void:
	if not dpad.is_layout_editing():
		button_pressed.emit("pause")


func _on_weapon_button_released() -> void:
	if not showcase_visible:
		weapon_showcase.show()
		showcase_visible = true
	else:
		weapon_showcase.hide()
		showcase_visible = false

func _equip_weapon(weapon_id: String) -> void:
	if not obtained_weapon.has(weapon_id):
		return

	active_weapon = weapon_id
	weapon = Global.WEAPONS.get(weapon_id, {})
	_player["active_weapon"] = weapon_id
	data["player"] = _player
	Global.save_data(data)
	change_weapon_button_icon_to(active_weapon)
	Global.Player_weapon_changed.emit(active_weapon)
	weapon_showcase.hide()
	showcase_visible = false


func _on_pensil_released() -> void:
	_equip_weapon("pensil")

func _on_ball_pen_released() -> void:
	_equip_weapon("ball_pen")

func _on_fountain_pen_released() -> void:
	_equip_weapon("fountain_pen")
