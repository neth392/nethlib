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
func _serialize(instance: Variant) -> Variant:
	assert(false, "_serialize not implemented for serializer id (%s)" % id)
	return {}


## Deserializes the [param serialized] by constructing a new instance of the
## supported type. The newly created type is then returned.
## [method property] is the property of the object being deserialized, keys & values are 
## the same as the [Dictionary]s returned in [method Object.get_property_list].
func _deserialize(property: Dictionary, serialized: Variant) -> Variant:
	assert(false, "_deserialize not implemented for serializer id (%s)" % id)
	return null


## Deserializes [i]into[/i] the specified [param instance] from the [param serialized].
## [method property] is the property of the object being deserialized, keys & values are 
## the same as the [Dictionary]s returned in [method Object.get_property_list].
func _deserialize_into(property: Dictionary, instance: Variant, serialized: Variant) -> void:
	assert(false, "_deserialize_into not implemented for serializer id (%s)" % id)


func _to_string() -> String:
	return "JSONSerializer(%s)" % id
