extends Level

const BALL_SCENE = preload("res://scenes/ball.tscn")

@onready var interractable_area_2d: Area2D = $Interractable_Area2D

var player_in_interractable_door := false

func _ready() -> void:
	super._ready()
	player.edit_attrs("jump_velocity_factor", 0.6667)
	player.edit_attrs("shoot_factor", 1)
	make_all_buttons_opacity(0.5)

func _before_level_completed(player_data: Dictionary) -> void:
	player_data["completed_tutorial"] = true
	player_data["max_hearts"] = player_data.get("max_hearts", 3)
	player_data["speed"] = player_data.get("speed", 300)
	player_data["jump_velocity"] = player_data.get("jump_velocity", -600)
	player_data["active_weapon"] = player_data.get("active_weapon", "pensil")

func give_player_damage(amount) -> void:
	player.take_damage(amount)

func make_all_buttons_opacity(opacity: float) -> void:
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
		set_checkpoint(Vector2(672, -48))
		mark_btns([control.ButtonType.FIRE, control.ButtonType.UP, control.ButtonType.DOWN, control.ButtonType.POS_LOCK])

func _on_checkpt_2_body_entered(body: Node2D) -> void:
	if body == player:
		set_checkpoint(Vector2(1088, -64))
		mark_btns([control.ButtonType.CROUCH])

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player:
		for index in range(5):
			var ball = BALL_SCENE.instantiate()
			ball.velocity = Vector2(-70, 0)
			ball.non_hostile_bodies.append("player")
			ball.disappear_time = 5
			ball.global_position = Vector2(1304, -120 - index * 24)
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

func _process(_delta: float) -> void:
	if player_in_interractable_door and Input.is_action_just_pressed("interract"):
		await level_pass()

func mark_btns(buttons: Array) -> void:
	for button in buttons:
		control.change_opacity(button, 1.0)

func _on_move_helper_body_entered(body: Node2D) -> void:
	if body == player:
		mark_btns([control.ButtonType.LEFT, control.ButtonType.RIGHT])

func _on_help_jump_body_entered(body: Node2D) -> void:
	if body == player:
		mark_btns([control.ButtonType.JUMP])
