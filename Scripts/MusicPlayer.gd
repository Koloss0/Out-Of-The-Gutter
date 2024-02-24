extends Node

func play_main_menu_music():
	stop_music()
	$MainMenuMusicSJ.play()

func play_Lobby_music():
	stop_music()
	$LobbyMusicSJ.play()

func play_in_Game_music():
	stop_music()
	$ActualGameMusicSJ.play()
	
func stop_music():
	$ActualGameMusicSJ.stop()
	$LobbyMusicSJ.stop()
	$MainMenuMusicSJ.stop()
