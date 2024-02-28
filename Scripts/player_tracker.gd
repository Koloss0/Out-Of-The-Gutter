extends Node2D

const OFFSET = 200.0

var target: Node2D = null

func _process(delta):
	if target:
		if target.position.y - get_viewport_rect().size.y/2.0 - OFFSET < position.y:
			position.y = target.position.y - get_viewport_rect().size.y/2.0 - OFFSET

func start_following_target(node: Node2D):
	target = node

func stop_following_target():
	target = null
