extends Node2D
const SEWER_WALL = preload("res://scenes/environment/sewer_wall.tscn")
const MOVING_PLATFORM = preload("res://scenes/environment/platforms/moving_platform.tscn")
const STATIC_PLATFORM = preload("res://scenes/environment/platforms/static_platform.tscn")
const BACKGROUND_TILE_SIZE : Vector2i = Vector2i(1080, 1920)

const END = preload("res://scenes/environment/sewer_exit.tscn")

@export_group("Platforms", "platform")
@export var platform_initial_height : float = 200
@export var platform_min_spacing : Vector2 = Vector2(200, 200)
@export var platform_max_spacing : Vector2 = Vector2(1080, 400)
@export_range(0, 1) var platform_motion_chance : float = 0.5
@export_range(0, 1) var platform_min_speed : float = 0.5
@export_range(1, 2) var platform_max_speed : float = 1.5

signal game_finished(leaderboard: Array)
@export var tile_map: TileMap
@export var platform_node: Node2D


var player_spawns : Array[Vector2]


func _ready() -> void:
	pass

func generate_map(playable_area : Rect2i, seed : int):
	var random : RandomNumberGenerator = RandomNumberGenerator.new()
	random.set_seed(seed)
	
	var boundry : Rect2i = Rect2i(playable_area)
	boundry.position -= Vector2i.ONE
	boundry.size += Vector2i(2, 2)
	
	#Create background to provided height
	var coord : Vector2i = playable_area.position
	var update_direction : Vector2i = Vector2i.RIGHT
	while boundry.has_point(coord):
		if playable_area.has_point(coord):
			tile_map.set_background(coord)
		else:
			tile_map.set_boundry(coord)
		coord += update_direction
		if not boundry.has_point(coord):
			update_direction = -update_direction
			coord += Vector2i.DOWN + update_direction
	
	var map_height : float = -playable_area.size.y * get_viewport().size.y
	
	#create platforms
	var platform_y : float = platform_initial_height
	while platform_y > map_height:
		platform_y -= random.randf_range(platform_min_spacing.y, platform_max_spacing.y)
		var platform_x = random.randf_range(platform_min_spacing.x, platform_max_spacing.x)
		var pos : Vector2 = Vector2(platform_x, platform_y)
		var moving_platform : bool = random.randf() < platform_motion_chance
		if moving_platform:
			instanciate_moving_platform(pos, random.randf_range(platform_min_speed, platform_max_speed))
		else:
			instanciate_static_platform(pos) #TODO: Rotation?
	#var end = END.instantiate()
	#end.position = Vector2(0, map_height)
	#end.game_finished.connect(on_game_fin)
	#background_node.add_child(end)

func on_game_fin(l: Array):
	game_finished.emit(l)

func instanciate_static_platform(pos : Vector2):
	var instance = STATIC_PLATFORM.instantiate()
	platform_node.add_child(instance)
	instance.set_position(pos)

func instanciate_moving_platform(pos : Vector2, speed_scale : float):
	var instance = MOVING_PLATFORM.instantiate()
	platform_node.add_child(instance)
	instance.speed_multiplier = speed_scale
	instance.position = pos
