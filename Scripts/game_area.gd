extends Node2D

const SEWER_WALL = preload("res://Scenes/GameArea/sewer_wall.tscn")
const PLATFORM = preload("res://Scenes/Pipe.tscn")
const MOVING_PLATFORM = preload("res://Scenes/Platforms/moving.tscn")

const BACKGROUND_TILE_SIZE : Vector2i = Vector2i(1080, 1920)

@export_group("Platforms", "platform")
@export var platform_min_spacing : Vector2 = Vector2.ONE
@export var platform_max_spacing : Vector2 = Vector2.ONE
@export_range(0, 1) var platform_motion_chance : float = 0.5
@export_range(0, 1) var platform_min_speed : float = 0.5
@export_range(1, 2) var platform_max_speed : float = 1.5

#@export var platform_max_side_by_side : int


@onready var background: Node2D = $Background
@onready var platforms: Node2D = $Platforms

#const 

var player_spawns : Array[Vector2]


func _ready() -> void:
	player_spawns = [$Players/Spawn1.position, $Players/Spawn2.position, $Players/Spawn3.position, $Players/Spawn4.position]
	generate_map(2, 23)
	#$Camera2D.zoom = Vector2(0.1, 0.1)
	

func _process(delta: float) -> void:
	$Camera2D.position += Vector2(0, -2)

func generate_map(height : int, seed : int):
	var random : RandomNumberGenerator = RandomNumberGenerator.new()
	random.set_seed(seed)
	
	#Create background to provided height
	for i in range(height):
		var wall : Node2D = SEWER_WALL.instantiate()
		background.add_child(wall)
		#wall.set_size(BACKGROUND_TILE_SIZE)
		wall.position.y = -i * BACKGROUND_TILE_SIZE.y
	
	var map_height : float = -height * BACKGROUND_TILE_SIZE.y
	
	#create platforms
	var platform_y : float = 0.0
	while platform_y > map_height:
		platform_y -= random.randf_range(platform_min_spacing.y, platform_max_spacing.y)
		var platform_x = random.randf_range(platform_min_spacing.x, platform_max_spacing.x)
		var pos : Vector2 = Vector2(platform_x, platform_y)
		#var num_side_by_side : int = roundi(random.randf() * platform_max_side_by_side)
		#for platform in range(num_side_by_side):
		var moving_platform : bool = random.randf() < platform_motion_chance
		if moving_platform:
			instanciate_moving_platform(pos, random.randf_range(platform_min_speed, platform_max_speed))
		else:
			instanciate_static_platform(pos) #TODO: Rotation?

func instanciate_static_platform(pos : Vector2):
	# var instance = STATIC_PLATFORM.instanciate()
	# platforms.add_child(instance)
	# instance.set_position(pos)
	pass

func instanciate_moving_platform(pos : Vector2, speed_scale : float):
	var instance = MOVING_PLATFORM.instantiate()
	platforms.add_child(instance)
	instance.position = pos

func get_player_spawn(index : int) -> Vector2:
	return player_spawns[index]

