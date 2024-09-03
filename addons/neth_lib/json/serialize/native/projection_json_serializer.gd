extends NonObjectJSONSerializer

func _get_id() -> Variant:
	return TYPE_PROJECTION


func __serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(instance is Projection, "instance not of type Projection")
	assert(impl != null, "impl is null")
	assert(impl._vector4 != null, "impl._vector4 is null")
	return {
		"x": impl._vector4.__serialize(instance.x, impl),
		"y": impl._vector4.__serialize(instance.y, impl),
		"z": impl._vector4.__serialize(instance.z, impl),
		"w": impl._vector4.__serialize(instance.w, impl),
	}


func __deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	assert(serialized["x"] is Dictionary, "x is not a Dictionary")
	assert(serialized["y"] is Dictionary, "y is not a Dictionary")
	assert(serialized["z"] is Dictionary, "z is not a Dictionary")
	assert(serialized["w"] is Dictionary, "w is not a Dictionary")
	assert(impl != null, "impl is null")
	assert(impl._vector4 != null, "impl._vector4 is null")
	
	return Projection(
		impl._vector4.__deserialize(serialized["x"], impl),
		impl._vector4.__deserialize(serialized["y"], impl),
		impl._vector4.__deserialize(serialized["z"], impl),
		impl._vector4.__deserialize(serialized["w"], impl),
	)
