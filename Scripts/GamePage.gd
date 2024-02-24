extends Node

@onready var world: Node2D = $World

# Called when the node enters the scene tree for the first time.
func _ready():
	Net.peer_connected.connect(on_peer_connected)
	Net.peer_disconnected.connect(on_peer_disconnected)
	Net.connected_to_server.connect(on_connected_to_server)
	Net.connection_failed.connect(on_connection_failed)
	
	 connected_to_server()
signal connection_failed()
signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)
signal server_disconnected()
	Net.start()
	MusicPlayer.play_Lobby_music()
	
	if is_multiplayer_authority():
		var my_player_info = Net.player_data[multiplayer.get_unique_id()]
		world.spawn_player(my_player_info)

func on_peer_connected(peer_id: int):
	if !is_multiplayer_authority():
		var player_info = Net.player_data[peer_id]
		world.spawn_player(player_info)
