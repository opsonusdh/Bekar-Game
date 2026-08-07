extends Node2D

var jumpscare1 = preload("res://audio/jumpscare 1.mp3")
var jumpscare2 = preload("res://audio/jumpscare 2.mp3")
@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var label: Label = $Label
@onready var timer: Timer = $Timer

var phase: int = 1

func _ready() -> void:
	audio_stream_player.stream = jumpscare1
	label.hide()
	audio_stream_player.play()

func _on_timer_timeout() -> void:
	if phase == 1:
		# Trigger the second jumpscare
		audio_stream_player.stream = jumpscare2
		audio_stream_player.play()
		label.show()
		
		# Set up the next countdown for 2 seconds
		timer.wait_time = 2.5
		timer.start()
		phase = 2
	elif phase == 2:
		get_tree().change_scene_to_file("res://scenes/scene 1.tscn")
