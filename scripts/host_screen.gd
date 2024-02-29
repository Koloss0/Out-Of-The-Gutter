extends Control

@onready var port : LineEdit = $Port

func _ready():
	if OS.is_debug_build():
		port.set_text(str(Net.DEFAULT_PORT))

func on_connect_pressed():
	Net.server_port = $Port.text
	Net.is_host = true
	SceneManager.fade_to_scene("game_screen")
	MusicPlayer.stop_music()


func _on_back_button_pressed() -> void:
	SceneManager.fade_to_scene("host_or_join")
