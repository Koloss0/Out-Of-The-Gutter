class_name SlimeEntity
extends CharacterBody2D

@export var max_jump_force := 1000.0
@export var friction := 0.95

var min_jump_force : float = max_jump_force / 5.0

@onready var player_sprite = $Sprite2D

@onready var ground_detector: ShapeCast2D = $GroundDetector


var hold_delta := Vector2.UP

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


var ready_to_jump : bool = false :
	set = set_ready_to_jump

var on_ground : bool = true :
	set = set_on_ground


func _physics_process(delta):
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


func jump(direction : Vector2, input_strength : float):
	input_strength = clampf(input_strength, 0, 1)
	var force := lerpf(min_jump_force, max_jump_force, input_strength)
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
	return ground_detector.is_colliding()

## requests the authority to send the entity's state to the local machine
func synch_state() -> void:
	var authority = get_multiplayer_authority()
	_on_refresh_requested.rpc_id(authority, multiplayer.get_unique_id())
	
@rpc("any_peer", "reliable")
func _on_refresh_requested(peer_id : int) -> void:
	if not multiplayer.get_peers().has(peer_id): return
	if is_multiplayer_authority():
		refresh_state.rpc_id(peer_id, position, on_ground, ready_to_jump)

@rpc("authority", "call_remote", "reliable")
func refresh_state(pos : Vector2, grounded : bool, jump_ready : bool) -> void:
	position = pos
	if not grounded:
		on_ground = grounded
	elif jump_ready:
		ready_to_jump = jump_ready
	else:
		on_ground = grounded
