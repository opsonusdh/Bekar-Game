extends Node2D

@export var player :CharacterBody2D
@export var camZone0 :PhantomCamera2D
@export var camZone1 :PhantomCamera2D
@export var camZone2 :PhantomCamera2D
var current_cam_zone := 0


func update_current_zone(body, zone_a, zone_b):
	if body == player:
		match current_cam_zone:
			zone_a:
				current_cam_zone = zone_b
			zone_b:
				current_cam_zone = zone_a
		update_cam()

func update_cam():
	var cams = [camZone0, camZone1, camZone2]
	for i in cams:
		if i != null:
			i.priority = 0
	cams[current_cam_zone].priority = 1

func _on_zone_01_body_entered(body: Node2D) -> void:
	update_current_zone(body, 0, 1)

func _on_zone_01_body_exited(body: Node2D) -> void:
	update_current_zone(body, 0, 1)
