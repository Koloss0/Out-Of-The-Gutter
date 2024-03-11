extends Area2D

signal player_tagged(other : Node2D)

@onready var cooldown_timer: Timer = $CooldownTimer

var tagged : bool = false
var cooldown_active : bool = false

func set_tagged(state : bool):
	if state == tagged: return
	tagged = state
	if tagged:
		start_cooldown()

func start_cooldown():
	cooldown_active = true
	cooldown_timer.start()

func _on_cooldown_timer_timeout() -> void:
	var overlapping := get_overlapping_bodies()
	if overlapping.size() > 0:
		overlapping.sort_custom(sort_closest)
		tag_player(overlapping[0])
	cooldown_active = false

func sort_closest(a : Node2D, b : Node2D) -> bool:
	return (a.position.distance_to(position) < b.position.distance_to(position))

func _on_body_entered(body: Node2D) -> void:
	if body is SlimeEntity:
		if tagged and not cooldown_active:
			tag_player(body)

func tag_player(other : Node2D):
	tagged = false
	player_tagged.emit(other)
