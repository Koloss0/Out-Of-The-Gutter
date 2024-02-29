extends Node

func play_main_menu_music():
	stop_music()
	$MainMenu.play()

func play_Lobby_music():
	stop_music()
	$Lobby.play()

func play_in_Game_music():
	stop_music()
	$Game.play()
	
func stop_music():
	$Game.stop()
	$Lobby.stop()
	$MainMenu.stop()
