# manages networking stuff
extends Node

const MAX_PLAYERS = 4

var player_data: Array[PlayerInfo]

var network_peer := ENetMultiplayerPeer.new()

var is_host := false

var server_ip: int
var server_port: int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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
	#else:
		#error = network_peer.create_client()
		
