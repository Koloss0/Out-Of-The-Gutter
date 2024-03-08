extends StaticBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape

func disable_collision(disabled : bool = true):
	collision_shape.disabled = disabled

func get_collision_rect() -> Rect2:
	return collision_shape.shape.get_rect()
