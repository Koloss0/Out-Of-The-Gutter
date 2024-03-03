@tool
extends Node

@export var sequential : bool

var markers : Array[Marker2D] = []
var sequence_index : int = -1
var sequence_mutex : Mutex = Mutex.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()

func reset() -> void:
	sequence_mutex.lock()
	sequence_index = 0
	sequence_mutex.unlock()

func next() -> Vector2:
	return get_next_point() if sequential else get_random_point()

func get_next_point() -> Vector2:
	var point : Vector2
	sequence_mutex.lock()
	sequence_index += 1
	if sequence_index > markers.size():
		sequence_index = 0
	point = get_point(sequence_index)
	sequence_mutex.unlock()
	return point

func get_point(index : int) -> Vector2:
	if markers.size() == 0: return Vector2.ZERO
	var point : Vector2
	point = markers[index % markers.size()].position
	return point

func get_random_point() -> Vector2:
	return get_point(randi_range(0, markers.size() - 1))

func update_markers() -> void:
	sequence_mutex.lock()
	markers.clear()
	markers.append_array(get_children().filter(is_marker))
	sequence_mutex.unlock()

func add_marker(index : int, marker : Marker2D):
	sequence_mutex.lock()
	if index >= markers.size():
		markers.append(marker)
	else:
		markers.insert(index, marker)
	sequence_mutex.unlock()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	if markers.size() == 0: warnings.append("Supplier requires Marker2D children to operate on.")
	return warnings

func is_marker(node) -> bool:
	return node is Marker2D


func _on_child_order_changed() -> void:
	update_markers()
	if Engine.is_editor_hint():
		update_configuration_warnings()


func _on_child_entered_tree(node: Node) -> void:
	if is_marker(node):
		add_marker(node.get_index(), node)
		if Engine.is_editor_hint():
			update_configuration_warnings()
