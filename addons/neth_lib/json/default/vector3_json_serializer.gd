extends JSONSerializer


func _can_serialize(variant) -> bool:
	return variant is Vector3


func _serialize(variant: Vector3) -> Dictionary:
	return {
		"x": variant.x,
		"y": variant.y,
		"z": variant.z
	}


func _deserialize_into(instance: Vector3, json_dictionary: Dictionary):
	assert(json_dictionary["x"] is float, "x is not a float")
	assert(json_dictionary["y"] is float, "y is not a float")
	assert(json_dictionary["z"] is float, "z is not a float")
	instance.x = json_dictionary["x"]
	instance.y = json_dictionary["y"]
	instance.z = json_dictionary["z"]
