
extends AnimatableBody2D

const SPEED = 13.00
var speed_multiplier = 1

var left_bound = 240

@onready var right_bound  = get_viewport_rect().size.x - 240
# Called when the node enters the scene tree for the first time.

var moving_right = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if(position.x > right_bound):
		moving_right = false
	
	if(position.x < left_bound):
		moving_right = true
	
	if(moving_right): 
		translate(Vector2(SPEED*speed_multiplier, 0))
	else:
		translate((Vector2(-SPEED*speed_multiplier, 0)))
		

