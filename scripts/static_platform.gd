extends StaticBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func disable_collision(disabled : bool = true):
	collision_shape.disabled = disabled

func get_collision_rect() -> Rect2:
	return collision_shape.shape.get_rect()
