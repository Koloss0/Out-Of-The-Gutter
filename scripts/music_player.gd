extends Node

@onready var game : AudioStreamPlayer = $Game
@onready var main_menu : AudioStreamPlayer = $MainMenu
@onready var lobby : AudioStreamPlayer = $Lobby

func play_main_menu_music():
	stop_music()
	main_menu.play()

func play_Lobby_music():
	stop_music()
	lobby.play()

func play_in_Game_music():
	stop_music()
	game.play()

func stop_music():
	game.stop()
	lobby.stop()
	main_menu.stop()
