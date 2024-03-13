extends GameScreen

const TAG_COMPONENT : PackedScene = preload("res://scenes/components/tag_component.tscn")

@onready var playable_area: PlayableArea = $World/PlayableArea
@onready var platform_generator: PlatformGenerator = $World/PlatformGenerator
@onready var entity_spawner: EntitySpawner = $World/EntitySpawner
@onready var camera_manager: CameraManager = $World/CameraManager

var settings : HotPotatoSettings
var map_rect : Rect2i

var tagged_player : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	
	MusicPlayer.play_Lobby_music()
	
	if is_multiplayer_authority():
		settings = ResourceHolder.take() as HotPotatoSettings
		map_rect = Rect2i(-settings.size / 2, settings.size)
		register_settings(map_rect, settings.generator_seed, settings.player_timeout)
		#TODO
		Net.start()


@rpc("authority", "call_remote", "reliable")
func register_settings(map_size : Rect2i, map_seed : int, player_timeout : float):
	playable_area.generate_map(map_size)
	platform_generator.generate_platforms(playable_area.get_playable_rect(), map_seed)
	pass

func attach_tag_component(player : Node2D):
	var component = TAG_COMPONENT.instantiate()
	# TODO: Connect player tagged signal
	player.add_child(component)

# Called when a client connects to the server.
func on_peer_connected(peer_id: int):
	if is_multiplayer_authority():
		register_settings.rpc_id(peer_id, map_rect, settings.generator_seed, settings.player_timeout)


# Called when a client successfully joins the session.
func on_player_registered(peer_id: int):
	if is_multiplayer_authority():
		var player_info = Net.player_data[peer_id]
		var player_character = entity_spawner.spawn(player_info.to_dictionary())
		_on_entity_spawned(player_character)
		

# Called when a client leaves the session.
func on_player_deregistered(peer_id: int):
	pass

# Called when a client disconnects from the server.
func on_peer_disconnected(peer_id: int):
	pass

# Called when the local machine connects to a server.
func on_connected_to_server():
	pass

# Called when the local machine fails to connect to a server.
func on_connection_failed():
	pass

# Called when the local machine disconnects from a server.
func on_server_disconnected():
	pass


func _on_entity_spawned(node: Node) -> void:
	if node.is_multiplayer_authority():
		camera_manager.start_tracking(node)

func _on_entity_despawned(node: Node) -> void:
	if node.is_multiplayer_authority():
		camera_manager.stop_tracking()