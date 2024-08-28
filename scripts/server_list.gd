extends Control


const NONE : int = -1
const LIST_ITEM = preload("res://scenes/ui/server_list_item.tscn")

@onready var v_box_container: VBoxContainer = $Panel/ScrollContainer/MarginContainer/VBoxContainer

var selected_item_index : int =  NONE


func _ready() -> void:
	
	for server in ServiceDiscovery.scanned_servers:
		_on_server_discovered(server)
	
	ServiceDiscovery.scanned_server.connect(_on_server_discovered)
	ServiceDiscovery.scan_started.connect(clear)
	
	#for server in [{"Name" : "Server 1", "server_ip" : "255.255.255.255"}, {"Name" : "Server 2", "server_ip" : "255.255.255.255"}, {"Name" : "Server 3", "server_ip" : "255.255.255.255"}, {"Name" : "Server 4", "server_ip" : "255.255.255.255"}]:
		#_on_server_discovered(server)


func get_selected_item() -> ServerListItem:
	return v_box_container.get_child(selected_item_index, true)


func clear() -> void:
	selected_item_index = NONE
	for item in v_box_container.get_children(true):
		if item is ServerListItem:
			item.queue_free()


func _on_list_item_pressed(item : ServerListItem):
	if selected_item_index == NONE:
		if item.selected:
			selected_item_index = item.get_index(true)
	else:
		var selected_item = get_selected_item()
		if item != selected_item:
			selected_item.selected = false
			selected_item_index = item.get_index(true)
		else:
			if not item.selected:
				selected_item_index = NONE



func _on_server_discovered(data : Dictionary):
	var list_item = LIST_ITEM.instantiate()
	list_item.server_ip = data["server_ip"]
	list_item.server_data = data["server_data"]
	list_item.server_name = data["server_data"]["Name"]
	v_box_container.add_child(list_item, false, Node.INTERNAL_MODE_FRONT)
	list_item.pressed.connect(_on_list_item_pressed.bind(list_item))
