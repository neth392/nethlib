class_name ObjectJSONSerializer extends JSONSerializer

## Returns an [Array] of [StringName]s for ALL of the [param object]'s properties.
static func for_all_properties(object: Object) -> Array[StringName]:
	var prop_names: Array[StringName] = []
	for property: Dictionary in object.get_property_list():
		prop_names.append(property.name as StringName)
	return prop_names

var _property_names: Array[StringName]
var _remaps: Dictionary

func _init(_id: StringName, _deserialize_mode: DeserializeMode):
	super._init(_id, _deserialize_mode)
	_property_names = _get_property_names()
	_remaps = _get_deserialization_remaps()
	assert(!_property_names.is_empty(), "_property_names is empty")


func _serialize(instance: Object) -> Dictionary:
	assert(instance != null, "variant is null")
	var serialized: Dictionary = {}
	for property_name: StringName in _property_names:
		assert(property_name in instance, "property (%s) not found in instance (%s)" \
		% [property_name, instance])
		
		var value: Variant = instance.get(property_name)
		
		# Check if the value is null
		if value == null:
			serialized[property_name] = null
			continue
		
		var serialized_value: Variant = JSONSerialization.serialize(value)
		serialized[property_name] = serialized_value
	
	return serialized


func _deserialize_into(instance: Object, serialized: Dictionary):
	assert(instance != null, "instance is null")
	assert(serialized != null, "serialized is null")
	
	# Sort object properties into a [Dictionary] for quick access
	var object_properties: Dictionary = {}
	for property: Dictionary in instance.get_property_list():
		object_properties[property.name] = property
	
	# Iterate expected properties
	for property_name: StringName in _property_names:
		assert(property_name in instance, "property (%s) not found in instance (%s)" \
		% [property_name, instance])
		
		var serialized_name: StringName = property_name
		# Utilize remaps to check for changed property names
		while !serialized.has(serialized_name):
			if !_remaps.has(serialized_name):
				assert(false, "property_name (%s) or serialized_name (%s) not found " +\
				"in _remaps (%s)" % [serialized_name, serialized_name, _remaps])
				return
			serialized_name = _remaps[serialized_name]
		
		# Retrieve the wrapped value
		var wrapped_value: Variant = serialized.get(serialized_name)
		assert(wrapped_value != null, "wrapped_value is null for serialized_name (%s)" % serialized_name)
		assert(wrapped_value is Dictionary, "wrapped_value (%s) is not of type Dictionary" + \
		" for serialized_name (%s)" % [wrapped_value, serialized_name])
		
		# Unwrap the value
		var unwrapped_value: Variant = JSONSerialization.unwrap_value(wrapped_value)
		
		# If the unwrapped_value value is null, directly set property to null
		if unwrapped_value == null:
			instance.set(property_name, null)
			continue
		
		assert(object_properties.has(property_name), "property_name (%s) not found " + \
		"in object (%s)'s property list" % [property_name, instance])
		var property: Dictionary = object_properties[property_name]
		
		var serializer: JSONSerializer = JSONSerialization.get_wrapped_serializer(wrapped_value)
		var existing_property: Variant = instance.get(property_name)
		
		# In debug, ensure wrapped's serializer matches serializer of the existing property value
		if OS.is_debug_build() && existing_property != null:
			var prop_serializer = JSONSerialization.get_serializer(existing_property)
			assert(prop_serializer == serializer, "existing_property (%s)'s serializer (%s) " + \
			"!= unwrapped value (%s)'s serializer (%s)" % [existing_property, prop_serializer, 
			wrapped_value, serializer])
		
		# Handle natives by directly setting the property
		if serializer is NativeJSONSerializer:
			instance.set(property_name, serializer._deserialize(unwrapped_value))
			continue
		
		# Property exists, ensure the serialiazation type matches & check if it can be deserialized into
		if existing_property != null && serializer.has_deserialize_into_func():
			serializer._deserialize_into(existing_property, unwrapped_value)
			continue
		
		assert(serializer.has_deserialize_func(), "serializer (%s) for property_name (%s) doesn't" + \
		" support _deserialize() & no value is set to deserialize into" % [serializer, property_name])
		var deserialized: Variant = serializer._deserialize(unwrapped_value)
		instance.set(property_name, deserialized)
	
	return instance


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
