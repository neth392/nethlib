extends JSONSerializer


func _can_serialize(variant) -> bool:
	return variant is Vector2


func _serialize(variant: Vector2) -> Dictionary:
	return {
		"x": variant.x,
		"y": variant.y,
	}


func _deserialize_into(instance: Vector2, json_dictionary: Dictionary):
	assert(json_dictionary["x"] is float, "x is not a float")
	assert(json_dictionary["y"] is float, "y is not a float")
	instance.x = json_dictionary["x"]
	instance.y = json_dictionary["y"]
