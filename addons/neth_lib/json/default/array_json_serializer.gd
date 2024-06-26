extends JSONSerializer


func _can_serialize(instance) -> bool:
	return instance is Array


func _can_deserialize_into(instance, serialized) -> bool:
	return instance is Array


func _serialize(instance: Array) -> Variant:
	assert(instance.is_typed(), "Array (%s) is not explicitly typed, Array's must " + \
	"be explicitly typed for deserialization purposes" % instance)
	
	var type: Variant.Type = instance.get_typed_builtin()
	var native: bool = NativeJSONSerializer.is_type_native(type)
	var serializer: JSONSerializer
	if !native:
		if type == TYPE_DICTIONARY:
			
		pass
	
	var serialized: Array = []
	
	for element: Variant in instance:
		# Null elements
		if element == null:
			serialized.append(null)
			continue
		
		# Native elements
		if native:
			serialized.append(element)
			continue
		
		
		
		
	return []


func _deserialize_into(instance, serialized) -> void:
	pass
