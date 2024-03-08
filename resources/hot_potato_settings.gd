class_name HotPotatoSettings
extends Resource

@export var size : Vector2i
@export var generator_seed : int
@export var player_timeout : float

func _init(map_size : Vector2i, timeout : float, map_seed : int) -> void:
	size = map_size
	generator_seed = map_seed
	player_timeout = timeout
