
extends AnimatableBody2D

const SPEED = 480.00
var speed_multiplier = 1

@onready var movement_path : Path2D = $MovementPath
@onready var collision_shape: CollisionShape2D = $CollisionShape
@onready var path_follow: PathFollow2D = $MovementPath/PathFollow
# Called when the node enters the scene tree for the first time.

var moving_right = false
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	path_follow.progress += delta * SPEED * speed_multiplier
	update_position()

func update_position():
	position = path_follow.get_position()

func disable_collision(disabled : bool = true):
	collision_shape.disabled = disabled

func enable_motion(enabled : bool = true):
	set_physics_process(enabled)
	

func set_movement_path(start : Vector2, end : Vector2, initial_pos : Vector2 = start):
	var new_path : Curve2D = Curve2D.new()
	
	new_path.add_point(initial_pos)
	new_path.add_point(end)
	new_path.add_point(start)
	if initial_pos != start:
		new_path.add_point(initial_pos)
	
	movement_path.set_curve(new_path)
	update_position()


func get_collision_rect() -> Rect2:
	return collision_shape.shape.get_rect()
