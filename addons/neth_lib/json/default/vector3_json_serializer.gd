extends JSONSerializer


func _init():
	super._init(&"Vector3", DeserializeMode.BOTH)


func _can_serialize(instance) -> bool:
	return instance is Vector3


func _serialize(instance: Variant) -> Dictionary:
	assert(instance is Vector3, "instance not of type Vector3")
	var vector: Vector3 = instance as Vector3
	return {
		"x": vector.x,
		"y": vector.y,
		"z": vector.z
	}


func _deserialize(serialized: Variant) -> Vector3:
	return _deserialize_into(Vector3(), serialized)


func _deserialize_into(instance: Variant, serialized: Variant):
	assert(instance is Vector3, "instance not of type Vector3")
	var vector: Vector3 = instance as Vector3
	assert(serialized["x"] is float, "x is not a float")
	assert(serialized["y"] is float, "y is not a float")
	assert(serialized["z"] is float, "z is not a float")
	vector.x = serialized["x"]
	vector.y = serialized["y"]
	vector.z = serialized["z"]
	return vector
