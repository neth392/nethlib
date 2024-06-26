extends Node

## Types supported natively by Godot's JSON.[br]
## Array & Dictionary are excluded as their types may not be compatible.
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
		TYPE_DICTIONARY,
		TYPE_ARRAY,
	]

var _serializers: Array[JSONSerializer] = []

func _ready() -> void:
	add_serializer(NativeJSONSerializer.new())
	add_serializer(preload("./default/vector2_json_serializer.gd").new())
	add_serializer(preload("./default/vector3_json_serializer.gd").new())
	add_serializer(preload("./default/color_json_serializer.gd").new())


func add_serializer(serializer: JSONSerializer) -> void:
	assert(!_serializers.has(serializer), "serializer already registered: %s" % serializer)
	_serializers.append(serializer)
	_serializers.sort_custom(
		func(a: JSONSerializer, b: JSONSerializer):
			return a._get_priority() > b._get_priority()
	)


func get_serializer(variant: Variant) -> JSONSerializer:
	assert(variant != null, "variant is null")
	for serializer: JSONSerializer in _serializers:
		if serializer._can_serialize(variant):
			return serializer
	push_error("no serializer found for variant: %s" % variant)
	return null


## Serializes the [param variant] into a [Variant] supported by [method JSON.stringify].
func serialize(variant: Variant) -> Variant:
	assert(variant != null, "variant is null")
	assert(get_serializer(variant) != null, "no serializer for variant (%s)" % variant)
	
	var serializer: JSONSerializer = get_serializer(variant)
	var serialized: Variant = serializer._serialize(variant)
	
	assert(serialized != null, "serialized is null for variant (%s)" % variant)
	assert(_native_types.has(typeof(serialized)), "serialized (%s) typeof (%s) not" + \
	"natively supported by JSON.stringify" % [serialized, typeof(serialized)])
	
	return serialized


## Deserializes the [param serialized] into the specified [param instance].
func deserialize_into(instance: Variant, serialized: Variant) -> void:
	assert(instance != null, "instance is null")
	assert(!NativeJSONSerializer.is_native(instance), "instance (%s) is native and " + \
	"can't be deserialized into")
	assert(get_serializer(instance) != null, "no serializer for instance (%s)" % instance)
	
	var serializer: JSONSerializer = get_serializer(instance)
	
	assert(!(serializer is NativeJSONSerializer), "native instance (%s) can not " + \
	"be deserialized into" % instance)
	
	serializer._deserialize_into(instance, serialized)
