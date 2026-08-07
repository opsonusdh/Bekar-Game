extends Node2D

@onready var player: CharacterBody2D = $CharacterBody1D
@onready var interractable_area_2d: Area2D = $Interractable_Area2D
@onready var phantom_camera_2d: PhantomCamera2D = $PhantomCamera2D
@onready var phantom_camera_2d_2: PhantomCamera2D = $PhantomCamera2D2
@onready var pen_sprite_2d: Sprite2D = $"potions and enchantments/pens/Sprite2D"
@onready var on_screen_btns: CanvasLayer = $on_screen_btns
@onready var cross: TouchScreenButton = $"potions and enchantments/cross"
@onready var pens: Area2D = $"potions and enchantments/pens"
@onready var enchantments: Area2D = $"potions and enchantments/enchantments"
@onready var multishot: Area2D = $"potions and enchantments/books/multishot"
@onready var accuracy: Area2D = $"potions and enchantments/books/accuracy"
@onready var potion: Area2D = $"potions and enchantments/potion"
@onready var price: Label = $"potions and enchantments/data vis/price section/price"
@onready var heading: Label = $"potions and enchantments/data vis/heading"
@onready var image: Sprite2D = $"potions and enchantments/data vis/image"
@onready var label: Label = $"potions and enchantments/data vis/Label"
@onready var data_vis: Node2D = $"potions and enchantments/data vis"
@onready var data_vis_animation_player: AnimationPlayer = $"potions and enchantments/data vis/AnimationPlayer"
@onready var porimal_babu_hand: Sprite2D = $"Interractable_Area2D/porimal babu hand"

var player_in_desk = false
var player_interracting_desk = false
var in_advance_section = false
var last_interact_time_msec := 0
const INTERACT_COOLDOWN_MSEC := 1000
const ADVANCE = Global.POTIONS_AND_ENCHANTMENTS["advanced"]
const ORDINARY = Global.POTIONS_AND_ENCHANTMENTS["ordinary"]

var data = Global.load_data()
var potions_enchantments: Array[String] = ["heart", "ball_pen", "fountain_pen", "accuracy", "multishot", "enchantments"]
var ind := 0
var highlight_targets: Dictionary
var player_data: Dictionary = data.get("player", {})
var image_rect_size = Vector2(50, 50)
var current_list_mode := "ordinary"
var advanced_item_ids: Array[String] = []


func _reset_shop_item_visibility() -> void:
	if is_instance_valid(potion):
		potion.show()
	if is_instance_valid(accuracy):
		accuracy.show()
	if is_instance_valid(multishot):
		multishot.show()
	if is_instance_valid(pens):
		pens.show()
	if is_instance_valid(enchantments):
		enchantments.show()

func make_trade_look():
	porimal_babu_hand.texture.region = Rect2(Vector2(1138, 309), Vector2(171, 435))
	porimal_babu_hand.position = Vector2(89, 16)
	await get_tree().create_timer(1).timeout
	porimal_babu_hand.texture.region = Rect2(Vector2(1328, 285), Vector2(266, 291))
	porimal_babu_hand.position = Vector2(59.595, 49)
	
	
