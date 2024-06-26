class_name ObjectJSONSerializer extends JSONSerializer

## Returns an [Array] of [StringName]s for ALL of the [param object]'s properties.
static func for_all_properties(object: Object) -> Array[StringName]:
	var prop_names: Array[StringName] = []
	for property: Dictionary in object.get_property_list():
		prop_names.append(property.name as StringName)
	return prop_names

var _property_names: Array[StringName]
var _remaps: Dictionary

func _init():
	_property_names = _get_property_names()
	_remaps = _get_deserialization_remaps()
	assert(!_property_names.is_empty(), "_property_names is empty")


func _serialize(instance: Object) -> Dictionary:
	assert(instance != null, "variant is null")
	var serialized: Dictionary = {}
	for property_name: StringName in _property_names:
		assert(property_name in instance, "property (%s) not found in object (%s)" \
		% [property_name, instance])
		
		var value: Variant = instance.get(property_name)
		
		# Check if the value is null
		if value == null:
			serialized[property_name] = null
			continue
		
		var serialized_value: Variant = JSONSerialization.serialize(value)
		serialized[property_name] = serialized_value
	
	return serialized


func _deserialize_into(instance: Object, serialized: Dictionary) -> void:
	assert(instance != null, "instance is null")
	assert(serialized != null, "serialized is null")
	
	# Sort object properties into a [Dictionary] for quick access
	var object_properties: Dictionary = {}
	for property: Dictionary in instance.get_property_list():
		object_properties[property.name] = property
	
	# Iterate expected properties
	for property_name: StringName in _property_names:
		
		var serialized_name: StringName = property_name
		# Utilize remaps to check for changed property names
		while !serialized.has(serialized_name):
			if !_remaps.has(serialized_name):
				push_error("property_name (%s) or serialized_name (%s) not found " +\
				"in _remaps (%s)" % [serialized_name, serialized_name, _remaps])
				return
			serialized_name = _remaps[serialized_name]
		
		var serialized_value: Variant = serialized.get(serialized_name)
		# If the serialized value is null, directly set it as null
		if serialized_value == null:
			instance.set(property_name, null)
			continue
		
		assert(object_properties.has(property_name), "property_name (%s) not found " + \
		"in object (%s)'s property list" % [property_name, instance])
		var property: Dictionary = object_properties[property_name]
		
		# Check if the type is native, if it is directly assign the property
		if NativeJSONSerializer.is_native(property.type):
			# Edge case where ints are serialized to floats by [method JSON.stringify]
			if property.type == TYPE_INT && typeof(serialized_value) == TYPE_FLOAT:
				serialized_value = serialized_value as int
			instance.set(property_name, serialized_value)
			continue
		
		var existing_object: Variant = instance.get(property_name)
		assert(existing_object != null, "property (%s) is null on instance (%s), " + \
		"must not be null to deserialize into the property" % [property_name, instance])
		
		JSONSerialization.deserialize_into(existing_object, serialized_value)


## Must be overridden to return an [Array] of [StringName]s representing
## the names of properties that are to be serialized & deserialized.[br]
## For performance reasons, it is important the [StringName]s are explicitly
## defined as it speeds up the many [method Object.get] calls this serializer uses.
func _get_property_names() -> Array[StringName]:
	return []


## Can be overridden to return a [Dictionary] in the format of 
## {&"new_prop_stringname":&"old_prop_stringname"}.[br]
## Remaps are essential when a property name in a script changes, as it'll
## make [method _deserialize_into] aware that the new property name may not exist
## and in that case it'll look for the remap value.
func _get_deserialization_remaps() -> Dictionary:
	return {}
