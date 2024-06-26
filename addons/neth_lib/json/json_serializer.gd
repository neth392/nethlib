## A JSON Serializer for a specific type.
class_name JSONSerializer extends RefCounted


## Returns the ID of this [JSONSerializer].
func _get_id() -> StringName:
	return &""


## Optional piority of this [JSONSerializer]. Greater values have greater
## priority, useful for when working with inherited types.
func _get_priority() -> int:
	return 0


## Must return true if the [param variant] is supported by this serializer.
func _can_serialize(instance) -> bool:
	return false


func _can_deserialize_into(instance, serialized) -> bool:
	return false


## Must return true if the [param array] is supported by this serializer.
func _can_serialize_array(array: Array) -> bool:
	return false


## Must parse the [param variant] into a [Variant] which must be able to be
## deserialized by [method _deserialize_into].
func _serialize(instance) -> Variant:
	return {}


func _deserialize_into(instance, serialized) -> void:
	pass
