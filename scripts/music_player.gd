extends Node

@onready var game : AudioStreamPlayer = $Game
@onready var main_menu : AudioStreamPlayer = $MainMenu
@onready var lobby : AudioStreamPlayer = $Lobby
@onready var gameplay_intro: AudioStreamPlayer = $GameplayIntro
@onready var gameplay_chorus_1: AudioStreamPlayer = $GameplayChorus1
@onready var gameplay_chorus_2: AudioStreamPlayer = $GameplayChorus2
@onready var gameplay_outro: AudioStreamPlayer = $GameplayOutro
var queued_music_stop : bool = false

func play_main_menu_music():
	stop_music()
	main_menu.play()

func play_Lobby_music():
	stop_music()
	lobby.play()

func stop_music():
	game.stop()
	lobby.stop()
	main_menu.stop()

func play_in_Game_music():
	stop_music()
	gameplay_intro.play()
	await gameplay_intro.finished
	gameplay_chorus_1.play()
	queued_music_stop = false

func stop_in_game_music():
	queued_music_stop = true

func _on_gameplay_chorus_1_finished() -> void:
	if queued_music_stop:
		gameplay_outro.play()
	else:
		gameplay_chorus_2.play()


func _on_gameplay_chorus_2_finished() -> void:
	if queued_music_stop:
		gameplay_outro.play()
	else:
		gameplay_chorus_1.play()


func _on_gameplay_outro_finished() -> void:
	lobby.play()
