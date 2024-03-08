@tool
extends Node

const SEWER_WALL = preload("res://scenes/environment/sewer_wall.tscn")
const MOVING_PLATFORM = preload("res://scenes/environment/platforms/moving_platform.tscn")
const STATIC_PLATFORM = preload("res://scenes/environment/platforms/static_platform.tscn")
const BACKGROUND_TILE_SIZE : Vector2i = Vector2i(1080, 1920)

const END = preload("res://scenes/environment/sewer_exit.tscn")

signal game_finished(leaderboard : Array)

@export var platform_node: Node2D : 
	set = set_platform_node

@export_group("Generation Parameters", "platform")
@export var platform_initial_height : float = -200
@export var platform_min_spacing : Vector2 = Vector2(200, 200)
@export var platform_max_spacing : Vector2 = Vector2(1080, 400)
@export_range(0, 1) var platform_motion_chance : float = 0.5
@export_range(0, 1) var platform_min_speed : float = 0.5
@export_range(1, 2) var platform_max_speed : float = 1.5


var player_spawns : Array[Vector2]
var screen_width = ProjectSettings.get_setting("display/window/size/viewport_width")

@warning_ignore("shadowed_global_identifier")
func generate_platforms(height : float, seed : int):
	var random : RandomNumberGenerator = RandomNumberGenerator.new()
	random.set_seed(seed)
	
	#create platforms
	var platform_y : float = platform_initial_height
	while platform_y > height:
		var platform_x = random.randf_range(platform_min_spacing.x, platform_max_spacing.x)
		var pos : Vector2 = Vector2(platform_x, platform_y)
		var moving_platform : bool = random.randf() < platform_motion_chance
		if moving_platform:
			instanciate_moving_platform(pos, random.randf_range(platform_min_speed, platform_max_speed))
		else:
			instanciate_static_platform(pos) #TODO: Rotation?
		platform_y -= random.randf_range(platform_min_spacing.y, platform_max_spacing.y)

func create_finish_area(height : float) -> Node2D:
	var finish_area = END.instantiate()
	finish_area.position = Vector2(0, height)
	finish_area.game_finished.connect(on_game_finished)
	platform_node.add_child(finish_area)
	return finish_area

#TODO: Remove
func on_game_finished(leaderboard : Array):
	game_finished.emit(leaderboard)

func instanciate_static_platform(pos : Vector2):
	var instance = STATIC_PLATFORM.instantiate()
	platform_node.add_child(instance)
	instance.set_position(pos)

func instanciate_moving_platform(pos : Vector2, speed_scale : float):
	var instance = MOVING_PLATFORM.instantiate()
	platform_node.add_child(instance)
	instance.speed_multiplier = speed_scale
	var height = pos.y
	var instance_half_width = instance.get_collision_rect().size.x / 2.0
	instance.set_movement_path(Vector2(screen_width - instance_half_width, height), Vector2(instance_half_width, height), pos)

func set_platform_node(node : Node2D):
	platform_node = node
	if Engine.is_editor_hint():
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	if not platform_node: warnings.append("Spawner must have a platform node assigned.")
	return warnings
