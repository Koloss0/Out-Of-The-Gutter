extends Node

func play_main_menu_music():
	stop_music()
	$MainMenu.play()

func play_game_music():
	stop_music()
	$Game.play()
	
func stop_music():
	$MainMenu.stop()
	$Game.stop()
