extends Node2D

@onready var animation_player: AnimationPlayer = $moving/AnimationPlayer

func start_animation_delayed(delay : float, custom_speed : float):
	get_tree().create_timer(delay).timeout.connect(start_animation.bind(custom_speed))
	

func start_animation(custom_speed : float):
	animation_player.play("move_loop", -1,  custom_speed)
