extends Node2D
@export var top_visible := true
@export var bottom_visible := true
@export var left_visible := true
@export var right_visible := true
@export var pos_lock_visible := true
@export var jump_visible := true
@export var crouch_visible := true
@export var fire_visible := true
@export var interract_visible := true
@export var dpad_passby_press := true

@export var custom_top_action := ""
@export var custom_bottom_action := ""
@export var custom_left_action := ""
@export var custom_right_action := ""
@export var custom_pos_lock_action := ""
@export var custom_jump_action := ""
@export var custom_crouch_action := ""
@export var custom_fire_action := ""
@export var custom_interract_action := ""

@onready var up: TouchScreenButton = $up
@onready var down: TouchScreenButton = $down
@onready var left: TouchScreenButton = $left
@onready var right: TouchScreenButton = $right
@onready var pos_lock: TouchScreenButton = $pos_lock
@onready var jump: TouchScreenButton = $jump
@onready var crouch: TouchScreenButton = $crouch
@onready var fire: TouchScreenButton = $fire
@onready var interract: TouchScreenButton = $interract

enum ButtonType {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	POS_LOCK,
	JUMP,
	CROUCH,
	FIRE,
	INTERACT
}



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not top_visible:
		up.queue_free()
	if not bottom_visible:
		down.queue_free()
	if not left_visible:
		left.queue_free()
	if not right_visible:
		right.queue_free()
	if not pos_lock_visible:
		pos_lock.queue_free()
	if not jump_visible:
		jump.queue_free()
	if not crouch_visible:
		crouch.queue_free()
	if not fire_visible:
		fire.queue_free()
	if not interract_visible:
		interract.queue_free()
	
	if dpad_passby_press:
		if top_visible:
			up.shape.set("size", Vector2(91, 30))
		if bottom_visible:
			down.shape.set("size", Vector2(91, 28))
		if left_visible:
			left.shape.set("size", Vector2(30, 92))
		if right_visible:
			right.shape.set("size", Vector2(29, 92))
	
	if custom_top_action:
		up.action = custom_top_action
	if custom_bottom_action:
		down.action = custom_bottom_action
	if custom_left_action:
		left.action = custom_left_action
	if custom_right_action:
		right.action = custom_right_action
	if custom_pos_lock_action:
		pos_lock.action = custom_pos_lock_action
	if custom_jump_action:
		jump.action = custom_jump_action
	if custom_crouch_action:
		crouch.action = custom_crouch_action
	if custom_fire_action:
		fire.action = custom_fire_action
	if custom_interract_action:
		interract.action = custom_interract_action


func change_opacity(button: ButtonType, opacity: float) -> void:
	match button:
		ButtonType.UP:
			up.modulate.a = opacity
		ButtonType.DOWN:
			down.modulate.a = opacity
		ButtonType.LEFT:
			left.modulate.a = opacity
		ButtonType.RIGHT:
			right.modulate.a = opacity
		ButtonType.POS_LOCK:
			pos_lock.modulate.a = opacity
		ButtonType.JUMP:
			jump.modulate.a = opacity
		ButtonType.CROUCH:
			crouch.modulate.a = opacity
		ButtonType.FIRE:
			fire.modulate.a = opacity
		ButtonType.INTERACT:
			interract.modulate.a = opacity
