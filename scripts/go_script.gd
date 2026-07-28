extends Area2D
@onready var touch_screen_button: TouchScreenButton = $TouchScreenButton
var player_in := false
signal enter_btn_pressed

func _on_body_entered(body: Node2D) -> void:
	if body.name == "CharacterBody2D":
		player_in = true
		touch_screen_button.show()

func _on_body_exited(body: Node2D) -> void:
	if body.name == "CharacterBody2D":
		player_in = false
		touch_screen_button.hide()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		if player_in:
			enter_btn_pressed.emit()
