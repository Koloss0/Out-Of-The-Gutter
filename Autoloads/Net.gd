# manages networking stuff
extends Node

const MAX_PLAYERS = 4

var player_data: Array[PlayerInfo]

var network_peer := ENetMultiplayerPeer.new()

var is_host := false

var server_ip: String
var server_port: int

signal connected_to_server()
signal connection_failed()
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
			multiplayer.set_network_peer(network_peer)
			print("[Net] Hosting Server...")
		else:
			print("[Net] Failed to create server: %s" % error);
	else:
		error = network_peer.create_client(server_ip, server_port)
		if error == OK:
			multiplayer.set_network_peer(network_peer)
			print("[Net] Joining...")
		else:
			print("[Net] Failed to create client: %s" % error);

func on_connected_to_server():
	connected_to_server.emit()
	pass
	
func on_connection_failed():
	connection_failed.emit()
	pass

func on_peer_connected(peer_id: int):
	peer_connected.emit(peer_id)
	pass

func on_peer_disconnected(peer_id: int):
	peer_disconnected.emit(peer_id)
	pass

func on_server_disconnected():
	server_disconnected.emit()
	pass
