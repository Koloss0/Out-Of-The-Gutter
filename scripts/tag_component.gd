class_name TagComponent
extends Area2D

signal tag_forwarded(other : Node2D)
signal tag_received()

@onready var cooldown_timer: Timer = $CooldownTimer

var tagged : bool = false
var cooldown_active : bool = false


## Returns true iff the tagged state was changed
func set_tagged(state : bool = true) -> bool:
	if state == tagged: return false
	tagged = state
	if tagged:
		start_cooldown()
		tag_received.emit()
	return true

func start_cooldown():
	cooldown_active = true
	cooldown_timer.start()

func _on_cooldown_timer_timeout() -> void:
	var overlapping := get_overlapping_bodies()
	if overlapping.size() > 0:
		overlapping.filter(func(body): return body is TagComponent)
		overlapping.sort_custom(sort_closest)

		## Sequentially attempt to tag overlapping TagComponents
		## (May fail if the other is already tagged)
		for other in overlapping:
			if _try_tag(other): break

	cooldown_active = false

func sort_closest(a : Node2D, b : Node2D) -> bool:
	return (a.position.distance_to(position) < b.position.distance_to(position))


## Returns true iff the tag was forwarded
func _try_tag(other : TagComponent) -> bool:
	if not other.set_tagged(): return false
	
	tagged = false
	tag_forwarded.emit(other)
	return true


func _on_area_entered(area:Area2D) -> void:
	if area is TagComponent:
		if tagged and not cooldown_active:
			_try_tag(area)
