
extends GameScreen

@onready var entity_spawner: EntitySpawner = $World/EntitySpawner
@onready var start_button: TextureButton = $CanvasLayer/Overlays/StartButton
@onready var countdown: Control = $CanvasLayer/Overlays/Countdown
@onready var platform_generator: PlatformGenerator = $World/PlatformGenerator
@onready var leader_board: Control = $CanvasLayer/Overlays/LeaderBoard
@onready var entities : Node2D = $World/Entities
@onready var playable_area: PlayableArea = $World/PlayableArea
@onready var camera_manager: CameraManager = $World/CameraManager

var settings : RaceSettings

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	
	MusicPlayer.play_Lobby_music()
	
	if is_multiplayer_authority():
		settings = ResourceHolder.take() as RaceSettings
		register_settings(settings.map_height, settings.map_seed)
		Net.start()

func get_map_area(height : int) -> Rect2i:
	return Rect2i(0, -(height - 1), 1, height)

func _on_start_button_pressed() -> void:
	if is_multiplayer_authority():
		start_button.hide()
		start_countdown.rpc()

func on_game_finished(l: Array):
	show_leaderboard.rpc(l)

func _on_countdown_finished() -> void:
	get_tree().call_group("platforms", "disable_collision", false)
	get_tree().call_group("moving_platforms", "enable_motion", true)

@warning_ignore("unused_parameter")
@rpc("any_peer", "call_local", "reliable")
func show_leaderboard(l: Array):
	MusicPlayer.play_Lobby_music()
	leader_board.show()

func on_player_registered(peer_id: int):
	if is_multiplayer_authority():
		var player_info = Net.player_data[peer_id]
		var player_character = entity_spawner.spawn(player_info.to_dictionary())
		_on_entity_spawned(player_character)
		
		if Net.num_players > 1:
			start_button.show()
			start_button.set_disabled(false)

func get_player(peer_id : int):
	return entities.get_node(str(peer_id))

func on_player_deregistered(peer_id: int):
	if is_multiplayer_authority():
		if peer_id == multiplayer.get_unique_id():
			camera_manager.stop_tracking()
		if Net.num_players <= 1:
			start_button.hide()
			start_button.set_disabled(true)
		get_player(peer_id).queue_free()

@warning_ignore("shadowed_global_identifier")
@rpc("authority", "call_remote", "reliable")
func register_settings(height : int, seed : int):
	playable_area.generate_map(get_map_area(height))
	var playable_rect = playable_area.get_playable_rect()
	platform_generator.generate_platforms(playable_rect, seed)
	platform_generator.create_finish_area(playable_rect.position.y)
	platform_generator.game_finished.connect(on_game_finished)
	get_tree().call_group("platforms", "disable_collision", true)

@rpc("authority", "call_local", "reliable")
func start_countdown():
	MusicPlayer.play_gameplay_music()
	countdown.play_countdown()

func on_peer_connected(peer_id: int):
	if is_multiplayer_authority():
		register_settings.rpc_id(peer_id, settings.map_height, settings.map_seed)

func on_peer_disconnected(peer_id: int):
	pass

func on_connected_to_server():
	pass

func on_connection_failed():
	pass

func on_server_disconnected():
	pass


func _on_entity_spawned(node: Node) -> void:
	if node.is_multiplayer_authority():
		camera_manager.start_tracking(node)

func _on_entity_despawned(node: Node) -> void:
	if node.is_multiplayer_authority():
		camera_manager.stop_tracking()
