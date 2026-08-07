extends Node2D

@export var text := ""
@export var label_shadow_color := Color(0, 0, 0, 0)
@export var label_shadow_offset := Vector2(0, 0)
@export var label_shadow_size := 0

@export var with_button := false
@export var button_id := 0
@export var button_label := ""
@export var button_scale := Vector2(1, 1)
@export var button_label_shadow_color := Color(6.988, 0.0, 0.0)
@export var button_label_shadow_offset := Vector2(1, 1)
@export var button_label_shadow_size := 5
@export var button_label_colour := Color(0.239, 0.0, 0.0)

signal banner_button_clicked(id)
const PADDING_X := 20
const PADDING_Y := 12

@onready var label: Label = $Label
@onready var panel: NinePatchRect = $NinePatchRect
@onready var text_button: Node2D = $"Text Button"


func _ready() -> void:
	label.text = text

	# Wait one frame so the Label updates its size
	await get_tree().process_frame

	# Measure the actual text
	var font := label.get_theme_font("font")
	var font_size := label.get_theme_font_size("font_size")

	var text_size := font.get_string_size(
		label.text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size
	)

	# Resize the panel
	panel.size = Vector2(
		text_size.x + PADDING_X * 2,
		text_size.y + PADDING_Y * 2
	)

	# Center the panel on this Node2D
	panel.position = -panel.size / 2

	# Make the label fill the panel
	label.position = panel.position
	label.size = panel.size

	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	var label_setting = label.label_settings
	
	label_setting.shadow_color = label_shadow_color
	label_setting.shadow_size = label_shadow_size
	label_setting.shadow_offset = label_shadow_offset


	if not with_button:
		text_button.queue_free()
	else:
		text_button.setup(button_label, button_scale, button_id, button_label_colour, button_label_shadow_color, button_label_shadow_size, button_label_shadow_offset)
		const BUTTON_MARGIN := Vector2(8, 8)
		await get_tree().process_frame
		# Size of the button
		var button_size = text_button.get_node("TouchScreenButton").shape.size * text_button.scale

		text_button.position = Vector2(
			panel.position.x + panel.size.x - button_size.x / 2 - BUTTON_MARGIN.x,
			panel.position.y + panel.size.y - button_size.y / 2 - BUTTON_MARGIN.y
		)
		


func _on_text_button_button_clicked(id: Variant) -> void:
	banner_button_clicked.emit(id)
