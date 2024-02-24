extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func play_countdown():
	animation_player.play("CountDown")
	await animation_player.animation_finished
