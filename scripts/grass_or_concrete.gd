extends Area2D

signal on_grass(TorF: bool)
# Called when the node enters the scene tree for the first time.



func _on_body_entered(body: Node2D) -> void:
	if body.name == "CharacterBody2D":
		on_grass.emit(true)


func _on_body_exited(body: Node2D) -> void:
	if body.name == "CharacterBody2D":
		on_grass.emit(false)
		
