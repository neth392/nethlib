## Represents a native type that is supported by Godot's [JSON] methods.[br]
## Native types are not deserialized *into*, but must be directly assigned by
## a [JSONSerializer].
class_name NativeJSONSerializer extends JSONSerializer

const ID: StringName = &"Native"

static var _native_types: Array[Variant.Type] = [
		TYPE_NIL,
		TYPE_BOOL,
		TYPE_INT,
		TYPE_FLOAT,
		TYPE_PACKED_INT32_ARRAY,
		TYPE_PACKED_INT64_ARRAY,
		TYPE_PACKED_FLOAT32_ARRAY,
		TYPE_PACKED_FLOAT64_ARRAY,
		TYPE_PACKED_STRING_ARRAY,
		TYPE_STRING,
	]


static func is_type_native(type: Variant.Type) -> bool:
	return _native_types.has(type)


static func is_native(instance: Variant) -> bool:
	return is_type_native(typeof(instance))


func _init() -> void:
	super._init(ID, DeserializeMode.DESERIALIZE)


func _get_priority() -> int:
	return 1


func _can_serialize(instance: Variant) -> bool:
	return is_native(instance)


func _serialize(instance: Variant) -> Variant:
	return instance


func _deserialize(serialized: Variant) -> Variant:
	return serialized
