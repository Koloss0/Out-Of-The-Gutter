extends TileMap

func generate_map(playable_area : Rect2i):
	var boundry : Rect2i = Rect2i(playable_area)
	boundry.position -= Vector2i.ONE
	boundry.size += Vector2i(2, 2)
	
	#Create background to provided dimensions
	var coord : Vector2i = boundry.position
	var update_direction : Vector2i = Vector2i.RIGHT
	while boundry.has_point(coord):
		if playable_area.has_point(coord):
			set_background(coord)
		else:
			set_boundry(coord)
		coord += update_direction
		if not boundry.has_point(coord):
			update_direction = -update_direction
			coord += Vector2i.DOWN + update_direction

func set_background(coords : Vector2i):
	set_cell(0, coords, 0, Vector2i.ZERO)

func set_boundry(coords : Vector2i):
	set_cell(0, coords, 1, Vector2i.ZERO)

func get_playable_rect() -> Rect2:
	var used : Rect2i = get_used_rect()
	used.position += Vector2i.ONE
	used.size -= Vector2i(2, 2)
	var playable = Rect2(used)
	var tile_size = Vector2(tile_set.get_tile_size()) * scale
	playable.position *= tile_size
	playable.size *= tile_size
	return playable
