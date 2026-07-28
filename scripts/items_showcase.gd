extends Control

@onready var texture_rect: TextureRect = $VBoxContainer/TextureRect
@onready var label: Label = $VBoxContainer/Label
@onready var vbox: VBoxContainer = $VBoxContainer

@export_file("*.png", "*.jpg", "*.webp")
var sprite_path := "res://assets/knowledge scraps.png"

@export var _scale := Vector2.ONE
@export var text := "Item Name"

@export_range(8, 128, 1)
var font_size := 16

func _ready() -> void:
	# Center everything inside the VBoxContainer
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER

	if sprite_path != "":
		texture_rect.texture = load(sprite_path)

		var tex_size = texture_rect.texture.get_size()
		texture_rect.custom_minimum_size = tex_size * _scale

	label.text = text

	# Set font size
	if label.label_settings == null:
		label.label_settings = LabelSettings.new()

	label.label_settings.font_size = font_size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	await get_tree().process_frame
	custom_minimum_size = vbox.get_combined_minimum_size()
	scale = _scale
