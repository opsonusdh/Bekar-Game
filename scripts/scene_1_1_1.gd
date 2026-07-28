extends Node2D

@onready var player: CharacterBody2D = $player
@onready var interractable_area_2d: Area2D = $Interractable_Area2D
@onready var curtain: Area2D = $curtain
@onready var control: Node2D = $CanvasLayer/control
@onready var current_scene = get_tree().current_scene.scene_file_path

var player_in_interractable_door = false
const BALL_SCENE = preload("res://scenes/ball.tscn")
var data = Global.load_data()

var checkpoint = Vector2(0, -32)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.edit_attrs("jump_velocity_factor", 0.6667)
	make_all_buttons_opacity(0.5)
	

func give_player_damage(amt):
	player.take_damage(amt)

func make_all_buttons_opacity(opacity) -> void:
	control.change_opacity(control.ButtonType.UP, opacity)
	control.change_opacity(control.ButtonType.DOWN, opacity)
	control.change_opacity(control.ButtonType.LEFT, opacity)
	control.change_opacity(control.ButtonType.RIGHT, opacity)
	control.change_opacity(control.ButtonType.POS_LOCK, opacity)
	control.change_opacity(control.ButtonType.JUMP, opacity)
	control.change_opacity(control.ButtonType.CROUCH, opacity)
	control.change_opacity(control.ButtonType.FIRE, opacity)
	control.change_opacity(control.ButtonType.INTERACT, opacity)

func _on_checkpt_body_entered(body: Node2D) -> void:
	if body == player:
		checkpoint = Vector2(672, -48)
		mark_btns([control.ButtonType.FIRE, control.ButtonType.UP, control.ButtonType.DOWN, control.ButtonType.POS_LOCK])


func _on_checkpt_2_body_entered(body: Node2D) -> void:
	if body == player:
		checkpoint = Vector2(1088, -64)
		mark_btns([control.ButtonType.CROUCH])

func _on_killzone_body_entered(body: Node2D) -> void:
	player.global_position = checkpoint


func _on_player_player_died() -> void:
	player.health = 3
	player.global_position = checkpoint




func _on_area_2d_body_entered(body):
	if body == player:
		for i in range(5):
			var ball = BALL_SCENE.instantiate()
			ball.velocity = Vector2(-70, 0)
			ball.non_hostile_bodies.append("player")
			ball.disappear_time = 5
			ball.global_position = Vector2(1304, -120 - i * 24)

			add_child(ball)


func _on_interractable_area_2d_body_entered(body: Node2D) -> void:
	if body == player:
		interractable_area_2d.highlight(true)
		player_in_interractable_door = true
		mark_btns([control.ButtonType.INTERACT])


func _on_interractable_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		interractable_area_2d.highlight(false)
		player_in_interractable_door = false


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interract"):
		if player_in_interractable_door:
			await curtain.play_animation(curtain.FADEIN)
			var data = Global.load_data()
			var _player = data.get("player", {})
			_player["completed_tutorial"] = true
			_player["health"] = _player.get("health", 3)
			_player["speed"] = _player.get("speed", 300)
			_player["jump_velocity"] = _player.get("jump_velocity", -600)
			_player["active_weapon"] = _player.get(
				"active_weapon",
				{
					"name": "pensil", 
					"damage": 1, 
					"icon_path": "res://assets/pensil.png", 
					"scene_path": "res://scenes/pensil.tscn", 
					"shootout_cooldown": 0.2, 
					"disappear_time": 0.5, 
					"shooting_speed": 100, 
					"scale": 0.03
				}
			)
			
			var _levels_completed = data.get("levels_completed", {})
			_levels_completed[current_scene] = _levels_completed.get(current_scene, {})
			_levels_completed[current_scene]["score"] = _levels_completed[current_scene].get("score", 0)
			
			var player_health = player.health
			if player_health > 3:
				player_health = 3
			if player_health > _levels_completed[current_scene]["score"]:
				var old_score = _levels_completed[current_scene]["score"]
				_levels_completed[current_scene]["score"] = player_health
				_player["knowledge_scraps"] = _player.get("knowledge_scraps", 0) + player_health - old_score
			
			data["levels_completed"] = _levels_completed
			data["player"] = _player
			
			Global.save_data(data)
			get_tree().change_scene_to_file("res://scenes/scene_1_1.tscn")

func mark_btns(lis):
	for i in lis:
		control.change_opacity(i, 1)

func _on_move_helper_body_entered(body: Node2D) -> void:
	if body == player:
		mark_btns([control.ButtonType.LEFT, control.ButtonType.RIGHT])

func _on_help_jump_body_entered(body: Node2D) -> void:
	if body == player:
		mark_btns([control.ButtonType.JUMP])
