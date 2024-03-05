extends TileMap

@export_group("Assigned Cameras")
## The playable area will automatically update the limits of assigned camreas.
@export var initial_cameras : Array[Camera2D] = []
@export var limits_offset : Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO):
	set = set_camera_limits_offset

var _assigned_cameras : Array[Camera2D] = []
var _camera_array_mutex : Mutex = Mutex.new()

func _ready() -> void:
	_assigned_cameras.clear()
	initial_cameras.filter(func(camera): camera != null)
	_assigned_cameras.append_array(initial_cameras)
	update_assigned_cameras()

func generate_map(playable_area : Rect2i) -> void:
	var boundery : Rect2i = Rect2i(playable_area)
	boundery.position -= Vector2i.ONE
	boundery.size += Vector2i(2, 2)
	
	#Create background to provided dimensions
	var coord : Vector2i = boundery.position
	var update_direction : Vector2i = Vector2i.RIGHT
	while boundery.has_point(coord):
		if playable_area.has_point(coord):
			set_background(coord)
		else:
			set_boundry(coord)
		coord += update_direction
		if not boundery.has_point(coord):
			update_direction = -update_direction
			coord += Vector2i.DOWN + update_direction
	
	update_assigned_cameras()

func set_background(coords : Vector2i) -> void:
	set_cell(0, coords, 0, Vector2i.ZERO)

func set_boundry(coords : Vector2i) -> void:
	set_cell(0, coords, 1, Vector2i.ZERO)

func get_playable_rect() -> Rect2:
	var used : Rect2i = get_used_rect()
	
	#assumes the outer edge is unplayable (boundery)
	used.position += Vector2i.ONE
	used.size -= Vector2i(2, 2)
	
	var playable = convert_to_pixels(used)
	return playable

func convert_to_pixels(area : Rect2i) -> Rect2:
	var pixels = Rect2(area)
	var tile_size = get_tile_size()
	pixels.position *= tile_size
	pixels.size *= tile_size
	return pixels

func get_tile_size() -> Vector2:
	return Vector2(tile_set.get_tile_size()) * scale

func limit_camera_to_area(camera : Camera2D, offset_margin : Rect2 = limits_offset) -> void:
	var limits := get_boundry(offset_margin)
	set_camera_limits(camera, limits)

func get_boundry(offset_margin : Rect2 = limits_offset) -> Rect2:
	var limits := get_playable_rect()
	limits.position += offset_margin.position
	limits.size += offset_margin.size - offset_margin.position
	return limits

func update_assigned_cameras() -> void:
	_camera_array_mutex.lock()
	if _assigned_cameras.size() > 0:
		var limits = get_boundry()
		for camera in _assigned_cameras:
			set_camera_limits(camera, limits)
	_camera_array_mutex.unlock()

func set_camera_limits(camera : Camera2D, limits : Rect2):
	camera.limit_left = limits.position.x
	camera.limit_top = limits.position.y
	camera.limit_right = limits.size.x
	camera.limit_bottom = limits.size.y - get_tile_size().y

func register_camera(camera : Camera2D) -> void:
	if not camera: return
	
	_camera_array_mutex.lock()
	_assigned_cameras.append(camera)
	_camera_array_mutex.unlock()
	
	limit_camera_to_area(camera)

func deregister_camera(camera : Camera2D) -> bool:
	_camera_array_mutex.lock()
	var index : int = _assigned_cameras.find(camera)
	var found : bool = index >= 0
	if found:
		_assigned_cameras.pop_at(index)
	_camera_array_mutex.unlock()
	return found

func set_camera_limits_offset(offset : Rect2):
	limits_offset = offset
	update_assigned_cameras()
