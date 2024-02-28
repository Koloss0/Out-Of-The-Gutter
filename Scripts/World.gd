extends Node2D

const player_scene = preload("res://scenes/entities/player.tscn")
@onready var spawnpoint: Node2D = $Spawnpoint
@onready var players: Node2D = $Players

func spawn_player(player_info: PlayerInfo):
	var player = player_scene.instantiate()
	player.name = str(player_info.peer_id)
	players.add_child(player)
	player.position = spawnpoint.position
	player.init(player_info)

func remove_player(peer_id: int):
	var player = players.get_node_or_null(str(peer_id))
	if player != null:
		player.queue_free()
