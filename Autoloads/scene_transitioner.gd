extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	hide()

func fade_in() -> Signal:
	animation_player.play("fade_in")
	return animation_player.animation_finished

func fade_out() -> Signal:
	animation_player.play_backwards("fade_in")
	return animation_player.animation_finished
