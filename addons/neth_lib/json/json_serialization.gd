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

var _serializers_ordered: Array[JSONSerializer] = []
var _serializers_by_id: Dictionary = {}

func _ready() -> void:
	add_serializer(NativeJSONSerializer.new())
	add_serializer(preload("./default/vector2_json_serializer.gd").new())
	add_serializer(preload("./default/vector3_json_serializer.gd").new())
	add_serializer(preload("./default/color_json_serializer.gd").new())


## Constructs & returns a new JSON-parsable [Dictionary] containing a "type" key
## with value of the [member JSONSerializer.id] of the [param serializer], and a
## "value" key with value as the [param serialized_value]. Will only be JSON parsable
## if the [param serialized_value] is natively supported by Godot's JSON.
func wrap_value(serializer: JSONSerializer, serialized_value: Variant) -> Dictionary:
	return {
		"type": serializer.id,
		"value": serialized_value,
	}

## Unwraps & returns the value from the [param wrapped_value] assuming it was created
## via [method wrap_value].
func unwrap_value(wrapped_value: Dictionary) -> Variant:
	assert(wrapped_value != null, "wrapped_value is null")
	assert(wrapped_value.has("value"), "wrapped_value (%s) does not have 'value' key" % wrapped_value)
	return wrapped_value.value


func add_serializer(serializer: JSONSerializer) -> void:
	assert(!_serializers_by_id.has(serializer.id), "serializer already registered: %s" % serializer)
	_serializers_by_id[serializer.id] = serializer
	_serializers_ordered.append(serializer)
	_serializers_ordered.sort_custom(
		func(a: JSONSerializer, b: JSONSerializer):
			return a._get_priority() > b._get_priority()
	)


## Returns the [JSONSerializer] for use with serializing the [param variant].
## Returns null & pushes an error if one is not found.
func get_serializer(variant: Variant) -> JSONSerializer:
	assert(variant != null, "variant is null")
	for serializer: JSONSerializer in _serializers_ordered:
		if serializer._can_serialize(variant):
			return serializer
	assert(false, "no serializer found to serialize variant: %s" % variant)
	return null


## Returns the [JSONSerializer] for use with deserializing the [param variant].
func get_wrapped_serializer(wrapped_serialized: Dictionary) -> JSONSerializer:
	assert(wrapped_serialized.has("type"), "'type' key not found in wrapped_serialized (%s)" \
	% wrapped_serialized)
	assert(_serializers_by_id.has(wrapped_serialized.type), "no JSONSerializer with " + \
	"type id (%s) found" % wrapped_serialized.type)
	var type: StringName = wrapped_serialized.type
	return _serializers_by_id[type] as JSONSerializer


## Serializes the [param variant] into a wrapped [Dictionary] (see [method wrap_value]) 
## that can be safely stored via JSON & deserialized via [method deserialize_into] (excluding
## native types)
func serialize(variant: Variant) -> Dictionary:
	assert(variant != null, "variant is null")
	assert(get_serializer(variant) != null, "no serializer for variant (%s)" % variant)
	
	var serializer: JSONSerializer = get_serializer(variant)
	var serialized: Variant = serializer._serialize(variant)
	
	assert(serialized != null, "serialized is null for variant (%s), serializer (%s)" \
	% [variant, serializer])
	
	assert(_native_types.has(typeof(serialized)), """serialized (%s) type not natively 
	supported by JSON.stringify, serializer: %s""" % [str(serialized), str(serializer)])
	
	return wrap_value(serializer, serialized)


## Deserializes the [param wrapped_value] and creates & returns a new instance of the type.
func deserialize(wrapped_value: Dictionary) -> Variant:
	assert(wrapped_value != null, "wrapped_value is null")
	
	var serializer: JSONSerializer = get_wrapped_serializer(wrapped_value)
	assert(serializer != null, "no serializer for wrapped_value (%s)" % wrapped_value)
	assert(serializer.has_deserialize_func(), "serializer (%s) for wrapped_value (%s) " + \
	"does not support deserialize" % [serializer, wrapped_value])
	
	var unwrapped_value: Variant = unwrap_value(wrapped_value)
	return serializer._deserialize(unwrapped_value)


## Deserializes the [param wrapped_value] into the specified [param instance].[br]
## Returns the [param instance] after it was deserialized into.
func deserialize_into(instance: Variant, wrapped_value: Dictionary) -> Variant:
	assert(instance != null, "instance is null")
	assert(wrapped_value != null, "wrapped_value is null")
	
	assert(!NativeJSONSerializer.is_native(instance), ("instance (%s) is native and " + \
	"can't be deserialized into") % instance)
	
	
	var serializer: JSONSerializer = get_serializer(instance)
	assert(serializer != null, "no serializer for instance (%s)" % instance)
	assert(serializer.has_deserialize_into_func(), ("serializer (%s) for instance (%s) " + \
	"does not support deserialize_into") % [serializer, instance])
	
	# In debug, ensure serializers match up from instance type & wrapped type
	if OS.is_debug_build():
		var wrapped_serializer: JSONSerializer = get_wrapped_serializer(wrapped_value)
		assert(wrapped_serializer != null, "no serializer found for wrapped_value (%s)" \
		% wrapped_value)
		assert(serializer == wrapped_serializer, ("serializer (%s) of instance (%s) " + \
		"does not match serializer (%s) of wrapped_value (%s)") % [serializer, instance, \
		 wrapped_serializer, wrapped_value])
	
	var unwrapped_value: Variant = unwrap_value(wrapped_value)
	return serializer._deserialize_into(instance, unwrapped_value)


## Helper function to call [method serialize] with the [param variant]
## and then call [method JSON.stringify] with the returned value. The JSON supported
## [String] is then returned.
func stringify(variant: Variant) -> String:
	assert(variant != null, "variant is null")
	var serialized: Dictionary = serialize(variant)
	return JSON.stringify(serialized)


## Helper function to call [method JSON.parse_string] with [param wrapped_json_string], and then
## send the resulting [Variant] to [method deserialize]. The result of deserialize is returned.
func parse(wrapped_json_string: String) -> Variant:
	var parsed: Variant = JSON.parse_string(wrapped_json_string)
	assert(parsed is Dictionary, "parsed result of JSON is not of type Dictionary: %s" % wrapped_json_string)
	return deserialize(parsed as Dictionary)


## Helper function to call [method JSON.parse_string] with [param wrapped_json_string] , and then
## send the resulting [Variant] and [param instance] to [method deserialize_into].
## [param instance] is returned after it was deserialized into.
func parse_into(instance: Variant, wrapped_json_string: String) -> Variant:
	var parsed: Variant = JSON.parse_string(wrapped_json_string)
	assert(parsed is Dictionary, "parsed result of JSON is not of type Dictionary: %s" % wrapped_json_string)
	return deserialize_into(instance, parsed as Dictionary)
