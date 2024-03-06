extends Control

func _ready():
	MusicPlayer.play_main_menu_music()


func _on_start_button_pressed() -> void:
	SceneManager.fade_to_scene("host_or_join")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
