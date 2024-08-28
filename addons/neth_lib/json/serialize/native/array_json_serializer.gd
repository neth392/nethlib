extends JSONSerializer


func _get_id() -> Variant:
	return TYPE_ARRAY


func _serialize(instance: Variant) -> Variant:
	assert(instance is Array, "instance not of type Array")
	
	if instance.is_empty():
		return []
	
	var serialized: Array = []
	
	for element: Variant in instance:
		if element == null:
			serialized.append(null)
			continue
		
		var serialized_element: Variant = JSONSerialization.serialize(element)
		serialized.append(serialized_element)
	
	return serialized


func _deserialize(serialized: Variant) -> Variant:
	var array: Array = []
	_deserialize_into(array, serialized)
	return array


func _deserialize_into(instance: Variant, serialized: Variant) -> void:
	assert(instance is Array, "instance not of type Array")
	assert(serialized is Array, "serialized not of type Array")
	
	instance.clear()
	for wrapped_element: Variant in serialized:
		if wrapped_element == null:
			instance.append(wrapped_element)
			continue
		
		assert(wrapped_element is Dictionary, ("wrapped_element (%s) of serialized array (%s) " + \
		"not of type Dictionary") % [wrapped_element, serialized])
		
		var deserialized: Variant = JSONSerialization.deserialize(wrapped_element)

		# In debug, check if the array is typed and if it is make sure the deserialized type matches
		if OS.is_debug_build() && instance.is_typed():
			assert(typeof(deserialized) == instance.get_typed_builtin(),
			"type (%s) of deserialized (%s) not expected type (%s) of array (%s)" \
			% [typeof(deserialized), deserialized, instance.get_typed_builtin(), instance])
			var script: Script = instance.get_typed_script() as Script
			assert(script == null || script.instance_has(deserialized),
			"script (%s) of array (%s) does not support instance (%s)" \
			% [script.resource_name, instance, deserialized])
		
		instance.append(deserialized)