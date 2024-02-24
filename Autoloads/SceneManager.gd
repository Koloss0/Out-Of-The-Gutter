extends Node

signal load_progress_updated(progress : float)

const SCENES : Dictionary = {
	"TitlePage" : "res://Scenes/title_page.tscn",
	"HostJoinPage" : "res://Scenes/HostJoin_page.tscn"
}


func fade_to_scene(scene_path : String) -> Error:
	await SceneTransitioner.fade_in()
	
	if SCENES.has(scene_path): scene_path = SCENES[scene_path]
	
	var error = ResourceLoader.load_threaded_request(scene_path)
	if error != OK: return error
		
	var loaded : bool = false
	var progress : Array = []
	while not loaded:
		match ResourceLoader.load_threaded_get_status(scene_path, progress):
			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
				return ERR_CANT_RESOLVE
			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
				load_progress_updated.emit(progress[0])
			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
				return ERR_CANT_RESOLVE
			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
				loaded = true
	
	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(scene_path))
	
	await SceneTransitioner.fade_out()
	
	return OK

