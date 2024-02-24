extends Control

func _ready():
	MusicPlayer.play_main_menu_music()

func _on_quit_pressed():
	get_tree().quit()


func _on_start_pressed():
	SceneManager.fade_to_scene("HostJoinPage")
