extends Control

signal started
signal finished

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func play_countdown() -> Signal:
	animation_player.play("CountDown")
	return animation_player.animation_finished
