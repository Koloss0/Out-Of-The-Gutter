class_name HotPotatoSettings
extends Resource

@export var map_size : Vector2i
@export var map_seed : int

func _init(map_size : Vector2i, seed : int) -> void:
	self.map_size = map_size
	map_seed = seed
