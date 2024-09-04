## A JSON Serializer for a specific type (or types in some cases)
class_name JSONSerializer extends Resource

## The ID of this [JSONSerializer]
var id: String:
	get():
		var id: Variant = _get_id()
		assert(id != null, "_get_id() returned null")
		return str(id) # Convert to string
	set(value):
		assert(false, "override _get_id() to change the ID")


## Must be overridden to return the ID of this [JSONSerializer], to be stored in the JSON to determine
## which [JSONSerializer] to use when deserializing. Returned [Variant] will be converted to a [String]
## by [member id]'s getter.
func _get_id() -> Variant:
	assert(false, "_get_id() not implemented")
	return null


## Parses [param variant] into a [Variant] which must be able to be
## deserialized by [method _deserialize_into].
## [param impl] is the JSONSerialization implementation being used.
## [param object_config] is the [JSONObjectConfig] of the object being serialized, 
## only used in deserializers concerning objects such as arrays, dictionaries, & objects themselves.
func _serialize(instance: Variant, impl: JSONSerializationImpl, 
object_configs: Array[JSONObjectConfig]) -> Variant:
	assert(false, "_serialize not implemented for serializer id (%s)" % id)
	return {}


## Deserializes the [param serialized] by constructing a new instance of the
## supported type. The newly created type is then returned.
## [param impl] is the JSONSerialization implementation being used.
## [param object_config]s is the [JSONObjectConfig] of the object being deserialized, 
## only used in deserializers concerning objects such as arrays, dictionaries, & objects themselves.
func _deserialize(serialized: Variant, impl: JSONSerializationImpl, 
object_configs: Array[JSONObjectConfig]) -> Variant:
	assert(false, "_deserialize not implemented for serializer id (%s)" % id)
	return null


## Deserializes [i]into[/i] the specified [param instance] from the [param serialized].
## [param impl] is the JSONSerialization implementation being used.
## [param object_config] is the [JSONObjectConfig] of the object being deserialized, 
## only used in deserializers concerning objects such as arrays, dictionaries, & objects themselves.
func _deserialize_into(serialized: Variant, instance: Variant, impl: JSONSerializationImpl, 
object_configs: Array[JSONObjectConfig]) -> void:
	assert(false, "_deserialize_into not implemented for serializer id (%s)" % id)


func _to_string() -> String:
	return "JSONSerializer(%s)" % id
