extends HostMenu

@export var randomize_seed : bool = true
@onready var height_option: SpinBox = $HBoxContainer/HeightOption

var map_seed : int

func get_map_height() -> int:
	return height_option.value

func get_random_seed() -> int:
	return randi()

func get_settings() -> RaceSettings:
	if randomize_seed: map_seed = get_random_seed()
	return RaceSettings.new(get_map_height(), map_seed)

func get_pretty_name() -> String:
	return "Gutter Race"

func get_game_screen_path() -> String:
	return "gutter_race"
