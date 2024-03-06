extends SlimeEntity

@onready var touch_box: Area2D = $TouchBox
@onready var arrow_sprite : Sprite2D = $Arrow

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
	touch_box.input_pickable = enabled
	set_process_input(enabled)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func _process(delta):
	if ready_to_jump:
		hold_delta = get_local_mouse_position()
		arrow_sprite.rotation = hold_delta.angle()

func _on_touch_box_input(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			arrow_sprite.set_visible(true)
			set_ready_to_jump.rpc(true)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if ready_to_jump and not event.pressed:
			if on_ground: jump(hold_delta, jump_force)
			set_ready_to_jump.rpc(false)
			arrow_sprite.set_visible(false)
