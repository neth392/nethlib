extends JSONSerializer


func _init():
	super._init(&"Vector2", DeserializeMode.BOTH)


func _can_serialize(instance) -> bool:
	return instance is Vector2


func _serialize(instance: Vector2) -> Dictionary:
	return {
		"x": instance.x,
		"y": instance.y,
	}


func _deserialize(serialized: Dictionary) -> Vector2:
	return _deserialize_into(Vector2(), serialized)


func _deserialize_into(instance: Vector2, serialized: Dictionary) -> Vector2:
	assert(serialized["x"] is float, "x is not a float")
	assert(serialized["y"] is float, "y is not a float")
	instance.x = serialized["x"]
	instance.y = serialized["y"]
	return instance
