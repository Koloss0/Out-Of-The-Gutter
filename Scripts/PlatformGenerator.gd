extends Node2D
const SEWER_WALL = preload("res://Scenes/sewer_wall.tscn")
const MOVING_PLATFORM = preload("res://Scenes/Platforms/moving_platform.tscn")
const STATIC_PLATFORM = preload("res://Scenes/Platforms/Stationary_platform.tscn")
const BACKGROUND_TILE_SIZE : Vector2i = Vector2i(1080, 1920)

@export_group("Platforms", "platform")
@export var platform_initial_height : float = 200
@export var platform_min_spacing : Vector2 = Vector2(200, 200)
@export var platform_max_spacing : Vector2 = Vector2(1080, 400)
@export_range(0, 1) var platform_motion_chance : float = 0.5
@export_range(0, 1) var platform_min_speed : float = 0.5
@export_range(1, 2) var platform_max_speed : float = 1.5


@export var background_node: Node2D
@export var platform_node: Node2D

var player_spawns : Array[Vector2]


func _ready() -> void:
	#testing
	#background_node = $Background
	#platform_node = $Platforms
	generate_map(2, 23)
	#$Camera2D.zoom = Vector2(0.1, 0.1)
	pass

func _process(delta: float) -> void:
	%Camera2D.position += Vector2(0, -2)

func generate_map(height : int, seed : int):
	var random : RandomNumberGenerator = RandomNumberGenerator.new()
	random.set_seed(seed)
	
	print(background_node)
	print(platform_node)
	
	#Create background to provided height
	for i in range(height):
		var wall : Node2D = SEWER_WALL.instantiate()
		background_node.add_child(wall)
		wall.position.y = -i * BACKGROUND_TILE_SIZE.y
	
	var map_height : float = -height * BACKGROUND_TILE_SIZE.y
	
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

func instanciate_static_platform(pos : Vector2):
	var instance = STATIC_PLATFORM.instantiate()
	platform_node.add_child(instance)
	instance.set_position(pos)

func instanciate_moving_platform(pos : Vector2, speed_scale : float):
	var instance = MOVING_PLATFORM.instantiate()
	platform_node.add_child(instance)
	instance.speed_multiplier = speed_scale
	instance.position = pos
