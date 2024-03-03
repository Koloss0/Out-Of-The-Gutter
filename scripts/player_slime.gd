extends SlimeEntity

@onready var touch_box = $TouchBox
@onready var arrow_sprite = $Arrow

var peer_id: int
var initialized : bool = false

func _ready():
	touch_box.input_event.connect(on_touch_box_input)
	set_process_locally(initialized)

# called directly by player spawner
func init(info: PlayerInfo):
	set_multiplayer_authority(info.peer_id)
	peer_id = info.peer_id
	player_sprite.modulate = info.color
	initialized = true
	
	set_process_locally(is_multiplayer_authority())

func set_process_locally(enabled : bool):
	set_process(enabled)
	set_physics_process(enabled)

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		super._physics_process(delta)

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
