class_name PlayerInfo

## An empty dictionary shared by all instances to indicate the cache being unset
## b/c typed variables are not nullable.
static var __EMPTY : Dictionary = {}

var peer_id : int: set = set_peer_id
var entity_type : EntityType: set = set_entity_type
var color : Color: set = set_color

var __dictionary_cache : Dictionary

enum EntityType {
	PLAYER,
	BOT
}

func _init(peer_id_: int, color_: Color = Color.WHITE, type_ : EntityType = EntityType.PLAYER):
	peer_id = peer_id_
	color = color_
	entity_type = type_

func to_dictionary() -> Dictionary:
	if __dictionary_cache == __EMPTY:
		__dictionary_cache = {
			"peer_id" : peer_id,
			"entity_type" : entity_type,
			"color" : color
		}
	return __dictionary_cache

func set_peer_id(new_id : int):
	peer_id = new_id
	__invalidate_cache()

func set_entity_type(type : EntityType):
	entity_type = type
	__invalidate_cache()

func set_color(col : Color):
	color = col
	__invalidate_cache()

func __invalidate_cache():
	__dictionary_cache = __EMPTY

static func from_dictionary(dict : Dictionary) -> PlayerInfo:
	return PlayerInfo.new(dict["peer_id"], dict["color"], dict["entity_type"])
