extends Control

@onready var texture_rect: TextureRect = $VBoxContainer/TextureRect
@onready var label: Label = $VBoxContainer/Label
@onready var vbox: VBoxContainer = $VBoxContainer

@export var tex: AtlasTexture
@export var text := "Item Name"
@export var id := "ID"
@export var _dim := Vector2.ONE*100

var font_size := 16

func _ready() -> void:
	if not is_instance_valid(vbox) or not is_instance_valid(texture_rect) or not is_instance_valid(label):
		return

	# Center everything inside the VBoxContainer
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER

	if tex:
		texture_rect.texture = tex
	texture_rect.visible = true
	texture_rect.custom_minimum_size = _dim

	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	label.text = text

	# Set font size
	if label.label_settings == null:
		label.label_settings = LabelSettings.new()

	label.label_settings.font_size = font_size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	if is_instance_valid(get_tree()):
		await get_tree().process_frame
	_finalize_layout()
	texture_rect.gui_input.connect(_on_texture_rect_gui_input)


func _on_texture_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		print("Texture touched! ", id)
		Global.showcase_item_touched.emit(id)



func set_display_text(new_text: String) -> void:
	text = new_text
	if is_instance_valid(label):
		label.text = new_text


func set_interactive(enabled: bool) -> void:
	if is_instance_valid(texture_rect):
		texture_rect.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
	if is_instance_valid(self):
		set_process_input(enabled)
		set_process_unhandled_input(enabled)


func _finalize_layout() -> void:
	if not is_instance_valid(vbox):
		return
	custom_minimum_size = vbox.get_combined_minimum_size()
