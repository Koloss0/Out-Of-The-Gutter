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
var initialized : bool = false

var ready_to_jump : bool = false :
	set = set_ready_to_jump

var jump_velocity := Vector2.ZERO
var hold_delta := Vector2.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var on_ground : bool = true

func _ready():
	touch_box.input_event.connect(on_touch_box_input)
	if not initialized:
		set_process(false)
		set_physics_process(false)

# called directly by player spawner
func init(info: PlayerInfo):
	set_multiplayer_authority(info.peer_id)
	peer_id = info.peer_id
	player_sprite.modulate = info.color
	initialized = true
	set_process(true)
	set_physics_process(true)


func _physics_process(delta):
	if is_multiplayer_authority():
		var new_on_ground : bool = check_on_ground()
		
		if new_on_ground != on_ground:
			set_on_ground.rpc(new_on_ground)
		
		if on_ground:
			velocity.x *= friction
		else:
			velocity.y += gravity * delta
		
		move_and_slide()
		
		update_pos.rpc(position)


@rpc("call_remote", "unreliable")
func update_pos(pos: Vector2):
	position = pos

func _process(delta):
	if is_multiplayer_authority() and ready_to_jump:
		hold_delta = get_local_mouse_position()
		arrow_sprite.rotation = hold_delta.angle()

func on_touch_box_input(viewport: Node, event: InputEvent, shape_idx: int):
	if is_multiplayer_authority():
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				arrow_sprite.set_visible(true)
				set_ready_to_jump.rpc(true)

func _input(event):
	if is_multiplayer_authority():
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if ready_to_jump and not event.pressed:
				if on_ground: jump(hold_delta, jump_force)
				set_ready_to_jump.rpc(false)
				arrow_sprite.set_visible(false)


func jump(direction : Vector2, force : float):
	velocity = direction.normalized() * force

func update_animation():
	if not on_ground:
		player_sprite.play("jump")
	elif ready_to_jump:
		player_sprite.play("squish")
	else:
		player_sprite.play("idle")

@rpc("call_local", "reliable")
func set_ready_to_jump(state: bool):
	ready_to_jump = state
	update_animation()

@rpc("call_local", "reliable")
func set_on_ground(state : bool):
	on_ground = state
	update_animation()

func check_on_ground() -> bool:
	return ray_cast_left.is_colliding() or ray_cast_center.is_colliding() or ray_cast_right.is_colliding()
