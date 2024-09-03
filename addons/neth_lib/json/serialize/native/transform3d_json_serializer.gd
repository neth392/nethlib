extends NonObjectJSONSerializer


func _get_id() -> Variant:
	return TYPE_TRANSFORM3D


func __serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(instance is Transform3D, "instance not of type Transform3D")
	assert(impl != null, "impl is null")
	assert(impl._vector3 != null, "impl._vector3 is null")
	assert(impl._basis != null, "impl._basis is null")
	
	return {
		"b": impl._basis.__serialize(instance.basis, impl),
		"o": impl._vector3.__serialize(instance.origin, impl),
	}


func __deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	assert(serialized["b"] is Dictionary, "b is not a Dictionary")
	assert(serialized["o"] is Dictionary, "o is not a Dictionary")
	assert(impl != null, "impl is null")
	assert(impl._vector3 != null, "impl._vector3 is null")
	assert(impl._basis != null, "impl._basis is null")
	
	return Transform3D(
		impl._basis.__deserialize(serialized["b"], impl), 
		impl._vector3.__deserialize(serialized["o"], impl), 
	)
