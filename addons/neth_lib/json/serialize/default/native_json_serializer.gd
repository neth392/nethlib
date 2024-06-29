## Represents a native type that is supported by Godot's [JSON] methods.[br]
## Native types are not deserialized *into*, but must be directly assigned by
## a [JSONSerializer].
class_name NativeJSONSerializer extends JSONSerializer

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


static func is_native(instance: Variant) -> bool:
	return _native_types.has(typeof(instance))


func _init() -> void:
	super._init(&"Native", DeserializeMode.DESERIALIZE)


func _get_priority() -> int:
	return 1


func _can_serialize(instance: Variant) -> bool:
	return is_native(instance)


func _serialize(instance: Variant) -> Variant:
	return {
		"t": typeof(instance),
		"v": instance
	}


func _deserialize(serialized: Variant) -> Variant:
	assert(serialized is Dictionary, "serialized (%s) not of type Dictionary" % serialized)
	assert(serialized.has("t"), "serialized (%s) does not have key t" % serialized)
	assert(serialized.has("v"), "serialized (%s) does not have key v" % serialized)
	var value: Variant = serialized["v"]
	return null if value == null else type_convert(value, serialized["t"])
