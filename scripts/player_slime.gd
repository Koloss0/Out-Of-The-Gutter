extends SlimeEntity

@onready var gesture_start_area: Area2D = $InputAreas/GestureStartArea
@onready var arrow_sprite : Sprite2D = $Arrow
@onready var min_jump_radius: CollisionShape2D = $InputAreas/MinJumpInput/CollisionShape2D
@onready var max_jump_radius: CollisionShape2D = $InputAreas/MaxJummpInput/CollisionShape2D

var peer_id: int

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

func _process(_delta):
	if ready_to_jump:
		hold_delta = get_local_mouse_position()
		arrow_sprite.rotation = hold_delta.angle()

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
				var input_radius : float = (position - event.position).length()
				if input_radius >= min_jump_radius.shape.radius: 
					input_radius -= min_jump_radius.shape.radius
					var input_strength : float = input_radius / (max_jump_radius.shape.radius - min_jump_radius.shape.radius)
					jump(hold_delta, clamp(input_strength, 0.0, 1.0))
			
			set_ready_to_jump.rpc(false)
			arrow_sprite.set_visible(false)
