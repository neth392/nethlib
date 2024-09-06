extends JSONSerializer


func _get_id() -> Variant:
	return TYPE_ARRAY


func _serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(instance is Array, "instance not of type Array")
	
	var serialized: Array = []
	for element: Variant in instance:
		var serialized_element: Variant = impl.serialize(element)
		serialized.append(serialized_element)
	
	var array: Array = instance as Array
	
	# Return regular array for non-typed arrays
	if !array.is_typed():
		return serialized
	
	# Return wrapped array for typed arrays
	if array.get_typed_builtin() != TYPE_OBJECT:
		array.get_typed_class_name()
	
	return {
		"t": array.get_typed_builtin(),
		"i": config_id,
		"a": serialized
	}


func _deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	var array: Array = []
	# Construct array
	
	_deserialize_into(serialized, array, impl)
	return array


func _deserialize_into(serialized: Variant, instance: Variant, impl: JSONSerializationImpl) -> void:
	assert(instance is Array, "instance not of type Array")
	assert(serialized is Array, "serialized not of type Array")
	for serialized_element: Variant in serialized:
		var deserialized: Variant = JSONSerialization.deserialize(serialized_element)
		instance.append(deserialized)
