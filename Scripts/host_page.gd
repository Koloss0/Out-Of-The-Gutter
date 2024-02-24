extends Control

func on_connect_pressed():
	Net.server_port = $Port.text
	Net.is_host = true
	SceneManager.fade_to_scene("res://Scenes/GamePage.tscn")
	MusicPlayer.stop_music()


func _on_back_button_pressed() -> void:
	SceneManager.fade_to_scene("HostJoinPage")
