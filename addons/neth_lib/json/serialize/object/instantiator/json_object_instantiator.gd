## Used to create instances of [Object]s when they are being deserialized but
## there is no instance to deserialize into. The BEST way is to always assign your
## properties default values of object instances, but sometimes that isn't feasible such
## as when you have an [Array] of dynamic objects. 
## So, instead of storing data on how to instantiate it, I find it much safer to use 
## this approach as it protects against saves being broken from renaming classes 
## & moving files around.
@tool
class_name JSONObjectInstantiator extends Resource

## Instantiates & returns a new [Object] instance. [method property] is the
## property of the object being deserialized, keys & values are the same as the
## [Dictionary]s returned in [method Object.get_property_list]. [param serialized]
## is the serialized version of the object, it can be used to check for existing
## json keys (defined in the bottom JSON panel which represents [ObjectJSONConfiguration])
func _instantiate(property: Dictionary, serialized: Dictionary) -> Object:
	assert(false, "_instantiate not overridden")
	return null
