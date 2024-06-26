extends JSONSerializer


func _can_serialize(instance) -> bool:
	return instance is Vector3


func _serialize(instance: Vector3) -> Dictionary:
	return {
		"x": instance.x,
		"y": instance.y,
		"z": instance.z
	}


func _deserialize_into(instance: Vector3, serialized: Dictionary):
	assert(serialized["x"] is float, "x is not a float")
	assert(serialized["y"] is float, "y is not a float")
	assert(serialized["z"] is float, "z is not a float")
	instance.x = serialized["x"]
	instance.y = serialized["y"]
	instance.z = serialized["z"]
