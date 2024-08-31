extends JSONSerializer


func _get_id() -> Variant:
	return TYPE_VECTOR2I


func _serialize(instance: Variant) -> Variant:
	assert(instance is Vector2i, "instance not of type Vector2i")
	return {
		"x": instance.x,
		"y": instance.y,
	}


func _deserialize(owner: Object, property: Dictionary, serialized: Variant) -> Variant:
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	assert(serialized["x"] is float, "x is not a float")
	assert(serialized["y"] is float, "y is not a float")
	return Vector2i(int(serialized["x"]), int(serialized["y"]))
