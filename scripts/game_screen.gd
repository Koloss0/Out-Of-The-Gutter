class_name GameScreen
extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	Net.peer_connected.connect(on_peer_connected)
	Net.player_registered.connect(on_player_registered)
	Net.player_deregistered.connect(on_player_deregistered)
	Net.peer_disconnected.connect(on_peer_disconnected)
	Net.connected_to_server.connect(on_connected_to_server)
	Net.connection_failed.connect(on_connection_failed)
	Net.server_disconnected.connect(on_server_disconnected)

@warning_ignore("unused_parameter")
func on_peer_connected(peer_id: int):
	pass

@warning_ignore("unused_parameter")
func on_player_registered(peer_id: int):
	pass

@warning_ignore("unused_parameter")
func on_player_deregistered(peer_id: int):
	pass

@warning_ignore("unused_parameter")
func on_peer_disconnected(peer_id: int):
	pass

func on_connected_to_server():
	pass

func on_connection_failed():
	pass

func on_server_disconnected():
	pass
