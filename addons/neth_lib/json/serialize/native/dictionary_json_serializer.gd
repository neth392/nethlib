extends JSONSerializer


func _get_id() -> Variant:
	return TYPE_DICTIONARY


func _serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(instance is Dictionary, "instance not of type Dictionary")
	
	if instance.is_empty():
		return {}
	
	var serialized: Dictionary = {}
	
	for key: Variant in instance:
		var serialized_key: Variant = null
		if key != null:
			# Key needs to be stringified as JSON key's cant be dictionaries themselves
			serialized_key = JSONSerialization.stringify(key)
		
		var value: Variant = instance[key]
		var serialized_value: Dictionary = value if value == null else JSONSerialization.serialize(value)
		
		serialized[serialized_key] = serialized_value
	
	return serialized


func _deserialize(serialized: Variant, impl: JSONSerializationImpl, json_key: StringName,
owner: Object, property: Dictionary) -> Variant:
	var dictionary: Variant = {}
	_deserialize_into(owner, property, dictionary, serialized)
	return dictionary


func _deserialize_into(serialized: Variant, instance: Variant, impl: JSONSerializationImpl, json_key: StringName, owner: Object, property: Dictionary) -> void:
	assert(instance is Dictionary, "instance not of type Dictionary")
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	
	instance.clear()
	for stringified_key: Variant in serialized:
		
		var key: Variant = null
		if stringified_key != null:
			assert(stringified_key is String, ("stringified_key (%s) not of type String " + \
			"for serialized Dictionary (%s)") % [stringified_key, serialized])
			key = JSONSerialization.parse(stringified_key)
		
		var wrapped_value: Variant = serialized[stringified_key]
		var value: Variant = wrapped_value
		if wrapped_value != null:
			assert(wrapped_value is Dictionary, ("wrapped_value (%s) not of type Dictionary " + \
			"for Dictionary (%s)") % [wrapped_value, serialized])
			value = JSONSerialization.deserialize(wrapped_value)
		
		instance[key] = value
