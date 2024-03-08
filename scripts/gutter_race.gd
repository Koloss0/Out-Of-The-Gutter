
extends GameScreen

@onready var player_spawner: Node = $World/PlayerSpawner
@onready var start_button: TextureButton = $CanvasLayer/Overlays/StartButton
@onready var countdown: Control = $CanvasLayer/Overlays/Countdown
@onready var platform_generator: Node = $World/PlatformGenerator
@onready var leader_board: Control = $CanvasLayer/Overlays/LeaderBoard
@onready var players = $World/Players
@onready var playable_area: TileMap = $World/PlayableArea
@onready var tracking_camera: Node = $World/TrackingCamera
@onready var camera: Camera2D = $World/Players/CameraOffset/Camera2D

var settings : RaceSettings

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	
	Net.start()
	MusicPlayer.play_Lobby_music()
	
	if is_multiplayer_authority():
		settings = ResourceHolder.take()
		register_settings(settings.map_height, settings.map_seed)

func get_map_area(height : int) -> Rect2i:
	return Rect2i(0, -(height - 1), 1, height)

func _on_start_button_pressed() -> void:
	if is_multiplayer_authority():
		start_button.hide()
		start_countdown.rpc()

func on_game_finished(l: Array):
	show_leaderboard.rpc(l)

func _on_countdown_finished() -> void:
	get_tree().call_group("platform", "disable_collision", false)
	get_tree().call_group("platform", "enable_motion", true)

@rpc("any_peer", "call_local", "reliable")
func show_leaderboard(l: Array):
	MusicPlayer.stop_in_game_music()
	leader_board.show()

func on_player_registered(peer_id: int):
	var player_info = Net.player_data[peer_id]
	var player_character = player_spawner.spawn_player(player_info)
	
	# if player is controlled by local machine
	if peer_id == multiplayer.get_unique_id():
		tracking_camera.start_tracking(players.get_node(str(peer_id)))
	
	if is_multiplayer_authority():
		if Net.num_players > 1:
			start_button.show()
			start_button.set_disabled(false)


func on_player_deregistered(peer_id: int):
	player_spawner.remove_player(peer_id)
	AlertDisplayer.alert("Player %s Disconnected" % peer_id)
	
	if peer_id == multiplayer.get_unique_id():
		tracking_camera.stop_tracking()
	
	if is_multiplayer_authority() and Net.num_players <= 1:
		start_button.hide()
		start_button.set_disabled(true)

@rpc("authority", "call_remote", "reliable")
func register_settings(height : int, seed : int):
	playable_area.generate_map(get_map_area(height))
	var playable_hight = -playable_area.get_playable_rect().size.y
	platform_generator.generate_platforms(playable_hight, seed)
	platform_generator.create_finish_area(playable_hight)
	platform_generator.game_finished.connect(on_game_finished)
	get_tree().call_group("platform", "disable_collision", true)

@rpc("authority", "call_local", "reliable")
func start_countdown():
	MusicPlayer.stop_music()
	MusicPlayer.play_in_Game_music()
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
