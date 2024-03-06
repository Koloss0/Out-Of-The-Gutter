extends Control

@onready var port : LineEdit = $Port
@onready var mode_option: OptionButton = $ScrollContainer/MarginContainer/Panel/ModeOption
@onready var race_settings: Control = $ScrollContainer/MarginContainer/Panel/RaceSettings
@onready var hot_potato_settings: Control = $ScrollContainer/MarginContainer/Panel/HotPotatoSettings

enum GameMode {
	GUTTER_RACE,
	HOT_POTATO
}

func _ready() -> void:
	refresh_game_modes()
	
	if OS.is_debug_build():
		port.set_text(str(Net.DEFAULT_PORT))


func _on_host_button_pressed() -> void:
	var mode : String
	match mode_option.get_selected_id():
		GameMode.GUTTER_RACE:
			mode = "gutter_race"
		GameMode.HOT_POTATO:
			mode = "hot_potato"
			
	Net.server_port = $Port.text
	Net.is_host = true
	if await SceneManager.fade_to_scene(mode) == OK:
		MusicPlayer.stop_music()



func _on_back_button_pressed() -> void:
	SceneManager.fade_to_scene("host_or_join")


func get_pretty_name(mode : GameMode):
	match mode:
		GameMode.GUTTER_RACE:
			return "Gutter Race"
		GameMode.HOT_POTATO:
			return "Hot Potato"


func refresh_game_modes():
	mode_option.clear()
	
	for mode in GameMode.values():
		mode_option.add_item(get_pretty_name(mode), mode)
	
	_on_mode_option_item_selected(0)


func _on_mode_option_item_selected(index: int) -> void:
	match mode_option.get_item_id(index):
		GameMode.GUTTER_RACE:
			hot_potato_settings.hide()
			race_settings.show()
		GameMode.HOT_POTATO:
			race_settings.hide()
			hot_potato_settings.show()
