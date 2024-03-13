extends Area2D

var scoreboard: Array = []
var time: float = 0.0
var started: bool = false
var count: int = 0

signal game_finished(scoreboard : Array)

func _on_body_entered(body):
	if is_multiplayer_authority() and body.is_in_group("players"):
		scoreboard.append({peer_id = body.player_info.peer_id, time = time})
		count += 1
		game_finished.emit(scoreboard)


func _process(delta):
	if started:
		time += delta

func start_timer():
	time = 0.0
	started = true
