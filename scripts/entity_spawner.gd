@tool
class_name EntitySpawner
extends Node

@export var player_entity : PackedScene:
	set = set_player_entity
@export var bot_entity : PackedScene:
	set = set_bot_entity

var spawnpoint_supplier : SpawnpointSupplier

var players : Dictionary = {}

@export var spawn_node: Node2D :
	set = set_spawn_node

func spawn_player(player_info: PlayerInfo) -> Node2D:
	var player = player_entity.instantiate()
	player.name = str(player_info.peer_id)
	player.position = spawnpoint_supplier.next()
	spawn_node.add_child(player)
	player.init(player_info)
	
	players[player_info.peer_id] = player
	
	# synch other player's character state
	if player_info.peer_id != multiplayer.get_unique_id():
		player.synch_state()
		
	return player

func remove_player(peer_id: int) -> bool:
	var player = players.get(peer_id)
	if player == null: return false
	
	players.erase(peer_id)
	player.queue_free()
	return true

func get_player_character(peer_id : int) -> Node2D:
	return players[peer_id]


func set_spawn_node(node : Node2D):
	spawn_node = node
	if Engine.is_editor_hint():
		update_configuration_warnings()

func set_player_entity(scene : PackedScene):
	player_entity = scene
	if Engine.is_editor_hint():
		update_configuration_warnings()

func set_bot_entity(scene : PackedScene):
	bot_entity = scene
	if Engine.is_editor_hint():
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	if not player_entity: warnings.append("Spawner has no player entity assigned.")
	# if not bot_entity: warnings.append("Spawner has no bot entity assigned.") TODO: Uncomment once bots are implemented
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
