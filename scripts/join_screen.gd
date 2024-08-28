extends Control

@onready var ip = $Control/VBoxContainer/Manual/IP
@onready var port = $Control/VBoxContainer/Manual/Port
@onready var server_list: Control = $Control/VBoxContainer/Discovery/ServerList

@onready var manual_options: Control = $Control/VBoxContainer/Manual
@onready var discovery: Control = $Control/VBoxContainer/Discovery

@onready var advanced_button: Button = $Control/VBoxContainer/SearchOptions/AdvancedButton
@onready var refresh_button: Button = $Control/VBoxContainer/SearchOptions/RefreshButton


var advanced_mode : bool = false : set = set_advanced_mode

func _ready() -> void:
	ServiceDiscovery.scan_finished.connect(_on_discovery_scan_finished)
	
	if OS.is_debug_build():
		ip.set_text(str(Net.DEFAULT_ADDRESS))
		port.set_text(str(Net.DEFAULT_PORT))


func _on_connect_button_pressed() -> void:
	if advanced_mode:
		Net.server_ip = ip.text
		Net.server_port = port.text
	else:
		var selected_item : ServerListItem = server_list.get_selected_item()
		if not selected_item: return
		ServiceDiscovery._on_timer_timeout()
		Net.server_ip = selected_item.server_ip
		Net.server_port = selected_item.server_data["Port"]
	
	Net.is_host = false
	#TODO: switch to correct scene when joining.
	# SceneManager.fade_to_scene("gutter_race")
	# MusicPlayer.stop_music()
	await SceneManager.fade_to_black()
	await SceneManager.switch_to_scene("res://scenes/components/game_mode_synchronizer.tscn")
	if Net.start() != OK:
		await SceneManager.switch_to_scene("host_or_join")
		SceneManager.fade_from_black()


func _on_back_button_pressed() -> void:
	SceneManager.fade_to_scene("host_or_join")


func set_advanced_mode(enabled : bool):
	if advanced_mode == enabled: return
	advanced_mode = enabled
	advanced_button.text = "Discover" if advanced_mode else "Advanced"
	manual_options.visible = advanced_mode
	discovery.visible = not advanced_mode
	refresh_button.visible = not advanced_mode


func _on_advanced_button_pressed() -> void:
	set_advanced_mode(!advanced_mode)


func _on_refresh_button_pressed() -> void:
	refresh_button.disabled = true
	ServiceDiscovery.scan_lan_servers()


func _on_discovery_scan_finished():
	refresh_button.disabled = false
