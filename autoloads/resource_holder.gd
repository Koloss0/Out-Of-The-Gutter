extends Node

var _resource : Resource:
	set = put,
	get = take

func put(res : Resource) -> void:
	_resource = res

func take() -> Resource:
	var res := _resource
	_resource = null
	return res
