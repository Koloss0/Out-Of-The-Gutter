class_name RaceSettings
extends Resource

@export var map_height : int
@export var map_seed : int

@warning_ignore("shadowed_global_identifier")
func _init(height : int, seed : int) -> void:
	map_height = height
	map_seed = seed