func refresh_shop() -> void:
	data = Global.load_data()
	player_data = data.get("player", {})
	if not player_data.has("obtained_weapons") or not player_data["obtained_weapons"] is Array:
		player_data["obtained_weapons"] = []
	if not player_data.has("enchantments_purchased") or not player_data["enchantments_purchased"] is Array:
		player_data["enchantments_purchased"] = []

	_reset_shop_item_visibility()
	potions_enchantments = ["heart", "ball_pen", "fountain_pen", "accuracy", "multishot", "enchantments"]

	var player_obtained_weapon: Array = Array(player_data.get("obtained_weapons", []))
	var player_enchantments: Array = Array(player_data.get("enchantments_purchased", []))

	if player_enchantments.has("heart"):
		potions_enchantments.erase("heart")
		potion.hide()

	if player_enchantments.has("accuracy"):
		potions_enchantments.erase("accuracy")
		accuracy.hide()

	if player_enchantments.has("multishot"):
		potions_enchantments.erase("multishot")
		multishot.hide()

	if player_obtained_weapon.has("ball_pen") and player_obtained_weapon.has("fountain_pen"):
		pens.hide()
		potions_enchantments.erase("ball_pen")
		potions_enchantments.erase("fountain_pen")
	elif player_obtained_weapon.has("ball_pen"):
		change_pen_atlas("fountain")
		potions_enchantments.erase("ball_pen")
	elif player_obtained_weapon.has("fountain_pen"):
		change_pen_atlas("ball")
		potions_enchantments.erase("fountain_pen")
	else:
		change_pen_atlas("both")

	advanced_item_ids = []
	for item in ADVANCE:
		advanced_item_ids.append(item["id"])

	if current_list_mode == "advanced":
		potions_enchantments = Array(advanced_item_ids)

	_configure_item_outlines()
	if player_interracting_desk:
		_select_current_item()
	else:
		remove_highlight()
	
func _ready() -> void:
	data_vis.hide()
	highlight_targets = {"heart": potion, "ball_pen": pens, "fountain_pen": pens, "accuracy": accuracy, "multishot": multishot, "enchantments": enchantments}
	refresh_shop()
	
	if !on_screen_btns.dpad.left.released.is_connected(_on_left_released):
		on_screen_btns.dpad.left.released.connect(_on_left_released)
	if !on_screen_btns.dpad.right.released.is_connected(_on_right_released):
		on_screen_btns.dpad.right.released.connect(_on_right_released)
	if !on_screen_btns.dpad.interract.released.is_connected(_on_interract_released):
		on_screen_btns.dpad.interract.released.connect(_on_interract_released)

func remove_highlight() -> void:
	for key in highlight_targets.keys():
		if key not in potions_enchantments:
			continue

		var target = highlight_targets[key]
		if is_instance_valid(target):
			_set_highlight(target, false)

func add_highlight(item_id: String) -> void:
	var target = highlight_targets.get(item_id)
	if target is Area2D and is_instance_valid(target):
		_set_highlight(target, true)

func _configure_item_outlines() -> void:
	for target in highlight_targets.values():
		if target is Area2D and is_instance_valid(target):
			var outline := target.get_node_or_null("Outline") as Sprite2D
			if outline:
				outline.z_index = 0

func _set_highlight(target: Area2D, enabled: bool) -> void:
	target.highlight(enabled)
	var outline := target.get_node_or_null("Outline") as Sprite2D
	if outline:
		outline.visible = enabled

func _get_item_data(item_id: String) -> Dictionary:
	if current_list_mode == "advanced":
		for item in ADVANCE:
			if item["id"] == item_id:
				return item
	for item in ORDINARY:
		if item["id"] == item_id:
			return item
	return {}


