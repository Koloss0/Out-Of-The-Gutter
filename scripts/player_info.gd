class_name PlayerInfo

@export var peer_id := 0
@export var type : EntityType
@export var color := Color.WHITE

enum EntityType {
	PLAYER,
	BOT
}

func _init(peer_id_: int, color_: Color, type_ : EntityType = EntityType.PLAYER):
	peer_id = peer_id_
	color = color_
	type = type_

func to_dictionary() -> Dictionary:
	return {
		"peer_id" : peer_id,
		"type" : type,
		"color" : color
	}

static func from_dictionary(dict : Dictionary) -> PlayerInfo:
	return PlayerInfo.new(dict["peer_id"], dict["color"], dict["type"])
