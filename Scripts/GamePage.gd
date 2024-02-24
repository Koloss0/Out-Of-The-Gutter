extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	Net.start()
	MusicPlayer.play_Lobby_music()

