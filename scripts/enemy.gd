class_name Enemy
extends CharacterBody2D

signal give_player_damage(amt)

@export var health := 100
@export var speed := 100
@export var damage := 1

func take_damage(amount):
	health -= amount
	if health <= 0:
		die()

func die():
	queue_free()

func attack():
	pass

func move():
	pass

func _ready():
	pass
	
func _physics_process(delta):
	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()

		if body.is_in_group("player"):
			body.take_damage(damage)
