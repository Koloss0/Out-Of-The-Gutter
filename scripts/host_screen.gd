extends Control

@onready var port : LineEdit = $Port
@onready var mode_option: OptionButton = $ScrollContainer/MarginContainer/GameModes/ModeOption
@onready var game_modes: VBoxContainer = $ScrollContainer/MarginContainer/GameModes

var host_menus : Array[HostMenu] = []

func _ready() -> void:
	refresh_game_modes()
	
	if OS.is_debug_build():
		port.set_text(str(Net.DEFAULT_PORT))


func _on_host_button_pressed() -> void:
	var menu : HostMenu = mode_option.get_selected_metadata()
	var game_screen_path : String = menu.get_game_screen_path()

	Net.server_port = int(port.text)
	Net.is_host = true
	Net.game_mode = game_screen_path
	
	ResourceHolder.put(menu.get_settings())
	
	if await SceneManager.fade_to_scene(game_screen_path) == OK:
		MusicPlayer.stop_music()


func _on_back_button_pressed() -> void:
	SceneManager.fade_to_scene("host_or_join")

func refresh_game_modes():
	var children = game_modes.get_children()
	
	host_menus.clear()
	host_menus.append_array(children.filter(func(child): return child is HostMenu))
	
	mode_option.clear()
	
	for menu : HostMenu in host_menus:
		register_menu(menu)
	
	_on_mode_option_item_selected(0)

func register_menu(menu : HostMenu) -> void:
	var pretty_name : String = menu.get_pretty_name()
	var index : int = mode_option.item_count
	mode_option.add_item(pretty_name, index)
	mode_option.set_item_metadata(index, menu)

func _on_mode_option_item_selected(index: int) -> void:
	if index >= mode_option.item_count: return
	var selected_menu = mode_option.get_item_metadata(index)
	for mode in host_menus:
		mode.hide()
	selected_menu.show()


func _on_game_modes_child_entered_tree(node: Node) -> void:
	if not is_node_ready(): return
	if node is HostMenu:
		register_menu(node)

func _on_game_modes_child_exiting_tree(node: Node) -> void:
	if not is_node_ready(): return
	if node is HostMenu:
		refresh_game_modes()

func _on_game_modes_child_order_changed() -> void:
	if not is_node_ready(): return
	refresh_game_modes()
