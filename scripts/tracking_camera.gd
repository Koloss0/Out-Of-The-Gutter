@tool
class_name CameraManager
extends Node

@export var camera_pivot : Node2D:
	set = set_camera_pivot

@export var default_target : Node2D:
	set = set_default_target

@export var entity_spawner : EntitySpawner:
	set = set_entity_spawner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stop_tracking()

func start_tracking_player(peer_id : int) -> bool:
	var character := entity_spawner.get_player_character(peer_id)
	if character == null: return false
	start_tracking(character)
	return true

func start_tracking(target : Node2D):
	camera_pivot.reparent(target)
	
func stop_tracking():
	camera_pivot.reparent(default_target)

func set_default_target(node : Node2D):
	default_target = node
	if Engine.is_editor_hint():
		update_configuration_warnings()

func set_camera_pivot(node : Node2D):
	camera_pivot = node
	if Engine.is_editor_hint():
		update_configuration_warnings()

func set_entity_spawner(node : EntitySpawner):
	entity_spawner = node
	if Engine.is_editor_hint():
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	if not camera_pivot: warnings.append("Tracker must have a camera pivot node assigned.")
	if not default_target: warnings.append("Tracker must have a default target node assigned.")
	if not entity_spawner: warnings.append("Tracker cannot track players by ID without an EntitySpawner assigned.")
	return warnings
