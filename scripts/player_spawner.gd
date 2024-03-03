@tool
extends Node

const PLAYER_SCENE = preload("res://scenes/entities/player.tscn")
@export var spawn_node: Node2D :
	set = set_spawn_node

func spawn_player(player_info: PlayerInfo, spawnpoint: Vector2) -> Node2D:
	var player = PLAYER_SCENE.instantiate()
	player.name = str(player_info.peer_id)
	player.position = spawnpoint
	spawn_node.add_child(player)
	player.init(player_info)
	return player

func remove_player(peer_id: int):
	var player = spawn_node.get_node_or_null(str(peer_id))
	if player != null:
		player.queue_free()

func set_spawn_node(node : Node2D):
	spawn_node = node
	if Engine.is_editor_hint():
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	if not spawn_node: warnings.append("Spawner must have a spawn node assigned.")
	return warnings
