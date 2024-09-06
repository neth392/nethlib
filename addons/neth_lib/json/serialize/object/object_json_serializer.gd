@tool
extends JSONSerializer

func _get_id() -> Variant:
	return TYPE_OBJECT


func _serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(instance is Object, "instance not of type Object")
	
	var object: Object = instance as Object
	
	# Determine the class
	var object_class: StringName = ObjectUtil.get_class_name(object)
	assert(!object_class.is_empty(), "object (%s) does not have a class defined" % object_class)
	
	# Get the config by class
	var config: JSONObjectConfig = impl.object_config_registry.get_config_by_class(object_class)
	assert(config != null, "no JSONObjectConfig found for object_class %s" % object_class)
	
	var serialized: Dictionary = {}
	
	# Iterate the properies
	for property: JSONProperty in config.get_properties_extended():
		# Skip disabled properties
		if !property.enabled:
			continue
		
		# Ensure no duplicates
		assert(!serialized.has(property.json_key), "duplicate json_keys (%s) for object (%s)" \
		% [property.json_key, object])
		
		# Check if property exists in the object
		if property.name not in object:
			match property.if_missing_in_object_serialize:
				JSONProperty.IfMissing.WARN_DEBUG:
					push_warning("property (%s) missing in object (%s)" % [property, object])
				JSONProperty.IfMissing.ERROR_DEBUG:
					assert(false, "property (%s) missing in object (%s)" % [property, object])
			continue
		
		var value: Variant = object.get(property.name)
		var serialized_value: Variant = impl.serialize(value)
		serialized[property.json_key] = serialized_value
	
	# Wrap value with an extra dictionary to store which deserializer to use
	return {
		"i": config.id,
		"v": serialized,
	}


## TODO fix this method
func _deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(serialized is Dictionary, "serialized (%s) not of type Dictionary" % serialized)
	assert(serialized.has("i"), "serialized (%s) missing 'i' key" % serialized)
	
	var config: JSONObjectConfig = _get_config(serialized, impl)
	assert(config.instantiator != null, ("config (%s)'s instantiator is null, use " + \
	"_deserialize_into() with an existing instance instead") % config)
	assert(config.instantiator._can_instantiate(), ("cant instantiate config %s, use " + \
	"_deserialize_into() with an existing instance instead") % config)
	
	# Create instance
	var instance: Object = config.instantiator._instantiate()
	assert(instance != null, "config (%s)'s instantiator._instantiate() returned null" % config)
	
	_deserialize_into_w_config(serialized, instance, impl, config)
	
	return instance


## TODO fix this method
func _deserialize_into(serialized: Variant, instance: Variant, impl: JSONSerializationImpl) -> void:
	assert(instance != null, "instance is null; can't deserialize into a null instance")
	assert(instance is Object, "instance not of type Object")
	assert(serialized is Dictionary, "serialized not null or of type Dictionary")
	assert(serialized.has("i"), "serialized (%s) missing 'i' key" % serialized)
	
	
	# Determine config ID
	var config_id: StringName = StringName(serialized.i)
	assert(!config_id.is_empty(), "config_id empty for serialized (%s)" % serialized)
	
	# Determine config
	var config: JSONObjectConfig = impl.object_config_registry.get_config_by_id(config_id)
	
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


func _get_config(serialized: Dictionary, impl: JSONSerializationImpl) -> JSONObjectConfig:
	# Determine config ID
	var config_id: StringName = StringName(serialized.i)
	assert(!config_id.is_empty(), "config_id empty for serialized (%s)" % serialized)
	
	# Determine config
	var config: JSONObjectConfig = impl.object_config_registry.get_config_by_id(config_id)
	assert(config != null, "no config with id (%s) found" % config_id)
	
	return config



func _deserialize_into_w_config(serialized: Dictionary, instance: Variant, impl: JSONSerializationImpl,
config: JSONObjectConfig) -> void:
	assert(serialized.has("v"), "serialized (%s) missing 'v' key" % serialized)
	
	var serialized_value: Dictionary = serialized.get("v") as Dictionary
	assert(serialized_value is Dictionary, "serialized[v] not of type Dictionary, serialized=%s" \
	% serialized)
	
	for property: JSONProperty in config.get_properties_extended():
		pass
	
	pass
