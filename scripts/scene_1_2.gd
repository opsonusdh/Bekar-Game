extends Node2D

@onready var player: CharacterBody2D = $CharacterBody1D
@onready var interractable_area_2d: Area2D = $Interractable_Area2D
@onready var phantom_camera_2d: PhantomCamera2D = $PhantomCamera2D
@onready var phantom_camera_2d_2: PhantomCamera2D = $PhantomCamera2D2

var player_in_desk = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interract") and player_in_desk:
		phantom_camera_2d.priority = 0
		phantom_camera_2d_2.priority = 1
		player.animation_player.play("make_invisible", -1, 2)




func _on_interractable_area_2d_body_entered(body: Node2D) -> void:
	if body == player:
		interractable_area_2d.highlight(true)
		player_in_desk = true


func _on_interractable_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		interractable_area_2d.highlight(false)
		player_in_desk = false
