extends Node

@onready var world: Node2D = $World

# Called when the node enters the scene tree for the first time.
func _ready():
	Net.peer_connected.connect(on_peer_connected)
	Net.player_registered.connect(on_player_registered)
	Net.player_deregistered.connect(on_player_deregistered)
	Net.peer_disconnected.connect(on_peer_disconnected)
	Net.connected_to_server.connect(on_connected_to_server)
	Net.connection_failed.connect(on_connection_failed)
	Net.server_disconnected.connect(on_server_disconnected)
	
	Net.start()
	MusicPlayer.play_Lobby_music()
	
	#if is_multiplayer_authority():
		#var my_player_info = Net.player_data[multiplayer.get_unique_id()]
		#world.spawn_player(my_player_info)

func on_peer_connected(peer_id: int):
	pass

func on_player_registered(peer_id: int):
	var player_info = Net.player_data[peer_id]
	world.spawn_player(player_info)


func on_player_deregistered(peer_id: int):
	world.remove_player(peer_id)
	AlertDisplayer.alert("Player %s Disconnected" % peer_id)


func on_peer_disconnected(peer_id: int):
	pass
	
func on_connected_to_server():
	pass

func on_connection_failed():
	pass

func on_server_disconnected():
	pass
