# manages networking stuff
extends Node

const MAX_PLAYERS = 4

const DEFAULT_PORT : int = 6005
const DEFAULT_ADDRESS : String = "localhost"

var player_data: Dictionary
var num_players: int = 0

var network_peer := ENetMultiplayerPeer.new()

var is_host := false

var server_ip: String
var server_port: int

signal connected_to_server()
signal connection_failed()
signal player_registered(peer_id: int)
signal player_deregistered(peer_id: int)
signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)
signal server_disconnected()

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.connected_to_server.connect(on_connected_to_server)
	multiplayer.connection_failed.connect(on_connection_failed)
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)
	multiplayer.server_disconnected.connect(on_server_disconnected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func start():
	var error = OK
	if is_host:
		error = network_peer.create_server(server_port, MAX_PLAYERS-1)
		if error == OK:
			multiplayer.set_multiplayer_peer(network_peer)
			print("[Net] Hosting Server...")
			AlertDisplayer.alert("Creating Server...")
			
			print("unique ID: %s" % multiplayer.get_unique_id())
			register_player(multiplayer.get_unique_id(), Color.WHITE)
		else:
			print("[Net] Failed to create server: %s" % error);
			AlertDisplayer.alert("Failed to Create Server: %s" % error)
	else:
		error = network_peer.create_client(server_ip, server_port)
		if error == OK:
			multiplayer.set_multiplayer_peer(network_peer)
			print("[Net] Joining...")
			AlertDisplayer.alert("Joining...")
		else:
			print("[Net] Failed to create client: %s" % error);
			AlertDisplayer.alert("Failed to Create Client: %s" % error)

func on_connected_to_server():
	connected_to_server.emit()
	print("Connected")
	print("unique ID: %s" % multiplayer.get_unique_id())
	pass
	
func on_connection_failed():
	connection_failed.emit()
	AlertDisplayer.alert("Connection Failed")
	pass

func on_peer_connected(peer_id: int):
	peer_connected.emit(peer_id)
	if is_multiplayer_authority():
		var color: Color = Color(randf(), randf(), randf())
		register_player(peer_id, color)
		
		for player_info in player_data.values():
			register_player.rpc_id(peer_id, player_info.peer_id, player_info.color)

@rpc("authority", "reliable")
func register_player(peer_id: int, color: Color):
	var player_info: PlayerInfo = PlayerInfo.new(peer_id, color)
	
	player_data[peer_id] = player_info
	num_players += 1
	player_registered.emit(peer_id)
	pass

func on_peer_disconnected(peer_id: int):
	if player_data.has(peer_id):
		peer_disconnected.emit(peer_id)
		player_data.erase(peer_id)
		num_players -= 1
		player_deregistered.emit(peer_id)

func on_server_disconnected():
	server_disconnected.emit()
	AlertDisplayer.alert("Server Disconnected")
	pass

