extends Control


# Called when the node enters the scene tree for the first time.s


func _on_quit_pressed():
	get_tree().quit()


func _on_start_pressed():
	SceneManager.fade_to_scene("HostScene")
