extends HostMenu

@onready var width_option: SpinBox = $Width/WidthOption
@onready var height_option: SpinBox = $Height/HeightOption
@onready var time_option: SpinBox = $Time/TimeOption

@export var randomize_seed : bool = true

var map_seed : int

@warning_ignore("narrowing_conversion")
func get_map_size() -> Vector2i:
	return Vector2i(width_option.value, height_option.value)

func get_timeout() -> float:
	return time_option.value

func get_settings() -> HotPotatoSettings:
	if randomize_seed: map_seed = get_random_seed()
	return HotPotatoSettings.new(get_map_size(), get_timeout(), map_seed)

func get_pretty_name() -> String:
	return "Hot Potato"

func get_game_screen_path() -> String:
	return "hot_potato"

func get_random_seed() -> int:
	return randi()
