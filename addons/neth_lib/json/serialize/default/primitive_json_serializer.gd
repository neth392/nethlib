## Represents a "primitive" type that is supported by Godot's [JSON] methods, such as
## [enum Variant.TYPE_STRING], [enum Variant.TYPE_BOOL].
## Primitive types do not support [method JSONSerializer._deserialize_into].
class_name PrimitiveJSONSerializer extends JSONSerializer

@export var primitive_type: Variant.Type

func _init(_primitive_type: Variant.Type = TYPE_NIL) -> void:
	primitive_type = _primitive_type


func _get_id() -> Variant:
	return JSONSerialization.convert_type_to_id(primitive_type)


func _serialize(instance: Variant) -> Variant:
	return instance


func _deserialize(serialized: Variant) -> Variant:
	return null if serialized == null else type_convert(serialized, primitive_type)
