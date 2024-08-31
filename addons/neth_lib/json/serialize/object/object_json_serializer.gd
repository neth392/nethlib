@tool
class_name ObjectJSONSerializer extends JSONSerializer

func _get_id() -> Variant:
	return TYPE_OBJECT


func _serialize(instance: Variant) -> Variant:
	assert(instance is Object, "instance not of type Object")
	
	var object: Object = instance as Object
	
	# Getthe config from the object's meta
	var config: ObjectJSONConfiguration = ObjectJSONMeta.get_config(object)
	
	if config == null:
		# Use the default config if there is no config in the meta
		config = JSONSerialization.get_default_object_config(object)
		assert(config != null, "no  ObjectJSONConfiguration for object (%s)" % object)
	
	var serialized: Dictionary = {}
	
	# Iterate the properies
	for property: JSONProperty in config.properties:
		# Skip disabled properties
		if !property.enabled:
			continue
		
		if property.name not in object:
			# TODO handle missing properties
			continue
		
		var value: Variant = object.get(property.name)
		
		assert(!serialized.has(property.json_key), "duplicate json_keys (%s) for object (%s)" \
		% [property.json_key, value])
		
		# Check if there is an override for the property's ObjectJSONConfiguration
		var override_config: bool = property is JSONObjectProperty \
		and typeof(value) == TYPE_OBJECT \
		and property.config != null
		
		# To store the overridden config
		var original_config: ObjectJSONConfiguration
		
		if override_config:
			# Override the config
			original_config = ObjectJSONMeta.get_config(value)
			ObjectJSONMeta.set_config(value, property.config)
		
		# Serialize the value
		var serialized_value: Variant = JSONSerialization.serialize(value)
		serialized[property.json_key] = serialized_value
		
		# Remove the override if it was overridden
		if override_config:
			ObjectJSONMeta.set_config(value, original_config)
	
	return serialized


## TODO fix this method
func _deserialize(property: Dictionary, serialized: Variant) -> Variant:
	assert(serialized == null || serialized is Dictionary, "instance not null or of type Dictionary")
	assert(!property.is_empty(), ("property is empty for serialized (%s), cant deserialize " +\
	"an object without a property") % serialized)
	if serialized == null:
		return null
	var instance: Object = _create_instance()
	assert(instance != null, "_create_instance() returned null")
	_deserialize_into(instance, serialized)
	return instance


## TODO fix this method
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
