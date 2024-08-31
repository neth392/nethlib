extends JSONSerializer


var _vector2serializer: JSONSerializer

func _init(vector2serializer: JSONSerializer) -> void:
	_vector2serializer = vector2serializer


func _get_id() -> Variant:
	return TYPE_RECT2


func _serialize(instance: Variant) -> Variant:
	assert(instance is Rect2, "instance not of type Rect2")
	assert(_vector2serializer != null, "_vector2serializer is null")
	return {
		"p": _vector2serializer._serialize(instance.position),
		"e": _vector2serializer._serialize(instance.end),
	}


func _deserialize(owner: Object, property: Dictionary, serialized: Variant) -> Variant:
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	assert(serialized["p"] is Dictionary, "p is not a Dictionary")
	assert(serialized["e"] is Dictionary, "e is not a Dictionary")
	assert(_vector2serializer != null, "_vector2serializer is null")
	
	var rect2: Rect2 = Rect2()
	rect2.position = _vector2serializer._deserialize(serialized["p"])
	rect2.end = _vector2serializer._deserialize(serialized["e"])
	return rect2
