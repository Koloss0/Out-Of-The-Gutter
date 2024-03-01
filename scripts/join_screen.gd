extends Control

@onready var ip = $IP
@onready var port = $Port

func _ready() -> void:
	if OS.is_debug_build():
		ip.set_text(str(Net.DEFAULT_ADDRESS))
		port.set_text(str(Net.DEFAULT_PORT))
		
func on_connect_pressed():
	Net.server_ip = $IP.text
	Net.server_port = $Port.text
	Net.is_host = false
	SceneManager.fade_to_scene("game_screen")
	MusicPlayer.stop_music()


func _on_back_button_pressed() -> void:
	SceneManager.fade_to_scene("host_or_join")



