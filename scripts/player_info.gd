extends Resource
class_name PlayerInfo

var peer_id := 0
var color := Color.WHITE

func _init(peer_id_: int, color_: Color):
	peer_id = peer_id_
	color = color_
