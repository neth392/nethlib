extends JSONSerializer


func _can_serialize(instance) -> bool:
	return instance is Vector2


func _serialize(instance: Vector2) -> Dictionary:
	return {
		"x": instance.x,
		"y": instance.y,
	}


func _deserialize_into(instance: Vector2, serialized: Dictionary):
	assert(serialized["x"] is float, "x is not a float")
	assert(serialized["y"] is float, "y is not a float")
	instance.x = serialized["x"]
	instance.y = serialized["y"]
