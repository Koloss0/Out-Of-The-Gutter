extends TileMap

func set_background(coords : Vector2i):
	set_cell(0, coords, 0, Vector2i.ZERO)

func set_boundry(coords : Vector2i):
	set_cell(0, coords, 1, Vector2i.ZERO)
