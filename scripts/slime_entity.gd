class_name SlimeEntity
extends CharacterBody2D

@export var jump_force := 1000.0
@export var friction := 0.95

@onready var player_sprite = $Sprite2D

@onready var ground_detector: ShapeCast2D = $GroundDetector


var ready_to_jump : bool = false :
	set = set_ready_to_jump

var jump_velocity := Vector2.ZERO
var hold_delta := Vector2.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var on_ground : bool = true


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
	return ground_detector.is_colliding()
