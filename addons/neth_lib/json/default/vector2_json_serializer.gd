extends JSONSerializer


func _init():
	super._init(&"Vector2", DeserializeMode.DESERIALIZE)


func _can_serialize(instance) -> bool:
	return instance is Vector2


func _serialize(instance: Variant) -> Variant:
	assert(instance is Vector2, "instance not of type Vector2")
	return {
		"x": instance.x,
		"y": instance.y,
	}


func _deserialize(serialized: Variant) -> Variant:
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	assert(serialized["x"] is float, "x is not a float")
	assert(serialized["y"] is float, "y is not a float")
	return Vector2(serialized["x"], serialized["y"])
