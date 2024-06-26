extends JSONSerializer

func _can_serialize(variant) -> bool:
	return variant is Color


func _serialize(variant: Color) -> Dictionary:
	
	return {
		"r": variant.r,
		"g": variant.g,
		"b": variant.b,
		"a": variant.a,
		"r8": variant.r8,
		"g8": variant.g8,
		"b8": variant.b8,
		"a8": variant.a8,
		"h": variant.h,
		"s": variant.s,
		"v": variant.v,
	}


func _deserialize_into(instance: Color, json_dictionary: Dictionary):
	assert(json_dictionary["r"] is float, "r is not a float")
	assert(json_dictionary["g"] is float, "b is not a float")
	assert(json_dictionary["b"] is float, "b is not a float")
	assert(json_dictionary["a"] is float, "a is not a float")
	assert(json_dictionary["r8"] is int, "r8 is not a int")
	assert(json_dictionary["g8"] is int, "g8 is not a int")
	assert(json_dictionary["b8"] is int, "b8 is not a int")
	assert(json_dictionary["a8"] is int, "a8 is not a int")
	assert(json_dictionary["h"] is float, "h is not a float")
	assert(json_dictionary["s"] is float, "s is not a float")
	assert(json_dictionary["v"] is float, "v is not a float")
	instance.r = json_dictionary["r"]
	instance.g = json_dictionary["g"]
	instance.b = json_dictionary["b"]
	instance.a = json_dictionary["a"]
	instance.r8 = json_dictionary["r8"]
	instance.g8 = json_dictionary["g8"]
	instance.b8 = json_dictionary["b8"]
	instance.a8 = json_dictionary["a8"]
	instance.h = json_dictionary["h"]
	instance.s = json_dictionary["s"]
	instance.v = json_dictionary["v"]
