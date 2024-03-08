@tool
extends Node

const PLAYER_SCENE = preload("res://scenes/entities/player_slime.tscn")

var spawnpoint_supplier : SpawnpointSupplier

@export var spawn_node: Node2D :
	set = set_spawn_node

func spawn_player(player_info: PlayerInfo) -> Node2D:
	var player = PLAYER_SCENE.instantiate()
	player.name = str(player_info.peer_id)
	player.position = spawnpoint_supplier.next()
	spawn_node.add_child(player)
	player.init(player_info)
	
	# synch other player's character state
	if player_info.peer_id != multiplayer.get_unique_id():
		player.synch_state.rpc_id(player_info.peer_id, multiplayer.get_unique_id())
		
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
	if not spawnpoint_supplier: warnings.append("Spawner must have a SpawnpointProvider child.")
	return warnings

func find_first_supplier() -> SpawnpointSupplier:
	for node in get_children():
		if node is SpawnpointSupplier:
			return node
	return null

func refresh_spawnpoint_supplier():
	var first_supplier := find_first_supplier()
	if first_supplier != spawnpoint_supplier:
		spawnpoint_supplier = first_supplier
	if Engine.is_editor_hint():
		update_configuration_warnings()

func _on_child_entered_tree(node: Node) -> void:
	if node is SpawnpointSupplier:
		refresh_spawnpoint_supplier()

func _on_child_exiting_tree(node: Node) -> void:
	if node == spawnpoint_supplier:
		spawnpoint_supplier = find_first_supplier()
		if Engine.is_editor_hint():
			update_configuration_warnings()

func _on_child_order_changed() -> void:
	refresh_spawnpoint_supplier()
