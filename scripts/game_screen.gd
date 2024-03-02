class_name GameScreen
extends Node

@onready var player_spawner: Node = $World/PlayerSpawner
@onready var start_button: TextureButton = $CanvasLayer/Overlays/StartButton
@onready var countdown: Control = $CanvasLayer/Overlays/Countdown
@onready var platform_generator: Node = $World/PlatformGenerator
@onready var leader_board: Control = $CanvasLayer/Overlays/LeaderBoard
@onready var players = $World/Players
@onready var playable_area: TileMap = $World/PlayableArea
@onready var camera: Node = $World/TrackingCamera
@onready var spawnpoint: Marker2D = $World/Spawnpoint

const MAP_HEIGHT : int = 2
const MAP_AREA : Rect2i = Rect2i(0, -(MAP_HEIGHT - 1), 1, MAP_HEIGHT)

# Called when the node enters the scene tree for the first time.
func _ready():
	Net.peer_connected.connect(on_peer_connected)
	Net.map_seed_received.connect(on_map_seed_received)
	Net.player_registered.connect(on_player_registered)
	Net.player_deregistered.connect(on_player_deregistered)
	Net.peer_disconnected.connect(on_peer_disconnected)
	Net.connected_to_server.connect(on_connected_to_server)
	Net.connection_failed.connect(on_connection_failed)
	Net.server_disconnected.connect(on_server_disconnected)
	
	Net.start()
	MusicPlayer.play_Lobby_music()
	
	platform_generator.game_finished.connect(on_game_finished)


func on_peer_connected(peer_id: int):
	pass

func on_game_finished(l: Array):
	show_leaderboard.rpc(l)

@rpc("call_local", "reliable")
func show_leaderboard(l: Array):
	leader_board.show()

func on_player_registered(peer_id: int):
	var player_info = Net.player_data[peer_id]
	var player_character = player_spawner.spawn_player(player_info, spawnpoint.position)
	
	if peer_id == multiplayer.get_unique_id():
		camera.start_tracking(player_character)
	
	if is_multiplayer_authority():
		if Net.num_players > 1:
			start_button.show()
			start_button.set_disabled(false)


func on_player_deregistered(peer_id: int):
	player_spawner.remove_player(peer_id)
	AlertDisplayer.alert("Player %s Disconnected" % peer_id)
	
	if peer_id == multiplayer.get_unique_id():
		camera.stop_tracking()
	
	if is_multiplayer_authority() and Net.num_players <= 1:
		start_button.hide()
		start_button.set_disabled(true)

func on_map_seed_received(seed: int):
	playable_area.generate_map(MAP_AREA)
	var playable_hight = -playable_area.get_playable_rect().size.y
	platform_generator.generate_platforms(playable_hight, seed)
	platform_generator.create_finish_area(playable_hight)
	get_tree().call_group("platform", "disable_collision", true)

func on_peer_disconnected(peer_id: int):
	pass

func on_connected_to_server():
	pass

func on_connection_failed():
	pass

func on_server_disconnected():
	pass

func _on_start_button_pressed() -> void:
	if Net.is_multiplayer_authority():
		start_button.hide()
	start_countdown.rpc()

@rpc("call_local")
func start_countdown():
	MusicPlayer.stop_music()
	MusicPlayer.play_in_Game_music()
	countdown.play_countdown()


func _on_countdown_finished() -> void:
	get_tree().call_group("platform", "disable_collision", false)
	get_tree().call_group("platform", "enable_motion", true)
