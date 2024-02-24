extends Node2D

const player_scene = preload("res://Scenes/player.tscn")
@onready var spawnpoint: Node2D = $Spawnpoint
@onready var players: Node2D = $Players

func spawn_player(player_info: PlayerInfo):
	var player = player_scene.instantiate()
	players.add_child(player)
	player.position = spawnpoint.position
	player.init(player_info)