func _select_current_item() -> void:
	remove_highlight()
	if potions_enchantments.is_empty():
		return
	ind = posmod(ind, potions_enchantments.size())
	add_highlight(potions_enchantments[ind])
	
	if potions_enchantments[ind] == "enchantments":
		heading.text = "Advanced"
		label.text = "Press interact to see Ultra-Power"
		label.global_position = Vector2(-321, 91)
		label.size.x = 253
		price.text = "∞"
		price.label_settings.font_color = Global.INSUFFICIENT_BALANCE_COLOR
		image.hide()
		return
	
	var item_data: Dictionary = _get_item_data(potions_enchantments[ind])
	if item_data.is_empty():
		return
	
	if current_list_mode == "advanced":
		price.text = "∞"
		var price_labelsettings = price.label_settings
		price_labelsettings.set_font_color(Global.INSUFFICIENT_BALANCE_COLOR)
		heading.text = item_data.get("name", "Advanced")
		label.text = item_data.get("desc", "") + "\n" + item_data.get("info", "")
		label.global_position = Vector2(-376, 91)
		label.size.x = 308
		image.hide()
		return
	
	image.show()
	price.text = str(item_data["price"])
	var price_labelsettings = price.label_settings
	if player_data["knowledge_scraps"] < item_data["price"]:
		price_labelsettings.set_font_color(Global.INSUFFICIENT_BALANCE_COLOR)
	else:
		price_labelsettings.set_font_color(Color(1, 1, 1, 1))
	
	heading.text = item_data["name"]
	label.text = item_data["desc"] + "\n" + item_data["info"]
	var tex := AtlasTexture.new()
	var _region = item_data["region"]
	var icon_path = "res://assets/potions and enchantments and weapons.png"
	tex.atlas = load(icon_path)
	
	tex.region = _region
	
	if tex:
		image.texture = tex
		
		if _region.size.x > _region.size.y:
			image.scale = Vector2.ONE*image_rect_size.x/_region.size.x
		else:
			image.scale = Vector2.ONE*image_rect_size.y/_region.size.y
	else:
		push_warning("Could not load weapon icon: %s" % icon_path)

		
	label.global_position = Vector2(-321, 91)
	label.size.x = 253


func _on_left_released() -> void:
	if potions_enchantments.is_empty() or !player_interracting_desk:
		return
	ind = posmod(ind - 1, potions_enchantments.size())
	_select_current_item()
	
func _on_right_released() -> void:
	if potions_enchantments.is_empty() or !player_interracting_desk:
		return
	ind = posmod(ind + 1, potions_enchantments.size())
	_select_current_item()
	

func _on_interract_released() -> void:
	var now_msec := Time.get_ticks_msec()
	if now_msec - last_interact_time_msec < INTERACT_COOLDOWN_MSEC:
		return
	last_interact_time_msec = now_msec

	if player_in_desk and !player_interracting_desk:
		phantom_camera_2d.priority = 0
		phantom_camera_2d_2.priority = 1
		player.animation_player.play("make_invisible", -1, 2)
		player_interracting_desk = true
		cross.show()
		player.movable = false
		player.is_shooting = false
		imp_buttons_visible(false)
		ind = 0
		_select_current_item()
		on_screen_btns.dpad.modulate = Color(1, 1, 1, 0.5)
		data_vis.show()
		interractable_area_2d.highlight(false)
		data_vis_animation_player.play("fadein")
	
	elif player_in_desk and player_interracting_desk:
		if potions_enchantments.is_empty() or ind < 0 or ind >= potions_enchantments.size():
			return

		var selected_item_id := potions_enchantments[ind]
		if selected_item_id == "enchantments":
			current_list_mode = "advanced"
			potions_enchantments = Array(advanced_item_ids)
			ind = 0
			_select_current_item()
			return
		
		if current_list_mode == "advanced":
			data_vis_animation_player.play("insufficient_balance")
			return
			
		for i in ORDINARY:
			if i["id"] != selected_item_id:
				continue

			if i["price"] <= int(player_data.get("knowledge_scraps", 0)):
				if i["id"] in ["ball_pen", "fountain_pen"]:
					if not player_data["obtained_weapons"].has(i["id"]):
						player_data["obtained_weapons"].append(i["id"])
				else:
					if not player_data["enchantments_purchased"].has(i["id"]):
						player_data["enchantments_purchased"].append(i["id"])
				player_data["knowledge_scraps"] = int(player_data.get("knowledge_scraps", 0)) - i["price"]
				if i["id"] == "heart":
					player_data["max_hearts"] += 1
				if Global.POTIONS_AND_ENCHANTMENTS["connections"]["ignore"].has(i["id"]):
					if not player_data["current_enchantment_config"].has(i["id"]):
						player_data["current_enchantment_config"].append(i["id"])
				else:
					for j in Global.POTIONS_AND_ENCHANTMENTS["connections"].keys():
						if j == "ignore":
							continue
						var k = Global.POTIONS_AND_ENCHANTMENTS["connections"][j]
						if k["connected"].has(i["id"]):
							var n = 0
							var last_seens = []
							for m in range(len(player_data["current_enchantment_config"])):
								if k["connected"].has(player_data["current_enchantment_config"][m]):
									n += 1
									last_seens.append(m)
							last_seens.reverse()
							if n >= k["max"]:
								var o = n+1 - k["max"]
								for p in range(o):
									player_data["current_enchantment_config"].remove_at(last_seens[p])
							if not player_data["current_enchantment_config"].has(i["id"]):
								player_data["current_enchantment_config"].append(i["id"])
							break
					
				Global.Player_coin_changed.emit(player_data["knowledge_scraps"])
				data["player"] = player_data
				Global.save_data(data)
				make_trade_look()
				refresh_shop()
			else:
				data_vis_animation_player.play("insufficient_balance")
			break


