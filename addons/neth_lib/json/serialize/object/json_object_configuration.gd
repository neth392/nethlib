## A configuration containing specifications on how to serialize & deserialize an
## arbitrary [Object]. Can be reused across objects of multiple types.
class_name JSONObjectConfiguration extends Resource

## The [JSONProperty]s that are to be serialized. Properties with [member JSONProperty.enabled]
## as false are ignored. The order of this array is important as it determines in which order
## properties are serialized in.
## [br]Format: [member JSONProperty.json_key]:[JSONProperty]
@export var _properties: Dictionary = {}


## The [JSONObjectInstantiator] used anytime a property of this type is being deserialized
## but the property's assigned value is null. See that class's docs for more info.
@export var instantiator: JSONObjectInstantiator = SmartJSONObjectInstantiator.new()


## Returns true if a [JSONProperty] with the [param json_key] exists, false if not.
func has_property(json_key: StringName) -> bool:
	return _properties.has(json_key)


## Returns the [JSONProperty] with the [param json_key], or null if it does not exist.
func get_property(json_key: StringName) -> JSONProperty:
	return _properties.get(json_key, null)


## Adds the [param property]. An error is thrown in debug mode if the property already exists.
func add_property(property: JSONProperty) -> void:
	assert(property != null, "property is null")
	assert(!property.json_key.is_empty(), "property.json_key is empty for property (%s)" % property)
	assert(!_properties.has(property.json_key), "json_key (%s) already exists" % property.json_key)
	_properties[property.json_key] = property


## Removes the [JSONProperty] of the [param json_key]. Returns true if removed, false
## if it wasn't as it doesn't exist.
func remove_property(json_key: StringName) -> bool:
	return _properties.erase(json_key)


## Returns the [JSONObjectConfiguration]s for the property with key [param json_key].
## If the property does not exist, is not a [JSONObjectProperty], or is not a
## [JSONDictionaryProperty], an empty array is returned.
func get_configs_for_property(json_key: StringName) -> Array[JSONObjectConfiguration]:
	var property: JSONProperty = _properties.get(json_key, null)
	if property is JSONObjectProperty:
		return [property.config]
	elif property is JSONDictionaryProperty:
		return [property.key_config, property.value_config]
	return []
