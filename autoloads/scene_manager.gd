extends Node

signal load_progress_updated(progress : float)

@onready var scene_transitioner : SceneTransitioner = $SceneTransitioner

const SCENES : Dictionary = {
	"start_screen" : "res://scenes/screens/start_screen.tscn",
	"host_or_join" : "res://scenes/screens/host_or_join.tscn",
	"host_screen" : "res://scenes/screens/host_screen.tscn",
	"server_settings" : "res://scenes/screens/server_settings.tscn",
	"join_screen" : "res://scenes/screens/join_screen.tscn",
	"gutter_race" : "res://scenes/screens/game_modes/gutter_race.tscn",
	"hot_potato" : "res://scenes/screens/game_modes/hot_potato.tscn",
	"game_mode_synch" : "res://scenes/components/game_mode_synchronizer.tscn"
}


func fade_to_scene(scene_path : String) -> Error:
	await fade_to_black()
	var error : Error = await switch_to_scene(scene_path)
	await fade_from_black()
	return error

func switch_to_scene(scene_path : String) -> Error:
	var status = load_scene(scene_path)
		
	if status == OK:
		get_tree().change_scene_to_packed(get_loaded_scene(scene_path))
	else:
		await AlertDisplayer.alert("ERROR: Unable to load requested scene.\n%s (%0d)" % [error_string(status), status])
	
	return status


func load_scene(scene_path : String) -> Error:
	scene_path = resolve_path(scene_path)
	
	var status : Error
	if ResourceLoader.exists(scene_path):
		status = ResourceLoader.load_threaded_request(scene_path)
	else:
		status = ERR_DOES_NOT_EXIST
	
	
	var progress : Array = []
	while status == OK:
		match ResourceLoader.load_threaded_get_status(scene_path, progress):
			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
				status = ERR_CANT_RESOLVE
			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
				load_progress_updated.emit(progress[0])
			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
				status = ERR_CANT_RESOLVE
			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
				break
	
	return status

func get_loaded_scene(scene_name : String) -> PackedScene:
	return ResourceLoader.load_threaded_get(resolve_path(scene_name))

func resolve_path(scene_name : String) -> String:
	return SCENES[scene_name] if SCENES.has(scene_name) else scene_name 

func fade_to_black() -> Signal:
	return scene_transitioner.fade_in()

func fade_from_black() -> Signal:
	return scene_transitioner.fade_out()