func imp_buttons_visible(x: bool) -> void:
	if !x:
		on_screen_btns.dpad_top_visible = false
		on_screen_btns.dpad_bottom_visible = false
		on_screen_btns.dpad_pos_lock_visible = false
		on_screen_btns.dpad_jump_visible = false
		on_screen_btns.dpad_crouch_visible = false
		on_screen_btns.dpad_fire_visible = false
		on_screen_btns.dpad_passby_press = false
	else:
		on_screen_btns.dpad_top_visible = true
		on_screen_btns.dpad_bottom_visible = true
		on_screen_btns.dpad_pos_lock_visible = true
		on_screen_btns.dpad_jump_visible = true
		on_screen_btns.dpad_crouch_visible = true
		on_screen_btns.dpad_fire_visible = true
		on_screen_btns.dpad_passby_press = true

	on_screen_btns.apply_configuration()


func _on_interractable_area_2d_body_entered(body: Node2D) -> void:
	if body == player:
		interractable_area_2d.highlight(true)
		player_in_desk = true


func _on_interractable_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		interractable_area_2d.highlight(false)
		player_in_desk = false

func change_pen_atlas(pen_type: String) -> void:
	var atlas = pen_sprite_2d.texture as AtlasTexture
	if pen_type == "both":
		atlas.region = Rect2(15, 13, 111, 234)
	elif pen_type == "ball":
		atlas.region = Rect2(414, 5, 109, 254)
	elif pen_type == "fountain":
		atlas.region = Rect2(627, 15, 108, 244)


func _on_on_screen_btns_button_pressed(button_type: String) -> void:
	match button_type:
		"pause":
			on_screen_btns.show_box("pause")
			get_tree().paused = true
		"treasure":
			on_screen_btns.show_box("treasure")
			get_tree().paused = true
		"treasure_close":
			on_screen_btns.hide_box("treasure")
			get_tree().paused = false
		"continue":
			get_tree().paused = false
			on_screen_btns.hide_box("pause")
		"restart":
			get_tree().paused = false
			get_tree().reload_current_scene()
			on_screen_btns.hide_box("restart")
			on_screen_btns.hide_box("pause")
		"quit":
			get_tree().paused = false
			get_tree().change_scene_to_file("res://scenes/loading.tscn")


func _on_cross_released() -> void:
	phantom_camera_2d.priority = 1
	phantom_camera_2d_2.priority = 0
	player.animation_player.play("make_invisible", -1, 2)
	player.animation_player.play("make_invisible", -1, -2)
	player_interracting_desk = false
	cross.hide()
	player.movable = true
	player.is_shooting = false
	imp_buttons_visible(true)
	current_list_mode = "ordinary"
	potions_enchantments = ["heart", "ball_pen", "fountain_pen", "accuracy", "multishot", "enchantments"]
	ind = -1
	refresh_shop()
	data_vis.hide()
	remove_highlight()
	interractable_area_2d.highlight(true)
	on_screen_btns.dpad.modulate = Color(1, 1, 1, 1)
