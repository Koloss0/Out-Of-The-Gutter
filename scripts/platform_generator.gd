@tool
class_name PlatformGenerator
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
	# TODO: implement new algorithm with _shift_into_range()
	# TODO: enforce boundery
	var random : RandomNumberGenerator = RandomNumberGenerator.new()
	random.set_seed(seed)
	
	#create platforms
	var platform_y : float = (area.position.y + area.size.y) - platform_initial_height
	var center_x : float = area.position.x + area.size.x / 2.0
	var max_side_by_side : int = roundi(area.size.x / platform_max_spacing.x)
	var outer_limits : Limit = Limit.new(area)

	var previous_layer : Array[Rect2] = []
	var current_layer : Array[Rect2] = []
	
	while platform_y > area.position.y:
		var num_platforms : int = random.randi_range(1, max_side_by_side)
		previous_layer.clear()

		current_layer.clear()
		current_layer.resize(num_platforms)
		
		for i in range(num_platforms):
			var offset := random.randf() * area.size.x
			var moving_platform : bool = random.randf() < platform_motion_chance

			var platform_x = fmod(center_x + offset, area.size.x)
			
			var instance = MOVING_PLATFORM.instantiate() if moving_platform else STATIC_PLATFORM.instantiate()
			platform_node.add_child(instance)
			
			var adjusted_boundery = trim_boundry(outer_limits, instance.get_collision_rect().size)
			var pos : Vector2 = Vector2(clamp(platform_x, adjusted_boundery.min.x, adjusted_boundery.max.x), clamp(platform_y, adjusted_boundery.min.y, adjusted_boundery.max.y))
			instance.position = pos
			
			if moving_platform:
				instance.set_movement_path(Vector2(adjusted_boundery.max.x, pos.y), Vector2(adjusted_boundery.min.x, pos.y), pos)
				instance.speed_multiplier = random.randf_range(platform_min_speed, platform_max_speed)
				
		platform_y -= random.randf_range(platform_min_spacing.y, platform_max_spacing.y)


func _shift_into_range_h(platform : Rect2, targets : Array[Rect2], obstacles : Array[Rect2], spacing : float, boundery : Limit) -> Rect2:
	# TODO: enforce boundery

	if targets.size() == 0: return platform
	targets.sort_custom(is_closer.bind(platform))

	var platform_center = platform.get_center()
	var shifted : Rect2
	for target in targets:
		shifted = Rect2(platform)
		var target_center : Vector2 = target.get_center()

		var shift_right : bool = target_center.x > platform_center.x
		if shift_right:
			shifted.position.x = target.position.x + target.size.x + spacing
		else:
			shifted.position.x = target.position.x - shifted.size.x - spacing

		if obstacles.filter(func(other): return shifted.intersects(other)).size() == 0:
			return shifted
	
	shifted = _unclip_area_h(platform, obstacles, boundery)
	return shifted
	

	
## Horizontally moves the area to have the least possible overlap with the obstacles, whilst also having the least possible displacement
func _unclip_area_h(area : Rect2, obstacles : Array[Rect2], boundery : Limit) -> Rect2:
	if obstacles.size() == 0: return area

	# Used Vector2 as a tupple to avoid synchronizing two arrays
	# Vector2.x = x position, Vector2.y = gap size
	var available_postions : Array[Vector2] = []

	obstacles.sort_custom(sort_ascending_x)

	var leftmost : Rect2 = obstacles.front()
	var rightmost : Rect2 = obstacles.back()
	assert(boundery.min.x <= (leftmost.position.x + leftmost.size.x) and boundery.max.x >= (rightmost.position.x + rightmost.size.x), "Invalid boundery received. An obstacle is out of bounds.")

	obstacles.push_front(boundery.min)
	obstacles.push_back(boundery.max)

	available_postions.resize(obstacles.size())
	
	var o := obstacles[0]
	var i : int = 0
	while i < obstacles.size():
		var next_i := i + 1
		var next_o := obstacles[next_i]

		var pos_x := o.position.x + o.size.x
		var gap := next_o.position.x - pos_x
		available_postions[i] = Vector2(pos_x, gap)

		o = next_o
		i = next_i
	
	var with_sufficient_gap : Array[Vector2] = available_postions.filter(func(gap): return gap.y >= area.size.x)
	var best_x : float
	if with_sufficient_gap.size() > 0:
		with_sufficient_gap.sort_custom(sort_closest_x.bind(area.position))
		best_x = with_sufficient_gap[0].x
	else:
		# sorting descending by gap size (Vector2.y)
		available_postions.sort_custom(func(v1, v2): return v1.y > v2.y)
		best_x = available_postions[0].x
	
	var unclipped := Rect2(area)
	unclipped.position.x = best_x
	return unclipped



func sort_closest_x(v1 : Vector2, v2 : Vector2, reference : Vector2) -> bool:
	return absf(v1.x - reference.x) < absf(v2.x - reference.x)

func sort_ascending_x(area_a : Rect2i, area_b : Rect2i) -> bool:
	return area_a.position.x < area_b.position.x


func is_closer(rect_a : Rect2, rect_b : Rect2, reference : Rect2) -> bool:
	var point_a : Vector2 = closest_edge(rect_a, reference)
	var point_b : Vector2 = closest_edge(rect_b, reference)
	var reference_center : Vector2 = reference.get_center()

	return reference_center.distance_squared_to(point_a) < reference_center.distance_squared_to(point_b)

## Returns the closes edge on the first area to the second
func closest_edge(from : Rect2, to : Rect2):
	var top : bool = to.position.y > from.position.y
	var left : bool = to.position.x < from.position.x

	if top:
		return from.position if left else from.position + Vector2(from.size.x, 0)
	else:
		return from.position + Vector2(0, from.size.y) if left else from.position + from.size


func create_finish_area(height : float) -> Node2D:
	var finish_area = END.instantiate()
	finish_area.position = Vector2(0, height)
	finish_area.game_finished.connect(on_game_finished)
	platform_node.add_child(finish_area)
	return finish_area


#TODO: Remove
func on_game_finished(leaderboard : Array) -> void:
	game_finished.emit(leaderboard)

func trim_boundry(boundery : Limit, trim : Vector2) -> Limit: 
	return Limit.new(Rect2(boundery.min + trim / 2.0, boundery.max - boundery.min - trim))

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

@warning_ignore("shadowed_global_identifier")
class Limit:
	var max : Vector2
	var min : Vector2
	
	func _init(area : Rect2) -> void:
		if area is Rect2:
			min = area.position
			max = area.position + area.size

