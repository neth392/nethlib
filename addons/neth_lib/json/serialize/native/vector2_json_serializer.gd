extends JSONSerializer


func _get_id() -> Variant:
	return TYPE_VECTOR2


func _serialize(instance: Variant) -> Variant:
	assert(instance is Vector2, "instance not of type Vector2")
	return {
		"x": instance.x,
		"y": instance.y,
	}


func _deserialize(property: Dictionary, serialized: Variant) -> Variant:
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	assert(serialized["x"] is float, "x is not a float")
	assert(serialized["y"] is float, "y is not a float")
	return Vector2(serialized["x"], serialized["y"])
