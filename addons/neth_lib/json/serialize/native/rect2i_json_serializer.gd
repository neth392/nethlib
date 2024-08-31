extends JSONSerializer


var _vector2iserializer: JSONSerializer

func _init(vector2iserializer: JSONSerializer) -> void:
	_vector2iserializer = vector2iserializer


func _get_id() -> Variant:
	return TYPE_RECT2I


func _serialize(instance: Variant) -> Variant:
	assert(instance is Rect2i, "instance not of type Rect2i")
	assert(_vector2iserializer != null, "_vector2iserializer is null")
	return {
		"p": _vector2iserializer._serialize(instance.position),
		"e": _vector2iserializer._serialize(instance.end),
	}


func _deserialize(owner: Object, property: Dictionary, serialized: Variant) -> Variant:
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	assert(serialized["p"] is Dictionary, "p is not a Dictionary")
	assert(serialized["e"] is Dictionary, "e is not a Dictionary")
	assert(_vector2iserializer != null, "_vector2iserializer is null")
	
	var rect2i: Rect2i = Rect2i()
	rect2i.position = _vector2iserializer._deserialize(owner, property, serialized["p"])
	rect2i.end = _vector2iserializer._deserialize(owner, property, serialized["e"])
	return rect2i
