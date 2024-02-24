extends Node

@onready var world: Node2D = $World

# Called when the node enters the scene tree for the first time.
func _ready():
	Net.start()
	MusicPlayer.play_Lobby_music()
	var my_player_info = PlayerInfo.new(multiplayer.get_unique_id())
	world.spawn_player(my_player_info)
