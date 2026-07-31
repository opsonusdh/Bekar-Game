## An interactable Area2D that can display a simple outline highlight.
##
## This script duplicates the assigned Sprite2D to create an outline sprite.
## The outline is slightly larger than the original sprite and is hidden by
## default. Call [method highlight] to show or hide it.
##
## Example:
## ```gdscript
## if player_near:
##     chest.highlight(true)
## else:
##     chest.highlight(false)
## ```
extends Area2D

@export var sprite_2d: Sprite2D
@export var collision_shape_2d: CollisionShape2D
@export var shadow_scale := 1.02

var outline: Sprite2D

func _ready() -> void:
	if sprite_2d == null:
		push_error("sprite_2d is not assigned!")
		return

	outline = sprite_2d.duplicate()

	outline.name = "Outline"
	outline.modulate = Color(365365436495928230000000.0, 3687482719498240.0, 36825386719498240.0)
	outline.scale = sprite_2d.scale * shadow_scale
	outline.z_index = sprite_2d.z_index - 1

	add_child(outline)
	move_child(outline, 0)
	outline.hide()

## Enables or disables the outline.
##
## Parameters:
## - `enable`: If `true`, the outline becomes visible. If `false`, it is hidden.
##
## Example:
## ```gdscript
## door.highlight(true)
##
## await get_tree().create_timer(0.5).timeout
##
## door.highlight(false)
## ```
func highlight(enable: bool) -> void:
	if outline:
		if enable:
			outline.show()
		else:
			outline.hide()
