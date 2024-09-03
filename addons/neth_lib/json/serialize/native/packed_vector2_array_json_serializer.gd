extends NonObjectJSONSerializer

func _get_id() -> Variant:
	return TYPE_PACKED_VECTOR2_ARRAY


func __serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(instance is PackedVector2Array, "instance not of type PackedVector2Array")
	assert(impl != null, "impl is null")
	assert(impl._vector2 != null, "impl._vector2 is null")
	var serialized: Array[Dictionary] = []
	var array: PackedVector2Array = instance as PackedVector2Array
	for vector2: Vector2 in array:
		serialized.append(impl._vector2.__serialize(vector2, impl))
	return serialized


func __deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(serialized is Array, "serialized not of type Array")
	assert(impl != null, "impl is null")
	assert(impl._vector2 != null, "impl._vector2 is null")
	
	var array: PackedVector2Array = PackedVector2Array()
	for serialized_vector2 in serialized:
		array.append(impl._vector2.__deserialize(serialized_vector2, impl))
	
	return array
