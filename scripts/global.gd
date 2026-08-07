## Global singleton (autoload).
##
## Stores game-wide constants, default save data, item definitions,
## and helper methods for saving/loading persistent data.
##
## Responsibilities:
## - Manage save file serialization.
## - Store default player/game data.
## - Store potion, weapon and enchantment metadata.
## - Broadcast global signals.
##
## Functions:
## - [method save_data]
## - [method load_data]
## - [method notify_player_coin_changed]
##
## Signals:
## - [signal Player_coin_changed]
##
## Constants:
## - [constant DEBUG]
## - [constant SAVE_PATH]
## - [constant POTIONS_AND_ENCHANTMENTS]
## - [constant GLOBAL_FILE_TEMPLATE]
##
## Example:
## ```gdscript
## var data = Global.load_data()
## data["player"]["max_hearts"] += 1
## Global.save_data(data)
## ```
extends Node

## Enables additional debugging features.
##
## Intended for development builds only.
const DEBUG = true

## Default location of the save file.
##
## Uses Godot's `user://` directory so it works across platforms.
const SAVE_PATH := "user://savegame.json"


## Emitted whenever the player's Knowledge Scrap (coin) amount changes.
##
## [param new_amount] The updated amount.
signal Player_coin_changed(new_amount)
signal Player_weapon_changed(new_weapon)
signal showcase_item_touched(id: String)

## List containing every obtainable potion, weapon and enchantment.
##
## Each entry contains display information used by the inventory,
## shop and UI systems.
##
## Common fields:
## - `name`
## - `desc`
## - `info`
## - `region`
## - `scale`
##
## The `"Advanced"` entry contains unlockable abilities instead of
## regular items.
const POTIONS_AND_ENCHANTMENTS := {
	"ordinary": [
		{
			"name": "Heart Potion",
			"id": "heart",
			"desc": "Increases heart by one.",
			"info": "heart + 1",
			"region": Rect2(Vector2(177, 46), Vector2(131, 189)),
			"scale": Vector2(0.5, 0.5),
			"price": 5
		},
		{
			"name": "Ballpoint Pen",
			"id": "ball_pen",
			"desc": "Pen but not the regular one.",
			"info": "shooting speed + 50%",
			"region": Rect2(Vector2(153, 287), Vector2(261, 435)),
			"scale": Vector2(0.5, 0.5),
			"price": 10
		},
		{
			"name": "Fountain Pen",
			"id": "fountain_pen",
			"desc": "Let them be wet in ink.",
			"info": "damage + 200%, shooting speed - 10%",
			"region": Rect2(Vector2(544, 277), Vector2(284, 422)),
			"scale": Vector2(0.5, 0.5),
			"price": 15
		},
		{
			"name": "Accuracy",
			"id": "accuracy",
			"desc": "Increases accuracy of your projectiles.",
			"info": "accuracy + 100%, shooting speed - 20%",
			"region": Rect2(Vector2(963, 8), Vector2(221, 334)),
			"scale": Vector2(0.5, 0.5),
			"price": 30
		},
		{
			"name": "Multishot",
			"id": "multishot",
			"desc": "shoots three projectiles at once.",
			"info": "projectiles = 3, range - 10%",
			"region": Rect2(Vector2(1205, 8), Vector2(225, 334)),
			"scale": Vector2(0.5, 0.5),
			"price": 30
		},
	],
	"advanced": [
		{
			"name": "Geometry Slash",
			"id": "geometry_slash",
			"desc": "Deals damage while falling on an enemy",
			"info": "Defeat math teacher to get this."
		},
		{
			"name": "Grammer Storm",
			"id": "grammer_storm",
			"desc": "Deals damage on enemies present within a specific range",
			"info": "Defeat english teacher to get this."
		},
		{
			"name": "Gravity Magic",
			"id": "gravity_magic",
			"desc": "Lets you dash mid air defying gravity",
			"info": "Defeat physics teacher to get this."
		},
		{
			"name": "Acid Bomb",
			"id": "acid_bomb",
			"desc": "Let you throw a bomb of acid that deals damage, even to you.",
			"info": "Defeat chemistry teacher to get this."
		},
		{
			"name": "Brain Manupulation",
			"id": "brain_manipulation",
			"desc": "Enemies will attack themselves for a while.",
			"info": "Defeat Biology teacher to get this."
		},
	],
	"connections": {
		"weapon_enhancements": {
			"max": 1,
			"connected": ["accuracy", "multishot"]
		},
		"advanced_enhancements": {
			"max": 2,
			"connected": ["geometry_slash", "grammer_storm", "gravity_magic", "acid_bomb", "brain_manipulation"]
		},
		"ignore":["heart"]
	},
}

