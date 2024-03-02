@tool
extends Node

@onready var camera_offset: Node2D = $CameraOffset

@export var default_target : Node2D:
	set = set_default_target

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stop_tracking()

func start_tracking(target : Node2D):
	camera_offset.reparent(target)
	
func stop_tracking():
	camera_offset.reparent(default_target)

func set_default_target(node : Node2D):
	default_target = node
	if Engine.is_editor_hint():
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	if not default_target: warnings.append("Spawner must have a default target node assigned.")
	return warnings
