extends Node2D

## Uses viewport-relative positions, so the controls stay in reach on phones and tablets.
@export var top_visible := true
@export var bottom_visible := true
@export var left_visible := true
@export var right_visible := true
@export var pos_lock_visible := true
@export var jump_visible := true
@export var crouch_visible := true
@export var fire_visible := true
@export var interract_visible := true
@export var swap_visible := false
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
@export var custom_swap_action := ""

const LAYOUT_FILE := "user://touch_control_layout.cfg"
const REFERENCE_SIZE := Vector2(1152.0, 648.0)
const DPAD_DEFAULT_ANCHOR := Vector2(0.135, 0.716)
const EDGE_MARGIN := 22.0

@onready var up: TouchScreenButton = $up
@onready var down: TouchScreenButton = $down
@onready var left: TouchScreenButton = $left
@onready var right: TouchScreenButton = $right
@onready var pos_lock: TouchScreenButton = $pos_lock
@onready var jump: TouchScreenButton = $jump
@onready var crouch: TouchScreenButton = $crouch
@onready var fire: TouchScreenButton = $fire
@onready var interract: TouchScreenButton = $interract
@onready var swap: TouchScreenButton = $"swap button"

enum ButtonType { UP, DOWN, LEFT, RIGHT, POS_LOCK, JUMP, CROUCH, FIRE, INTERACT , SWAP}

var _configured := false
var _layout_editing := false
var _drag_target := ""
var _saved_layout: Dictionary = {}

func _ready() -> void:
	_load_layout()
	apply_configuration()
	get_viewport().size_changed.connect(_apply_responsive_layout)
	call_deferred("_apply_responsive_layout")

## Public because existing scenes configure the component after instancing it.
func apply_configuration() -> void:
	_configured = true
	_set_visible(up, top_visible)
	_set_visible(down, bottom_visible)
	_set_visible(left, left_visible)
	_set_visible(right, right_visible)
	_set_visible(pos_lock, pos_lock_visible)
	_set_visible(jump, jump_visible)
	_set_visible(crouch, crouch_visible)
	_set_visible(fire, fire_visible)
	_set_visible(interract, interract_visible)
	_set_visible(swap, swap_visible)
	if dpad_passby_press:
		if is_instance_valid(up): up.shape.size = Vector2(91, 30)
		if is_instance_valid(down): down.shape.size = Vector2(91, 28)
		if is_instance_valid(left): left.shape.size = Vector2(30, 92)
		if is_instance_valid(right): right.shape.size = Vector2(29, 92)
	_set_action(up, custom_top_action)
	_set_action(down, custom_bottom_action)
	_set_action(left, custom_left_action)
	_set_action(right, custom_right_action)
	_set_action(pos_lock, custom_pos_lock_action)
	_set_action(jump, custom_jump_action)
	_set_action(crouch, custom_crouch_action)
	_set_action(fire, custom_fire_action)
	_set_action(interract, custom_interract_action)
	_set_action(swap, custom_swap_action)
	_apply_responsive_layout()

func _set_visible(button: TouchScreenButton, should_show: bool) -> void:
	if is_instance_valid(button):
		button.visible = should_show
		button.process_mode = Node.PROCESS_MODE_INHERIT if should_show else Node.PROCESS_MODE_DISABLED

func _set_action(button: TouchScreenButton, action_name: String) -> void:
	if is_instance_valid(button) and not action_name.is_empty():
		button.action = action_name

func _apply_responsive_layout() -> void:
	if not _configured:
		return
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var size_factor: float = minf(viewport_size.x / REFERENCE_SIZE.x, viewport_size.y / REFERENCE_SIZE.y)
	scale = Vector2.ONE * (3.2 * clampf(size_factor, 0.72, 1.0))
	var dpad_position: Vector2 = _saved_layout.get("dpad", DPAD_DEFAULT_ANCHOR)
	global_position = _normalised_to_screen(dpad_position, viewport_size)
	for button_name in ["pos_lock", "jump", "crouch", "fire", "interract", "swap"]:
		if _saved_layout.has(button_name):
			var button := _get_action_button(button_name)
			if is_instance_valid(button):
				button.global_position = _normalised_to_screen(_saved_layout[button_name], viewport_size)

