extends Node

@onready var world: Node2D = $World
@onready var start_button: TextureButton = $Control/StartButton
@onready var countdown: Control = $Control/Countdown
@onready var platform_generator: Node2D = $World/PlatformGenerator
@onready var leader_board: Control = $Control/LeaderBoard
@onready var players = $World/Players
@onready var camera_offset = $World/Players/CameraOffset

const MAP_AREA : Rect2i = Rect2i(0, -9, 1, 10)

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
	#if is_multiplayer_authority():
		#var my_player_info = Net.player_data[multiplayer.get_unique_id()]
		#world.spawn_player(my_player_info)
		
	# Only for testing
	get_tree().call_group("platform", "set_collision", true)
	get_tree().call_group("platform", "start_moving", true)

func on_peer_connected(peer_id: int):
	pass

func on_game_finished(l: Array):
	leader_board.show()
	

func on_player_registered(peer_id: int):
	var player_info = Net.player_data[peer_id]
	world.spawn_player(player_info)
	
	if peer_id == multiplayer.get_unique_id():
		camera_start_tracking(players.get_node(str(multiplayer.get_unique_id())))
	
	if is_multiplayer_authority():
		if Net.num_players > 1:
			start_button.show()
			start_button.set_disabled(false)


func on_player_deregistered(peer_id: int):
	world.remove_player(peer_id)
	AlertDisplayer.alert("Player %s Disconnected" % peer_id)
	
	if peer_id == multiplayer.get_unique_id():
		camera_stop_tracking()
	
	if is_multiplayer_authority() and Net.num_players <= 1:
		start_button.hide()
		start_button.set_disabled(true)

func on_map_seed_received(seed: int):
	platform_generator.generate_map(MAP_AREA, seed)
	get_tree().call_group("platform", "set_collision", false)

func on_peer_disconnected(peer_id: int):
	pass

func on_connected_to_server():
	pass

func on_connection_failed():
	pass

func on_server_disconnected():
	pass

func camera_start_tracking(player : Node2D):
	camera_offset.reparent(player)
	
func camera_stop_tracking():
	camera_offset.reparent(players)

func _on_start_button_pressed() -> void:
	if Net.is_multiplayer_authority():
		start_button.hide()
	start_countdown.rpc()

@rpc("call_local")
func start_countdown():
	countdown.play_countdown()
	get_tree().call_group("platform", "set_collision", true)
	get_tree().call_group("platform", "start_moving", true)
