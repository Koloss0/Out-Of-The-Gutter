extends Node2D


# Called when the node enters the scene tree for the first time.s


func _on_quit_pressed():
	get_tree().quit()


func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/HostJoin_page.tscn")
