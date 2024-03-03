extends TileMap

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

func limit_camera_to_area(camera : Camera2D, offset_margin : Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)) -> void:
	var limits := get_playable_rect()
	limits.position += offset_margin.position
	limits.size += offset_margin.size - offset_margin.position
	camera.limit_left = limits.position.x
	camera.limit_top = limits.position.y
	camera.limit_right = limits.size.x
	camera.limit_bottom = limits.size.y - get_tile_size().y


