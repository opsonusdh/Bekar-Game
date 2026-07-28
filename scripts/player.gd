extends CharacterBody2D

const SPEED = 150.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var move_msg: Node2D = $"../in game messages/banner"
@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var sound_grass = preload("res://audio/running on grass.mp3")
var sound_conc = preload("res://audio/running.mp3")
var last_dir = "walking-down"
func _ready() -> void:
	audio_stream_player.stream = sound_conc

func _physics_process(_delta: float) -> void:
	var direction := Vector2(
			Input.get_axis("go left", "go right"),
			Input.get_axis("go up", "go down")
		)
	#checking if the character is moving in only one dir
	if direction and not (abs(direction.x) == abs(direction.y)):
		if move_msg:
			move_msg.queue_free() # remove the movement hint
		velocity = direction * SPEED
		if not audio_stream_player.playing:
			audio_stream_player.play()
		
		# for mobile, to take the max(magnitude) 
		# not needed, but afraid to fix
		
		# if x is major
		if abs(direction.x) > abs(direction.y):
			velocity.y = 0
			if velocity.x > 0:
				animated_sprite.play("walking-right")
				animated_sprite.flip_h = false
				last_dir = "walking-right"
			if velocity.x < 0:
				animated_sprite.play("walking-right")
				animated_sprite.flip_h = true
				last_dir = "walking-left"
		
		# if y is major
		elif abs(direction.x) < abs(direction.y):
			velocity.x = 0
			if velocity.y > 0:
				animated_sprite.play("walking-down")
				last_dir = "walking-down"
			if velocity.y < 0:
				animated_sprite.play("walking-up")
				last_dir = "walking-up"
		
		# if both are same = dont go anywhere
		else:
			velocity = Vector2(0, 0)
	
	#no input of direction
	else:
		# stop the footprint immediately
		audio_stream_player.stop()
		# animating the idle character based on the direction
		
		# left = inverse(right)
		if last_dir == "walking-left":
			animated_sprite.play("walking-right")
			animated_sprite.flip_h = true
		else:
			animated_sprite.play(last_dir)
		animated_sprite.stop()
		animated_sprite.frame = 0
		
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	# This one line handles all collisions and sliding. 
	move_and_slide()


func _on_checking_if_on_grass_on_grass(TorF: bool) -> void:
	if TorF == true:
		audio_stream_player.stream = sound_grass
	else:
		audio_stream_player.stream = sound_conc
	audio_stream_player.stop()
