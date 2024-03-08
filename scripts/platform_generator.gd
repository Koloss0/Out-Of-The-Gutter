@tool
extends Node

const MOVING_PLATFORM = preload("res://scenes/environment/platforms/moving_platform.tscn")
const STATIC_PLATFORM = preload("res://scenes/environment/platforms/static_platform.tscn")
const BACKGROUND_TILE_SIZE : Vector2i = Vector2i(1080, 1920)

const END = preload("res://scenes/environment/sewer_exit.tscn")

signal game_finished(leaderboard : Array)

@export var platform_node: Node2D : 
	set = set_platform_node

@export_group("Generation Parameters", "platform")
@export var platform_initial_height : float = 200
@export var platform_min_spacing : Vector2 = Vector2(200, 200)
@export var platform_max_spacing : Vector2 = Vector2(1080, 400)
@export var platform_max_motion : Vector2 = Vector2(1080, 0)
@export var platform_min_motion : Vector2 = Vector2(200, 0)
@export_range(0, 1) var platform_motion_chance : float = 0.5
@export_range(0, 1) var platform_min_speed : float = 0.5
@export_range(1, 2) var platform_max_speed : float = 1.5

# TODO: implement motion limits for moving platforms.
# TODO: ensure platforms do not overlap.

var player_spawns : Array[Vector2]
var screen_width = ProjectSettings.get_setting("display/window/size/viewport_width")

@warning_ignore("shadowed_global_identifier")
func generate_platforms(area : Rect2, seed : int):
	var random : RandomNumberGenerator = RandomNumberGenerator.new()
	random.set_seed(seed)
	
	#create platforms
	var platform_y : float = (area.position.y + area.size.y) - platform_initial_height
	var center_x : float = area.position.x + area.size.x / 2.0
	var max_side_by_side : int = roundi(area.size.x / platform_max_spacing.x)
	var outer_limits : Boundery = Boundery.new(area)
	while platform_y > area.position.y:
		var num_platforms = random.randi_range(1, max_side_by_side)
		var occupied_left : float = center_x
		var occupied_right : float = center_x
		
		for i in range(num_platforms):
			var platform_x
			var offset := random.randf_range(platform_min_spacing.x, platform_max_spacing.x)
			var moving_platform : bool = random.randf() < platform_motion_chance
			
			var to_the_right : bool = random.randf() > 0.5
			if to_the_right:
				platform_x = occupied_right + offset
				if platform_x > outer_limits.max.x:
					platform_x -= area.size.x
			else:
				platform_x = (occupied_left - offset)
				if platform_x < outer_limits.min.x:
					platform_x += area.size.x
			
			var instance = MOVING_PLATFORM.instantiate() if moving_platform else STATIC_PLATFORM.instantiate()
			platform_node.add_child(instance)
			
			var adjusted_boundery = trim_boundry(outer_limits, instance.get_collision_rect().size)
			var pos : Vector2 = Vector2(clamp(platform_x, adjusted_boundery.min.x, adjusted_boundery.max.x), clamp(platform_y, adjusted_boundery.min.y, adjusted_boundery.max.y))
			instance.position = pos
			
			if moving_platform:
				instance.set_movement_path(Vector2(adjusted_boundery.max.x, pos.y), Vector2(adjusted_boundery.min.x, pos.y), pos)
				instance.speed_multiplier = randf_range(platform_min_speed, platform_max_speed)
				
		platform_y -= random.randf_range(platform_min_spacing.y, platform_max_spacing.y)

func create_finish_area(height : float) -> Node2D:
	var finish_area = END.instantiate()
	finish_area.position = Vector2(0, height)
	finish_area.game_finished.connect(on_game_finished)
	platform_node.add_child(finish_area)
	return finish_area


#TODO: Remove
func on_game_finished(leaderboard : Array) -> void:
	game_finished.emit(leaderboard)

func trim_boundry(boundery : Boundery, trim : Vector2) -> Boundery: 
	return Boundery.new(Rect2(boundery.min + trim / 2.0, boundery.max - boundery.min - trim))

func instanciate_static_platform(pos : Vector2) -> PhysicsBody2D:
	var instance = STATIC_PLATFORM.instantiate()
	platform_node.add_child(instance)
	instance.set_position(pos)
	return instance


func instanciate_moving_platform(pos : Vector2, speed_scale : float) -> PhysicsBody2D:
	var instance = MOVING_PLATFORM.instantiate()
	platform_node.add_child(instance)
	instance.speed_multiplier = speed_scale
	return instance


func set_platform_node(node : Node2D):
	platform_node = node
	if Engine.is_editor_hint():
		update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	if not platform_node: warnings.append("Spawner must have a platform node assigned.")
	return warnings


func convert_area_to_limits(area : Rect2) -> Rect2:
	return Rect2(area.position, area.position + area.size)


class Boundery:
	var max : Vector2
	var min : Vector2
	
	func _init(area : Rect2) -> void:
		if area is Rect2:
			min = area.position
			max = area.position + area.size

