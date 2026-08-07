extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var shooting_point: Node2D = $"shooting point"
@onready var hurtbox: CollisionShape2D = $hurtbox/CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var movable := true
@export var jumpable := true
@export var shootable := true

signal player_died
#const DASH_SPEED = 600          #DASHING IS DISABLED NOW

var data = Global.load_data()
var _player = data.get("player", {})
var health = _player.get("max_hearts", 3)
var speed = _player.get("speed", 300)
var jump_velocity = _player.get("jump_velocity", -600)

var running_sound = preload("res://audio/running.mp3")
var jumping_sound = preload("res://audio/jump.mp3")
var grond_hit_sound = preload("res://audio/ground hit.mp3")


var speed_factor = 1
var jump_velocity_factor = 1
var shoot_factor = 1

var active_weapon = _player.get("active_weapon", "pensil")
var weapon = Global.WEAPONS[active_weapon]

var PROJECTILES = load(weapon["scene_path"])
var attr_dict = {
	"jump_velocity_factor": jump_velocity_factor,
	"speed_factor": speed_factor,
	"shoot_factor": shoot_factor
}

var was_falling = false
var is_falling = false
var is_rising = false
var is_jumping = false
var is_crowching = false
var is_shooting = false
var current_dir := 1.0
var cooldown := 0.0
var position_lock := false
var pos_factor = 1
var will_jump = true
var will_jump_within = 0
#var is_dashing = false

func _ready() -> void:
	Global.Player_weapon_changed.connect(_on_player_weapon_changed)
	
func _on_player_weapon_changed(new_weapon):
	active_weapon = new_weapon
	weapon = Global.WEAPONS[active_weapon]
	PROJECTILES = load(weapon["scene_path"])

func take_damage(amount):
	health -= amount
	if health <= 0:
		player_died.emit()


func teleport_to(new_position: Vector2) -> void:
	velocity = Vector2.ZERO # Stop all current momentum
	global_position = new_position
 
func edit_attrs(key, value) -> void:
	if key in attr_dict.keys():
		attr_dict[key] = value
	set(key, value)

func shoot(projectile_velocity: Vector2) -> void:
	var projectile = PROJECTILES.instantiate()

	projectile.global_position = shooting_point.global_position
	projectile.velocity = projectile_velocity
	projectile.hostile_bodies.append("enemy")
	projectile.scale = Vector2.ONE * weapon["scale"] * scale
	projectile.is_hostile = false
	projectile.disappear_time = weapon["disappear_time"]*scale.x
	projectile.change_sprite_dir()
	
	get_tree().current_scene.add_child(projectile)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var direction := Input.get_axis("go left", "go right")
	
	cooldown -= delta
	if is_shooting and cooldown <= 0 and shootable:
		var shoot_dir := Vector2(current_dir, 0)

		if position_lock:
			shoot_dir = Vector2.ZERO

			if Input.is_action_pressed("go right"):
				shoot_dir.x += 1
			if Input.is_action_pressed("go left"):
				shoot_dir.x -= 1
			if Input.is_action_pressed("go down"):
				shoot_dir.y += 1
			if Input.is_action_pressed("go up"):
				shoot_dir.y -= 1

			if shoot_dir == Vector2.ZERO:
				shoot_dir.x = current_dir

			shoot_dir = shoot_dir.normalized()
		
		shoot(shoot_dir * (shoot_factor * weapon["shooting_speed"]))
		cooldown = weapon["shootout_cooldown"]
	
	if is_on_floor() and is_jumping:
		is_jumping = false
#		is_dashing = false
		
	if will_jump:
		if is_on_floor() and will_jump_within > 0:
			velocity.y = jump_velocity*jump_velocity_factor
			is_rising = true
			is_jumping = true
			animated_sprite.play("jump")
			audio_stream_player.stop()
			audio_stream_player.stream = jumping_sound
			audio_stream_player.play(0.025)
		elif !is_on_floor() and will_jump_within > 0:
			will_jump_within -= delta
		elif will_jump_within <= 0:
			will_jump = false
			will_jump_within = 0
	# Handle jump.
	if Input.is_action_just_pressed("jump") and jumpable:
		if is_on_floor():
			velocity.y = jump_velocity*jump_velocity_factor
			is_rising = true
			is_jumping = true
			animated_sprite.play("jump")
			audio_stream_player.stream = jumping_sound
			audio_stream_player.play(0.025)
		else:
			will_jump = true
			will_jump_within = Global.JUMP_BUFFER_TIME
		#else:
			#is_dashing = true
	
	# JUM CUTTING IS DISABLED NOW
	#if Input.is_action_just_released("jump"):
		#if is_jumping and not is_falling:
			#velocity.y = 0

	
	if Input.is_action_pressed("crouch") and not is_jumping:
		is_crowching = true
		collision_shape.shape.height = 40
		hurtbox.shape.height = 40
	else:
		is_crowching = false
		collision_shape.shape.height = 46
		hurtbox.shape.height = 46
		
	if Input.is_action_just_pressed("shoot") and shootable:
		is_shooting = not is_shooting
	if Input.is_action_just_pressed("pos_lock"):
		position_lock = not position_lock

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if direction:
		current_dir = direction
	if direction and not is_crowching and movable:
		if direction > 0:
			animated_sprite.flip_h = false
			shooting_point.position = Vector2(20, -2)
		if direction < 0:
			animated_sprite.flip_h = true
			shooting_point.position = Vector2(-20, -2)
			

		#if is_dashing:
			#velocity.x = direction * DASH_SPEED
		#else:
		if not position_lock:
			velocity.x = direction * speed * speed_factor
	else:
		if movable:
			velocity.x = move_toward(velocity.x, 0, speed * speed_factor)
	was_falling = is_falling
	is_falling = velocity.y > 0 and not is_on_floor()
	if is_falling:
		is_rising = false


	if is_falling:
		animated_sprite.play("falling")
	elif (not is_falling) and was_falling and (not is_jumping):
		animated_sprite.play("fallen")
		audio_stream_player.stream = grond_hit_sound
		audio_stream_player.play(0.07)
	
	else:
		if is_on_floor() and not is_rising and movable:
			if direction:
				if direction > 0:
					animated_sprite.play("running")
					animated_sprite.flip_h = false
				elif direction < 0:
					animated_sprite.play("running")
					animated_sprite.flip_h = true
				audio_stream_player.stream = running_sound
				audio_stream_player.play(0.07)
			else:
				animated_sprite.play("idle")
	if is_crowching:
		animated_sprite.play("crouch")
	if is_shooting and shootable:
		animated_sprite.play("shooting")

	if movable:
		move_and_slide()
