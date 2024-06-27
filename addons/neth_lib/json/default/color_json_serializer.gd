extends JSONSerializer


func _init() -> void:
	super._init(&"Color", DeserializeMode.BOTH)


func _can_serialize(instance) -> bool:
	return instance is Color


func _serialize(instance: Color) -> Dictionary:
	return {
		"r": instance.r,
		"g": instance.g,
		"b": instance.b,
		"a": instance.a,
		"r8": instance.r8,
		"g8": instance.g8,
		"b8": instance.b8,
		"a8": instance.a8,
		"h": instance.h,
		"s": instance.s,
		"v": instance.v,
	}


func _deserialize(serialized: Dictionary) -> Color:
	return _deserialize_into(Color(), serialized)


func _deserialize_into(instance: Color, serialized: Dictionary) -> Color:
	assert(serialized["r"] is float, "r is not a float")
	assert(serialized["g"] is float, "b is not a float")
	assert(serialized["b"] is float, "b is not a float")
	assert(serialized["a"] is float, "a is not a float")
	assert(serialized["r8"] is int, "r8 is not a int")
	assert(serialized["g8"] is int, "g8 is not a int")
	assert(serialized["b8"] is int, "b8 is not a int")
	assert(serialized["a8"] is int, "a8 is not a int")
	assert(serialized["h"] is float, "h is not a float")
	assert(serialized["s"] is float, "s is not a float")
	assert(serialized["v"] is float, "v is not a float")
	instance.r = serialized["r"]
	instance.g = serialized["g"]
	instance.b = serialized["b"]
	instance.a = serialized["a"]
	instance.r8 = serialized["r8"]
	instance.g8 = serialized["g8"]
	instance.b8 = serialized["b8"]
	instance.a8 = serialized["a8"]
	instance.h = serialized["h"]
	instance.s = serialized["s"]
	instance.v = serialized["v"]
	return instance
