## Abstract [JSONSerializer] implementation that is meant to be extended
## for each specific object type that needs to be serialized/deserialized.[br]
## In inheriting classes, it is crucial to use [code]super._init(...)[/code],
## and inherit [method _get_properties]. Optionally [method _get_remaps] can be
## implemented as well.
class_name ObjectJSONSerializer extends JSONSerializer

## How to handle properties from [member _property_names] that are either
## not found in serialized data or have a null value.
enum IfMissing {
	## Ignore that it is missing and continue on.
	IGNORE,
	## Set the property to null in the object.
	SET_NULL,
	## Push a warning.
	WARN,
	## Throw an error (dangerous).
	ERROR,
}

## Returns an [Array] of [StringName]s for ALL of the [param object]'s properties.
static func for_all_properties(object: Object) -> Array[StringName]:
	var prop_names: Array[StringName] = []
	for property: Dictionary in object.get_property_list():
		prop_names.append(property.name as StringName)
	return prop_names

var _property_names: Dictionary
var _remaps: Dictionary

func _init(_id: StringName, _deserialize_mode: DeserializeMode = DeserializeMode.DESERIALIZE_INTO):
	super._init(_id, _deserialize_mode)
	_property_names = _get_properties()
	if OS.is_debug_build():
		for property_name in _property_names:
			assert(property_name is String || property_name is StringName, ("property_name (%s) " + \
			"not of type String or StringName") % property_name)
			assert(_property_names[property_name] is IfMissing, ("value for property_name (%s) " + \
			" not of type IfMissing") % property_name)
	_remaps = _get_deserialization_remaps()
	assert(!_property_names.is_empty(), "_property_names is empty")


func _serialize(instance: Variant) -> Variant:
	assert(instance != null, "instance is null")
	assert(instance is Object, "instance not of type object")
	var object: Object = instance as Object
	var serialized: Dictionary = {}
	for property_name: StringName in _property_names:
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


func _deserialize_into(instance: Variant, serialized: Variant) -> Variant:
	assert(instance != null, "instance is null")
	assert(serialized != null, "serialized is null")
	assert(instance is Object, "instance not of type Vector3")
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	
	# Sort object properties into a [Dictionary] for quick access
	var object_properties: Dictionary = {}
	for property: Dictionary in instance.get_property_list():
		object_properties[property.name] = property
	
	# Iterate expected properties
	for property_name: StringName in _property_names:
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
			var what_to_do: IfMissing = _property_names[property_name]
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


## Must be overridden to return an [Dictionary] of [StringName]s keys representing
## the names of properties that are to be serialized & deserialized. Values
## are [enum IfMissing], true if the value is required, false if optional.[br]
## For performance reasons, it is important the [StringName]s are explicitly
## defined as it speeds up the many [method Object.get] calls this serializer uses.
func _get_properties() -> Dictionary:
	return {}


## Can be overridden to return a [Dictionary] in the format of 
## {&"new_prop_stringname":&"old_prop_stringname"}.[br]
## Remaps are essential when a property name in a script changes, as it'll
## make [method _deserialize_into] aware that the new property name may not exist
## and in that case it'll look for the remap value.
func _get_deserialization_remaps() -> Dictionary:
	return {}