const WEAPONS := {
	"pensil": {
		"damage": 1.0,
		"disappear_time": 0.2,
		"icon_path": "res://assets/potions and enchantments and weapons.png",
		"region": Rect2(Vector2(852, 402), Vector2(265, 320)),
		"name": "Pensil",
		"scale": 0.03,
		"scene_path": "res://scenes/pensil.tscn",
		"shooting_speed": 1000.0,
		"shootout_cooldown": 0.3
	},
	"ball_pen": {
		"damage": 1.0,
		"disappear_time": 0.2,
		"icon_path": "res://assets/potions and enchantments and weapons.png",
		"region": Rect2(Vector2(153, 287), Vector2(261, 435)),
		"name": "Ball Point Pen",
		"scale": 0.03,
		"scene_path": "res://scenes/ball_pen.tscn",
		"shooting_speed": 1000.0,
		"shootout_cooldown": 0.2
	},
	"fountain_pen": {
		"damage": 3.0,
		"disappear_time": 0.2,
		"icon_path": "res://assets/potions and enchantments and weapons.png",
		"region": Rect2(Vector2(544, 277), Vector2(284, 422)),
		"name": "Fountain Pen",
		"scale": 0.03,
		"scene_path": "res://scenes/fountain_pen.tscn",
		"shooting_speed": 1000.0,
		"shootout_cooldown": 0.3
	},
}

const PLAYER_INIT_DATA := {
	"obtained_weapons": ["pensil"],
	"active_weapon": "pensil",
	"completed_tutorial": false,
	"max_hearts": 3,
	"jump_velocity": -600.0,
	"knowledge_scraps": 0,
	"speed": 300.0,
	"enchantments_purchased": [],
	"current_enchantment_config": [],
}

## Default save file template.
##
## This dictionary represents the initial save data that will be
## written for a brand-new player.
##
## Sections:
## - `levels_completed`
## - `player`
## - `game`

const GLOBAL_FILE_TEMPLATE := {
	"levels_completed": {},
	"player": PLAYER_INIT_DATA,
}

const INSUFFICIENT_BALANCE_COLOR = Color(1, 0, 0, 1)
const JUMP_BUFFER_TIME = 0.2

## Saves game data as formatted JSON.
##
## [param data] Dictionary to save.
## [param file_path] Optional destination path. Defaults to
## [constant SAVE_PATH].
##
## Existing save data will be overwritten.
func save_data(data: Dictionary, file_path: String = SAVE_PATH) -> void:
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		push_error("Couldn't open save file.")
		return

	file.store_var(data)
	file.close()

## Loads save data from disk.
##
## [param file_path] Save file location.
##
## Returns:
## - Parsed save dictionary on success.
## - Empty dictionary (`{}`) if loading or parsing fails.
##
## The caller should validate missing fields if supporting
## save-file version upgrades.
func load_data(file_path: String = SAVE_PATH) -> Dictionary:
	if !FileAccess.file_exists(file_path):
		return GLOBAL_FILE_TEMPLATE.duplicate(true)

	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Couldn't open save file.")
		return {}

	var data = file.get_var()
	file.close()

	if data is Dictionary:
		return data

	push_error("Invalid save file.")
	return {}


## Emits the global [signal Player_coin_changed] signal.
##
## Call this after modifying the player's Knowledge Scrap amount so
## UI elements can update automatically.
##
## [param new_amount] The player's new total.
func notify_player_coin_changed(new_amount: int) -> void:
	Player_coin_changed.emit(new_amount)
	
func variant_to_json(value):
	match typeof(value):
		TYPE_RECT2:
			return {
				"__type": "Rect2",
				"x": value.position.x,
				"y": value.position.y,
				"w": value.size.x,
				"h": value.size.y
			}

		TYPE_VECTOR2:
			return {
				"__type": "Vector2",
				"x": value.x,
				"y": value.y
			}

		TYPE_DICTIONARY:
			var out := {}
			for k in value:
				out[k] = variant_to_json(value[k])
			return out

		TYPE_ARRAY:
			var out := []
			for v in value:
				out.append(variant_to_json(v))
			return out

		_:
			return value


func json_to_variant(value):
	if value is Dictionary:
		if value.has("__type"):
			match value["__type"]:
				"Rect2":
					return Rect2(
						value["x"],
						value["y"],
						value["w"],
						value["h"]
					)

				"Vector2":
					return Vector2(
						value["x"],
						value["y"]
					)

		var out := {}
		for k in value:
			out[k] = json_to_variant(value[k])
		return out

	if value is Array:
		var out := []
		for v in value:
			out.append(json_to_variant(v))
		return out

	return value
