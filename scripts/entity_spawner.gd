@tool
class_name EntitySpawner
extends MultiplayerSpawner

@export var player_entity : PackedScene:
	set = set_player_entity
	
@export var bot_entity : PackedScene:
	set = set_bot_entity

var spawnpoint_supplier : SpawnpointSupplier


func _ready() -> void:
	set_spawn_function(create_entity.bind())
	clear_spawnable_scenes()
	add_spawnable_scene(player_entity.resource_path)
	if bot_entity: add_spawnable_scene(bot_entity.resource_path)

func create_player(player_info: PlayerInfo) -> Node2D:
	var player = player_entity.instantiate()
	player.name = str(player_info.peer_id)
	player.position = spawnpoint_supplier.next()
	player.player_info = player_info
	return player

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
	if not spawnpoint_supplier: warnings.append("Spawner must have a SpawnpointProvider child.")
	return warnings

func find_first_supplier() -> SpawnpointSupplier:
	for node in get_children():
		if node is SpawnpointSupplier:
			return node
	return null

func create_entity(info) -> Node2D:
	if not info is Dictionary:
		push_error("Invalid data received to create entity. Obj: %s, Type: %s" % [info, info.type_string()])
		return null
		
	var player_info = PlayerInfo.from_dictionary(info)
	
	if player_info:
		match player_info.type:
			PlayerInfo.EntityType.PLAYER:
				return create_player(player_info)
			PlayerInfo.EntityType.BOT:
				pass #TODO
	else:
		push_error("Unable to create PlayerInfo from dictionary.\nObj: %s" % info)
			
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
