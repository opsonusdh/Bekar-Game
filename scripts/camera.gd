extends Sprite2D

@onready var camera_2d: Camera2D = $Camera2D
@onready var player: CharacterBody2D = $"../CharacterBody2D"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.position_changed.connect


func _on_player_position_changed(position: Vector2) -> void:
	pass # Replace with function body.


func _on_character_body_2d_position_changed(position: Vector2) -> void:
	pass # Replace with function body.
