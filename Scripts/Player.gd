extends CharacterBody2D

@export var jump_force := 1000.0
@export var friction := 0.95

var held_down := false : set = set_held_down

var jump_velocity := Vector2.ZERO
var hold_delta := Vector2.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	$TouchBox.input_event.connect(on_touch_box_input)

# called directly by player spawner
func init(info: PlayerInfo):
	set_multiplayer_authority(info.peer_id)


func _physics_process(delta):
	if on_ground():
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

	if not held_down:
		if on_ground():
			$Sprite2D.play("idle")
		else:
			$Sprite2D.play("jump")
	
	if held_down and on_ground():
		$Sprite2D.play("squish")

	move_and_slide()

func _process(delta):
	if held_down:
		$Arrow.rotation = hold_delta.angle()

func on_touch_box_input(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton:
		set_held_down(true)

func _input(event):
	if event is InputEventMouseButton:
		if not event.pressed:
			if held_down:
				jump_velocity = hold_delta.normalized() * jump_force
			set_held_down(false)
	if event is InputEventMouseMotion:
		if held_down:
			hold_delta = event.position - position

func set_held_down(new_held_down: bool):
	held_down = new_held_down
	$Arrow.visible = held_down
	
	if not held_down:
		$Sprite2D.play("idle")

func on_ground() -> bool:
	return $RayCast2D.is_colliding() or $RayCast2D2.is_colliding() or $RayCast2D3.is_colliding()
