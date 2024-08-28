extends Node

@onready var music_player: AudioStreamPlayer = $InteractiveMusic
var interactive_stream : AudioStreamInteractive

enum Clip {
	INTRO,
	CHORUS_1,
	CHORUS_2,
	OUTRO,
	LOBBY,
	START_SCREEN
}

func _ready() -> void:
	interactive_stream = music_player.stream

func play_main_menu_music():
	switch_to_clip(Clip.START_SCREEN)

func play_Lobby_music():
	switch_to_clip(Clip.LOBBY)

func stop_music():
	music_player.stop()

func play_gameplay_music():
	switch_to_clip(Clip.CHORUS_1)

func switch_to_clip(clip : Clip):
	if not music_player.playing: music_player.play()
	var interactive_playback : AudioStreamPlaybackInteractive = music_player.get_stream_playback()
	interactive_playback.switch_to_clip(clip)
