extends NonObjectJSONSerializer


func _get_id() -> Variant:
	return TYPE_AABB


func __serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(instance is AABB, "instance not of type AABB")
	assert(impl != null, "impl is null")
	assert(impl._vector3 != null, "impl._vector3 is null")
	return {
		"p": impl._vector3.__serialize(instance.position, impl),
		"e": impl._vector3.__serialize(instance.end, impl),
	}


func __deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	assert(serialized["p"] is Dictionary, "p is not a Dictionary")
	assert(serialized["e"] is Dictionary, "e is not a Dictionary")
	assert(impl != null, "impl is null")
	assert(impl._vector3 != null, "impl._vector3 is null")
	
	var aabb: AABB = AABB()
	aabb.position = impl._vector3.__deserialize(serialized["p"], impl)
	aabb.end = impl._vector3.__deserialize(serialized["e"], impl)
	return aabb
