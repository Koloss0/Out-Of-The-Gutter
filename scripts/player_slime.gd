extends SlimeEntity

@onready var gesture_start_area: Area2D = $InputAreas/GestureStartArea
@onready var arrow_sprite : Sprite2D = $Arrow
@onready var min_jump_radius: CollisionShape2D = $InputAreas/MinJumpInput/CollisionShape2D
@onready var max_jump_radius: CollisionShape2D = $InputAreas/MaxJummpInput/CollisionShape2D

var peer_id: int
var jump_input_strength : float

# Used to shake the jump indicator arrow
@export_group("Arrow Input Feedback", "jitter_")
@export var jitter_max_offset : float = PI / 42.0
@export var jitter_speed_scale : float = 9
@export_range(0, 1) var jitter_start_thresh : float = 0.5
@export var jitter_intensity_curve : Curve
var jitter_time : float

func _ready():
	set_process_locally(false)
	arrow_sprite.hide()

# called directly by player spawner
func init(info: PlayerInfo):
	set_multiplayer_authority(info.peer_id)
	peer_id = info.peer_id
	player_sprite.modulate = info.color
	
	set_process_locally(is_multiplayer_authority())

func set_process_locally(enabled : bool):
	set_process(enabled)
	set_physics_process(enabled)
	gesture_start_area.input_pickable = enabled
	set_process_input(enabled)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func _process(delta):
	if ready_to_jump:
		hold_delta = get_local_mouse_position()
		jump_input_strength = clamp(get_input_strength(), 0.0, 1.0)
		
		var above_thresh : bool = jump_input_strength > 0
		if above_thresh != arrow_sprite.visible:
			arrow_sprite.visible = above_thresh
			jitter_time = 0
		if above_thresh:
			update_jump_indicator(delta)


@warning_ignore("unused_parameter")
func _on_touch_box_input(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			arrow_sprite.set_visible(true)
			set_ready_to_jump.rpc(true)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if ready_to_jump and not event.pressed:
			if on_ground:
				var input_radius : float = hold_delta.length()
				if input_radius >= min_jump_radius.shape.radius: 
					input_radius -= min_jump_radius.shape.radius
					var input_strength : float = input_radius / (max_jump_radius.shape.radius - min_jump_radius.shape.radius)
					jump(hold_delta, clamp(input_strength, 0.0, 1.0))
			
			set_ready_to_jump.rpc(false)
			arrow_sprite.set_visible(false)

func get_input_strength() -> float:
	return (hold_delta.length() - min_jump_radius.shape.radius) / (max_jump_radius.shape.radius - min_jump_radius.shape.radius)

func update_jump_indicator(delta : float):
	if jump_input_strength > jitter_start_thresh:
		var jitter_intensity : float = (jump_input_strength - jitter_start_thresh) / (1 - jitter_start_thresh)
		jitter_time += delta * jitter_speed_scale * jitter_intensity_curve.sample(jitter_intensity)
		arrow_sprite.rotation = oscillate(hold_delta.angle(), jitter_max_offset * jump_input_strength, jitter_time)
	else:
		jitter_time = 0
		arrow_sprite.rotation = hold_delta.angle()

func oscillate(value : float, radius : float, time : float):
	return value + radius * sin(time * PI * 2)
