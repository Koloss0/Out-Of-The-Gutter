extends HostMenu

@onready var width_option: SpinBox = $Width/WidthOption
@onready var height_option: SpinBox = $Height/HeightOption
@onready var time_option: SpinBox = $Time/TimeOption


func get_map_size() -> Vector2i:
	return Vector2i(width_option.value, height_option.value)

func get_timeout() -> int:
	return time_option.value

func get_settings() -> HotPotatoSettings:
	return HotPotatoSettings.new(get_map_size(), get_timeout())

func get_pretty_name() -> String:
	return "Hot Potato"

func get_game_screen_path() -> String:
	return "hot_potato"
