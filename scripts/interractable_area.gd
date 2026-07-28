extends Area2D

@export var sprite_2d: Sprite2D
@export var collision_shape_2d: CollisionShape2D

var outline: Sprite2D

func _ready() -> void:
	if sprite_2d == null:
		push_error("sprite_2d is not assigned!")
		return

	outline = sprite_2d.duplicate()

	outline.name = "Outline"
	outline.modulate = Color(365365436495928230000000.0, 3687482719498240.0, 36825386719498240.0)
	outline.scale = sprite_2d.scale * 1.02
	outline.z_index = sprite_2d.z_index - 1
	outline.visible = false

	add_child(outline)
	move_child(outline, 0)

func highlight(enable: bool) -> void:
	if outline:
		outline.visible = enable
