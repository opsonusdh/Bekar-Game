extends Area2D

@export var is_hostile := true
@export var velocity := Vector2.ZERO
@export var damage := 1
@export var disappear_time = 0.0



@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var group_areas = ["wall", "path", "obstacle"]
var hostile_bodies = []
var non_hostile_bodies = []

func _ready():
	if disappear_time != 0:
		start_disappear_countdown(disappear_time)


func start_disappear_countdown(countdown_time: float) -> void:
	await get_tree().create_timer(countdown_time).timeout
	queue_free()


func change_sprite_dir():
	if velocity != Vector2.ZERO:
		rotation = velocity.angle() + PI


func _physics_process(delta):
	global_position += velocity * delta


func _on_body_entered(body: Node2D) -> void:
	if is_hostile:
		for group in non_hostile_bodies:
			if body.is_in_group(group):
				body.take_damage(damage)
				queue_free()
	else:
		for group in hostile_bodies:
			if body.is_in_group(group):
				body.take_damage(damage)
				queue_free()
	


func _on_area_entered(area: Area2D) -> void:
	for group in group_areas:
		if area.is_in_group(group):
			queue_free()
