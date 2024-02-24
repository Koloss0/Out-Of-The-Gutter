extends Node

@onready var world: Node2D = $World

# Called when the node enters the scene tree for the first time.
func _ready():
	Net.peer_connected.connect(on_peer_connected)
	Net.start()
	MusicPlayer.play_Lobby_music()
	var my_player_info = PlayerInfo.new(multiplayer.get_unique_id())
	world.spawn_player(my_player_info)

func on_peer_connected(peer_id: int):
	var player_info = PlayerInfo.new(peer_id)
	world.spawn_player(player_info)
