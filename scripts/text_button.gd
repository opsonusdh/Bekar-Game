extends Node2D

signal button_clicked(id)

@export var button_scale := 1.0
@export var id := 0
@export var text := ""
@export var button_label_shadow_color := Color(6.988, 0.0, 0.0)
@export var button_label_shadow_offset := Vector2(1, 1)
@export var button_label_click_translate := Vector2(10, 5)
@export var button_label_font_size := 64
@export var button_label_shadow_size := 5
@export var button_label_colour := Color(0.239, 0.0, 0.0)

@onready var label: Label = $Label
@onready var touch_screen_button: TouchScreenButton = $TouchScreenButton

var _configured_scale := Vector2.ONE
var _appearance_revision := 0

func _ready() -> void:
	_configured_scale = Vector2.ONE * button_scale
	_connect_input_signals()
	_refresh_appearance()

## Signal connections belong to the node lifecycle, not setup().
## setup() can then be used repeatedly by parent components without duplicates.
func _connect_input_signals() -> void:
	if not touch_screen_button.pressed.is_connected(_on_button_pressed):
		touch_screen_button.pressed.connect(_on_button_pressed)
	if not touch_screen_button.released.is_connected(_on_button_released):
		touch_screen_button.released.connect(_on_button_released)

func _refresh_appearance() -> void:
	_appearance_revision += 1
	var revision := _appearance_revision
	label.text = text
	label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	var label_settings: LabelSettings = label.label_settings
	label_settings.font_size = button_label_font_size
	label_settings.font_color = button_label_colour
	label_settings.shadow_color = button_label_shadow_color
	label_settings.shadow_size = button_label_shadow_size
	label_settings.shadow_offset = button_label_shadow_offset

	# Label metrics update on the next frame. Ignore older queued refreshes.
	await get_tree().process_frame
	if revision != _appearance_revision:
		return

	var text_size: Vector2 = label.get_combined_minimum_size()
	var rect_shape := RectangleShape2D.new()
	rect_shape.size = text_size
	touch_screen_button.shape = rect_shape
	touch_screen_button.shape_centered = true
	label.position = -text_size / 2.0
	scale = _configured_scale

func _on_button_released() -> void:
	label.position -= button_label_click_translate
	button_clicked.emit(id)

func _on_button_pressed() -> void:
	label.position += button_label_click_translate

func setup(button_text: String, new_button_scale: Vector2, button_id: int, \
		new_button_label_colour: Color, new_button_label_shadow_color: Color, \
		new_button_label_shadow_size: int, new_button_label_shadow_offset: Vector2) -> void:
	text = button_text
	id = button_id
	_configured_scale = new_button_scale
	button_label_colour = new_button_label_colour
	button_label_shadow_color = new_button_label_shadow_color
	button_label_shadow_size = new_button_label_shadow_size
	button_label_shadow_offset = new_button_label_shadow_offset

	if is_node_ready():
		_refresh_appearance()
