@tool
extends Node

@export var camera_pivot : Node2D:
	set = set_camera_pivot

@export var default_target : Node2D:
	set = set_default_target

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stop_tracking()

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

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	if not camera_pivot: warnings.append("Tracker must have a camera pivot node assigned.")
	if not default_target: warnings.append("Tracker must have a default target node assigned.")
	return warnings
