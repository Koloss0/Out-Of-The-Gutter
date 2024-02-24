extends CharacterBody2D

@export var jump_force := 600.0
@export var friction := 0.95

var held_down := false

var jump_velocity := Vector2.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	input_event.connect(on_collider_input)

func _physics_process(delta):
	if is_on_floor():
		if jump_velocity.length() > 0.0:
			velocity += jump_velocity;
			jump_velocity = Vector2.ZERO
		velocity.x *= friction
	else:
		velocity.y += gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var direction = Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func on_collider_input(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton:
		held_down = true

func _input(event):
	if event is InputEventMouseButton:
		if not event.pressed:
			if held_down:
				var delta = event.position - position
				jump_velocity = delta.normalized() * jump_force
			held_down = false
