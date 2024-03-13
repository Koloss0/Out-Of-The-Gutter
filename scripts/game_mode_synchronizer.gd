extends MultiplayerSpawner

func _init() -> void:
	set_spawn_function(create_game_mode_instance)

func _ready():
	if Net.is_host:
		SceneManager.load_scene(Net.game_mode)
		get_tree().current_scene.add_child(SceneManager.get_loaded_scene(Net.game_mode).instantiate())
		SceneManager.fade_from_black()


func create_game_mode_instance(path : String) -> Node:
	var error = SceneManager.load_scene(path)
	var instance : Node
	if error == OK:
		var loaded_scene := SceneManager.get_loaded_scene(path)
		instance = loaded_scene.instantiate()
	else:
		push_error("Failed to load game mode: %s" % path)
	return instance



func _on_spawned(_node:Node) -> void:
	SceneManager.fade_from_black()