func set_layout_editing(enabled: bool) -> void:
	_layout_editing = enabled
	_drag_target = ""
	for button in [up, down, left, right, pos_lock, jump, crouch, fire, interract, swap]:
		if not is_instance_valid(button):
			continue
		# A repositioning touch must never also trigger a gameplay input.
		Input.action_release(button.action)
		button.process_mode = Node.PROCESS_MODE_DISABLED if enabled or not button.visible else Node.PROCESS_MODE_INHERIT

func is_layout_editing() -> bool:
	return _layout_editing

func reset_saved_layout() -> void:
	_saved_layout.clear()
	var config := ConfigFile.new()
	config.save(LAYOUT_FILE)
	_apply_responsive_layout()

func _input(event: InputEvent) -> void:
	if not _layout_editing:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			_drag_target = _get_drag_target(event.position)
			if not _drag_target.is_empty():
				get_viewport().set_input_as_handled()
		elif not _drag_target.is_empty():
			_save_layout()
			_drag_target = ""
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and not _drag_target.is_empty():
		_move_drag_target(event.position)
		get_viewport().set_input_as_handled()

func _get_drag_target(screen_position: Vector2) -> String:
	# Check the centre action first; otherwise it would be swallowed by the D-pad.
	for button_name in ["pos_lock", "jump", "crouch", "fire", "interract", "swap"]:
		var button := _get_action_button(button_name)
		if is_instance_valid(button) and button.visible and screen_position.distance_to(button.global_position) <= 24.0 * scale.x:
			return button_name
	# Dragging a directional piece moves the whole D-pad and preserves its shape.
	if screen_position.distance_to(global_position) <= 60.0 * scale.x:
		return "dpad"
	return ""

func _move_drag_target(screen_position: Vector2) -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var clamped_position := screen_position.clamp(Vector2.ONE * EDGE_MARGIN, viewport_size - Vector2.ONE * EDGE_MARGIN)
	if _drag_target == "dpad":
		global_position = clamped_position
	else:
		var button := _get_action_button(_drag_target)
		if is_instance_valid(button):
			button.global_position = clamped_position
	_saved_layout[_drag_target] = _screen_to_normalised(clamped_position, viewport_size)

func _get_action_button(button_key: String) -> TouchScreenButton:
	match button_key:
		"pos_lock": return pos_lock
		"jump": return jump
		"crouch": return crouch
		"fire": return fire
		"interract": return interract
		"swap": return swap
		_: return null

func _load_layout() -> void:
	var config := ConfigFile.new()
	if config.load(LAYOUT_FILE) != OK:
		return
	for key in ["dpad", "pos_lock", "jump", "crouch", "fire", "interract", "swap"]:
		# Older layout files may not contain newer controls (such as swap).
		if not config.has_section_key("positions", key):
			continue
		var value = config.get_value("positions", key)
		if value is Vector2:
			_saved_layout[key] = value

func _save_layout() -> void:
	var config := ConfigFile.new()
	for key in _saved_layout:
		config.set_value("positions", key, _saved_layout[key])
	config.save(LAYOUT_FILE)

func _normalised_to_screen(value: Vector2, viewport_size: Vector2) -> Vector2:
	return Vector2(value.x * viewport_size.x, value.y * viewport_size.y)

func _screen_to_normalised(value: Vector2, viewport_size: Vector2) -> Vector2:
	return Vector2(value.x / viewport_size.x, value.y / viewport_size.y)

func change_opacity(button: ButtonType, opacity: float) -> void:
	var buttons := [up, down, left, right, pos_lock, jump, crouch, fire, interract, swap]
	if button < buttons.size() and is_instance_valid(buttons[button]):
		buttons[button].modulate.a = opacity
