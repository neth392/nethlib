class_name OLDObjectJSONSerializer extends JSONSerializer


var _properties: Dictionary = {}
var _remaps: Dictionary = {}


func _serialize(instance: Variant) -> Variant:
	assert(instance == null || instance is Object, "instance not null or of type Object")
	
	if instance == null:
		return null
	
	var object: Object = instance as Object
	var serialized: Dictionary = {}
	for property_name: StringName in _properties:
		assert(property_name in object, "property (%s) not found in object (%s)" \
		% [property_name, object])
		
		var value: Variant = object.get(property_name)
		
		# Check if the value is null
		if value == null:
			serialized[property_name] = null
			continue
		
		var serialized_value: Variant = JSONSerialization.serialize(value)
		serialized[property_name] = serialized_value
	
	return serialized


func _deserialize(serialized: Variant) -> Variant:
	assert(serialized == null || serialized is Dictionary, "instance not null or of type Dictionary")
	if serialized == null:
		return null
	var instance: Object = _create_instance()
	assert(instance != null, "_create_instance() returned null")
	_deserialize_into(instance, serialized)
	return instance


func _deserialize_into(instance: Variant, serialized: Variant) -> void:
	assert(instance != null, "instance is null; can't deserialize into a null instance")
	assert(instance is Object, "instance not of type Object")
	assert(serialized == null || serialized is Dictionary, "serialized not null or of type Dictionary")
	
	if serialized == null:
		return
	
	# Sort object properties into a [Dictionary] for quick access
	var object_properties: Dictionary = {}
	for property: Dictionary in instance.get_property_list():
		object_properties[property.name] = property
	
	# Iterate expected properties
	for property_name: StringName in _properties:
		assert(property_name in instance, "property (%s) not found in object (%s)" \
		% [property_name, instance])
		
		var serialized_name: StringName = property_name
		var missing: bool = false
		
		# Utilize remaps to check for changed property names
		while !serialized.has(serialized_name):
			if !_remaps.has(serialized_name):
				missing = true
				break
			serialized_name = _remaps[serialized_name]
		
		# Retrieve the wrapped value
		var wrapped_value: Variant = null if missing else serialized.get(serialized_name)
		
		# Property is missing or null
		if missing || wrapped_value == null:
			var what_to_do: IfMissing = _properties[property_name]
			if what_to_do == IfMissing.SET_NULL:
				instance.set(property_name, null)
			elif what_to_do == IfMissing.WARN:
				push_warning("property_name (%s) missing in serialied: %s" \
				% [property_name, serialized])
			elif what_to_do == IfMissing.ERROR:
				push_error("property_name (%s) missing in serialied: %s" \
				% [property_name, serialized])
			continue
		
		assert(wrapped_value != null, "wrapped_value is null for serialized_name (%s)" \
		% serialized_name)
		assert(wrapped_value is Dictionary, ("wrapped_value (%s) is not of type Dictionary " + \
		"for serialized_name (%s)") % [wrapped_value, serialized_name])
		
		# Unwrap the value
		var unwrapped_value: Variant = JSONSerialization.unwrap_value(wrapped_value)
		
		# If the unwrapped_value value is null, directly set property to null
		if unwrapped_value == null:
			instance.set(property_name, null)
			continue
		
		assert(object_properties.has(property_name), ("property_name (%s) not found \
		in object (%s)'s property list") % [property_name, instance])
		var property: Dictionary = object_properties[property_name]
		
		var serializer: JSONSerializer = JSONSerialization.get_wrapped_serializer(wrapped_value)
		var existing_property: Variant = instance.get(property_name)
		
		# In debug, ensure wrapped's serializer matches serializer of the existing property value
		if OS.is_debug_build() && existing_property != null:
			var prop_serializer = JSONSerialization.get_serializer(existing_property)
			assert(prop_serializer == serializer, ("existing_property (%s)'s serializer (%s) " + \
			"!= unwrapped value (%s)'s serializer (%s)") % [existing_property, prop_serializer, 
			wrapped_value, serializer])
		
		# Property exists, ensure the serialiazation type matches & check if it can be deserialized into
		if existing_property != null && serializer.has_deserialize_into_func():
			serializer._deserialize_into(existing_property, unwrapped_value)
			continue
		
		assert(serializer.has_deserialize_func(), ("serializer (%s) for property_name (%s) doesn't" + \
		" support _deserialize() & no value is set to deserialize into") % [serializer, property_name])
		var deserialized: Variant = serializer._deserialize(unwrapped_value)
		instance.set(property_name, deserialized)
	
	return instance


## Must be overridden to return a new instance of the object that is used in
## [method _deserialize].
func _create_instance() -> Object:
	assert(false, "_create_instance() not overridden, therefore only _deserialize_into() can be used")
	return null
