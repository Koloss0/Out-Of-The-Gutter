
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

const MAP_HEIGHT : int = 2
const MAP_AREA : Rect2i = Rect2i(0, -(MAP_HEIGHT - 1), 1, MAP_HEIGHT)

var map_seed: int

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	
	Net.start()
	MusicPlayer.play_Lobby_music()
	
	if is_multiplayer_authority():
		map_seed = randi()
		register_map_seed(map_seed)


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
	leader_board.show()

func on_player_registered(peer_id: int):
	var player_info = Net.player_data[peer_id]
	var player_character = player_spawner.spawn_player(player_info)
	
	# if player is controlled by local machine
	if peer_id == multiplayer.get_unique_id():
		tracking_camera.start_tracking(player_character)
	
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

func on_map_seed_received(seed: int):
	playable_area.generate_map(MAP_AREA)
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

@rpc("authority", "call_remote", "reliable")
func register_map_seed(seed: int):
	map_seed = seed
	on_map_seed_received(seed)

func on_peer_connected(peer_id: int):
	if is_multiplayer_authority():
		register_map_seed.rpc_id(peer_id, map_seed)
	pass

func on_peer_disconnected(peer_id: int):
	pass

func on_connected_to_server():
	pass

func on_connection_failed():
	pass

func on_server_disconnected():
	pass
