extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

enum AnimationType {
	FADE_IN,
	FADE_OUT
}
const FADEIN = AnimationType.FADE_IN
const FADEOUT = AnimationType.FADE_OUT

func play_animation(animation: AnimationType) -> void:
	match animation:
		AnimationType.FADE_IN:
			show()
			animation_player.play("fadein")
			await animation_player.animation_finished
			hide()

		AnimationType.FADE_OUT:
			show()
			animation_player.play("fadeout")
			await animation_player.animation_finished
			hide()
