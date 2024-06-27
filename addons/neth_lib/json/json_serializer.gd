## A JSON Serializer for a specific type.
class_name JSONSerializer extends RefCounted

## What type of deserialization is supported by this [JSONSerializer].
enum DeserializeMode {
	## Only [method _deserialize_into] is supported
	DESERIALIZE_INTO,
	## Only [method _deserialize] is supported
	DESERIALIZE,
	## Both [method _deserialize_into] & [method _deserialize] are supported
	BOTH,
}

## The ID of this [JSONSerializer], must be unique from all other serializers.
var id: StringName
var deserialize_mode: DeserializeMode

func _init(_id: StringName, _deserialize_mode: DeserializeMode):
	assert(!_id.is_empty(), "_id is empty")
	id = _id
	deserialize_mode = _deserialize_mode


func has_deserialize_func() -> bool:
	return deserialize_mode == DeserializeMode.DESERIALIZE \
		or deserialize_mode == DeserializeMode.BOTH


func has_deserialize_into_func() -> bool:
	return deserialize_mode == DeserializeMode.DESERIALIZE_INTO \
		or deserialize_mode == DeserializeMode.BOTH


## Optional priority of this [JSONSerializer]. Greater values have greater
## priority, useful for when working with inherited types.
func _get_priority() -> int:
	return 0


## Returns true if the [param variant] is supported by this serializer.
func _can_serialize(instance: Variant) -> bool:
	assert(false, "_can_serialize not supported")
	return false


## Parses [param variant] into a [Variant] which must be able to be
## deserialized by [method _deserialize_into].
func _serialize(instance: Variant) -> Variant:
	assert(false, "_serialize not supported")
	return {}


## Deserializes the [param serialized] by constructing a new instance of the
## supported type. The newly created type is then returned.
func _deserialize(serialized: Variant):
	assert(false, "_deserialize not supported")
	return null


## Deserializes [i]into[/i] the specified [param instance] from the [param serialized].
## Returns the [param instance].
func _deserialize_into(instance: Variant, serialized: Variant):
	assert(false, "_deserialize_into not supported")


func _to_string() -> String:
	return "JSONSerializer(%s)" % id
