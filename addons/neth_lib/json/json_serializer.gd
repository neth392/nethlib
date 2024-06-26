## A JSON Serializer for a specific type.
class_name JSONSerializer extends RefCounted

## Must return true if the [param variant] is supported by this serializer.
func _can_serialize(variant) -> bool:
	return false


## Must parse the [param variant] into a [Dictionary] which
## should be parsable by the 
func _serialize(variant) -> Dictionary:
	return {}


func _deserialize_into(instance, json_dictionary: Dictionary) -> void:
	pass
