extends Node2D

var dialouge = [
	"At last... someone else has entered this cursed realm.",
	"What you see is no longer our school.",
	"A terrible curse has consumed these halls.",
	"Our Head Sir, Tapan Kumar Poddar, was its first victim.",
	"The darkness twisted his mind and spread through every classroom.",
	"One by one... our teachers were transformed...",
	"into monstrous beings, each wielding terrifying powers.",
	"They no longer know friend from foe.",
	"Somewhere within this nightmare, the source of the curse still lurks...",
	"Hidden, watching.",
	"But you are different.",
	"The moment you crossed the school gate, the curse chose you.",
	"Not to destroy you...",
	"...but to awaken the power sleeping inside you.",
	"Your Curse Technique has awakened.",
	"Now... show me your strength.",
	"Your journey begins."
]

var index = 0
@onready var banner: Node2D = $kochu/banner
@onready var player: CharacterBody2D = $CharacterBody1D
@onready var curtain: Area2D = $curtain
@onready var dpad: Node2D = $CanvasLayer/Control/dpad
@onready var interractable_area_2d: Area2D = $Interractable_Area2D

var player_in_interractable_door = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var data = Global.load_data()
	if data.get("player", {}).get("completed_tutorial", false):
		index = len(dialouge)-1
		banner.with_button = false
	else:
		dpad.top_visible = false
		dpad.bottom_visible = false
		dpad.pos_lock_visible = false
		dpad.jump_visible = false
		dpad.crouch_visible = false
		dpad.fire_visible = false
		dpad.interract_visible = false
	
	banner.text = dialouge[index]
	dpad._ready()
	banner._ready()
	
	await curtain.play_animation(curtain.FADEOUT)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_P):
		index = len(dialouge)-2
	if Input.is_action_just_pressed("interract") and player_in_interractable_door:
		await curtain.play_animation(curtain.FADEIN)
		get_tree().change_scene_to_file("res://scenes/scene_1.tscn")


func _on_kochu_body_entered(body: Node2D) -> void:
	if body == player:
		banner.show()
		dpad.modulate = Color(1, 1, 1, 0.5)

func _on_kochu_body_exited(body: Node2D) -> void:
	if body == player:
		banner.hide()
		dpad.modulate = Color(1, 1, 1, 1)


func _on_banner_banner_button_clicked(id: Variant) -> void:
	index += 1
	if index >= len(dialouge):
		get_tree().change_scene_to_file("res://scenes/scene 1_1_1.tscn")
		return
	banner.hide()
	banner.text = dialouge[index]
	banner._ready()
	banner.show()
	

func _on_interractable_area_2d_body_entered(body: Node2D) -> void:
	if body == player:
		interractable_area_2d.highlight(true)
		player_in_interractable_door = true



func _on_interractable_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		interractable_area_2d.highlight(false)
		player_in_interractable_door = false
