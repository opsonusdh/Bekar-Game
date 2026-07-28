extends Node2D

signal button_clicked(id)

@export var button_scale := 1.0
@export var id := 0
@export var text := ""
@export var button_label_shadow_color := Color(6.988, 0.0, 0.0)
@export var button_label_shadow_offset := Vector2(1, 1)
@export var button_label_click_translate := Vector2(10, 5)
@export var button_label_font_size := 64
@export var button_label_shadow_size := 5.0
@export var button_label_colour := Color(0.239, 0.0, 0.0)


@onready var label: Label = $Label
@onready var touch_screen_button: TouchScreenButton = $TouchScreenButton
# Store your original shadow sizes to restore them later
var offset_x: int
var offset_y: int
var outline_size: int

func _ready() -> void:
	label.text = text
	label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	await get_tree().process_frame
	
	var text_size: Vector2 = label.get_combined_minimum_size()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = text_size
	var label_setting = label.label_settings
	label_setting.font_size = button_label_font_size
	
	touch_screen_button.shape = rect_shape
	touch_screen_button.shape_centered = true
	
	label.position = -text_size / 2
	
	
	label_setting.font_color = button_label_colour
	label_setting.shadow_color = button_label_shadow_color
	label_setting.shadow_size = button_label_shadow_size
	label_setting.shadow_offset = button_label_shadow_offset
	
	touch_screen_button.pressed.connect(_on_button_pressed)
	touch_screen_button.released.connect(_on_button_released)
	
	scale = Vector2.ONE * button_scale
	

func _on_button_released() -> void:
	# Restore the original offsets when the player lifts their finger
	label.position -= button_label_click_translate
	button_clicked.emit(id)

func _on_button_pressed() -> void:
	label.position += button_label_click_translate
	

func setup(button_text: String, button_scale: Vector2, button_id: int, \
		button_label_colour: Color, button_label_shadow_color: Color, \
		button_label_shadow_size: float, button_label_shadow_offset: Vector2) -> void:
	text = button_text
	id = button_id

	label.text = text
	await get_tree().process_frame

	var text_size = label.get_combined_minimum_size()

	var rect_shape := RectangleShape2D.new()
	rect_shape.size = text_size

	touch_screen_button.shape = rect_shape
	touch_screen_button.shape_centered = true

	label.position = -text_size / 2

	var label_setting = label.label_settings
	
	label_setting.font_color = button_label_colour
	label_setting.shadow_color = button_label_shadow_color
	label_setting.shadow_size = button_label_shadow_size
	label_setting.shadow_offset = button_label_shadow_offset

	scale = button_scale
	
	touch_screen_button.pressed.connect(_on_button_pressed)
	touch_screen_button.released.connect(_on_button_released)
