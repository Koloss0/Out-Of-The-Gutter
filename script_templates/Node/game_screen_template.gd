# meta-name: GameScreen Template
# meta-description: Predefined functions for network handling
# meta-default: false
# meta-space-indent: 4

extends GameScreen

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready() #NOTE: Do not delete this line. This connects the signals. 

# Called when a client connects to the server.
func on_peer_connected(peer_id: int):
	pass

# Called when a client successfully joins the session.
func on_player_registered(peer_id: int):
	pass

# Called when a client leaves the session.
func on_player_deregistered(peer_id: int):
	pass

# Called when a client disconnects from the server.
func on_peer_disconnected(peer_id: int):
	pass

# Called when the local machine connects to a server.
func on_connected_to_server():
	pass

# Called when the local machine fails to connect to a server.
func on_connection_failed():
	pass

# Called when the local machine disconnects from a server.
func on_server_disconnected():
	pass
