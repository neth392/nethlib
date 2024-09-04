## Used to create instances of [Object]s when they are being deserialized but
## there is no instance to deserialize into. Instead of storing data on how to 
## instantiate objects in the serialized data, this way of doing things is much
## safer as it prevents breakages from refactoring of file paths, class name changes,
## etc.
@tool
class_name JSONInstantiator extends Resource

## Returns true if the [param property] and [param serialized] can be instantiated,
## false if not.
func _can_instantiate(property: Dictionary, serialized: Dictionary) -> bool:
	return false


## Instantiates & returns a new [Object] instance. [method property] is the
## property of the object being deserialized, keys & values are the same as the
## [Dictionary]s returned in [method Object.get_property_list]. [param serialized]
## is the serialized version of the object, it can be used to check for existing
## json keys (defined in the bottom JSON panel which represents [JSONObjectConfig])
func _instantiate(property: Dictionary, serialized: Dictionary) -> Object:
	assert(false, "_instantiate not overridden")
	return null
