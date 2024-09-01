extends JSONSerializer


var _vector2serializer: JSONSerializer

func _init(vector2serializer: JSONSerializer) -> void:
	_vector2serializer = vector2serializer


func _get_id() -> Variant:
	return TYPE_TRANSFORM2D


func _serialize(instance: Variant) -> Variant:
	assert(instance is Transform2D, "instance not of type Transform2D")
	assert(_vector2serializer != null, "_vector2serializer is null")
	return {
		"o": _vector2serializer._serialize(instance.origin),
		"x": _vector2serializer._serialize(instance.x),
		"y": _vector2serializer._serialize(instance.y),
	}


func _deserialize(owner: Object, property: Dictionary, serialized: Variant) -> Variant:
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	assert(serialized["o"] is Dictionary, "o is not a Dictionary")
	assert(serialized["x"] is Dictionary, "x is not a Dictionary")
	assert(serialized["y"] is Dictionary, "y is not a Dictionary")
	assert(_vector2serializer != null, "_vector2serializer is null")
	
	var transform2d: Transform2D = Transform2D()
	transform2d.origin = _vector2serializer._deserialize(owner, property, serialized["o"])
	transform2d.x = _vector2serializer._deserialize(owner, property, serialized["x"])
	transform2d.y = _vector2serializer._deserialize(owner, property, serialized["y"])
	return transform2d
