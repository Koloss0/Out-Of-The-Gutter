extends CharacterBody2D

@export var jump_force := 1000.0
@export var friction := 0.95

@onready var player_sprite = $Sprite2D
@onready var arrow_sprite = $Arrow
@onready var touch_box = $TouchBox

@onready var ray_cast_left = $RayCastLeft
@onready var ray_cast_center = $RayCastCenter
@onready var ray_cast_right = $RayCastRight


var peer_id: int

var held_down := false : set = set_held_down

var jump_velocity := Vector2.ZERO
var hold_delta := Vector2.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	touch_box.input_event.connect(on_touch_box_input)

# called directly by player spawner
func init(info: PlayerInfo):
	set_multiplayer_authority(info.peer_id)
	peer_id = info.peer_id
	player_sprite.modulate = info.color


func _physics_process(delta):
	if not held_down:
		if on_ground():
			player_sprite.play("idle")
		else:
			player_sprite.play("jump")
	
	if held_down and on_ground():
		player_sprite.play("squish")
		
	if is_multiplayer_authority():
		if on_ground():
			if jump_velocity.length() > 0.0:
				velocity += jump_velocity;
				jump_velocity = Vector2.ZERO
			velocity.x *= friction
		else:
			velocity.y += gravity * delta

		move_and_slide()
		
		update_pos.rpc(position)

@rpc("unreliable")
func update_pos(pos: Vector2):
	position = pos

func _process(delta):
	if is_multiplayer_authority() and held_down:
		hold_delta = get_local_mouse_position()
		arrow_sprite.rotation = hold_delta.angle()

func on_touch_box_input(viewport: Node, event: InputEvent, shape_idx: int):
	if is_multiplayer_authority() and event is InputEventMouseButton:
		set_held_down(true)

func _input(event):
	if is_multiplayer_authority():
		if event is InputEventMouseButton:
			if not event.pressed:
				if held_down:
					jump_velocity = hold_delta.normalized() * jump_force
				set_held_down(false)

func set_held_down(new_held_down: bool):
	held_down = new_held_down
	arrow_sprite.visible = held_down
	
	if not held_down:
		player_sprite.play("idle")

@rpc
func update_held_down(new_held_down: bool):
	held_down = new_held_down
	
	if not held_down:
		player_sprite.play("idle")

func on_ground() -> bool:
	return ray_cast_left.is_colliding() or ray_cast_center.is_colliding() or ray_cast_right.is_colliding()
