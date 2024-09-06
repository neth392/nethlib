## Conducts serialization & deserialization of all types. Stores [JSONSerializer]s and
## [JSONObjectConfig]s.
@tool
class_name JSONSerializationImpl extends Node

@export var serialize_all_types: bool = true

## Parameter used in [method JSON.stringify]
## TODO add to project settings
var indent: String = ""
## Parameter used in [method JSON.stringify]
## TODO add to project settings
var sort_keys: bool = true
## Parameter used in [method JSON.stringify]
## TODO add to project settings
var full_precision: bool = false
## Parameter used in [method JSON.parse]
## TODO add to project settings
var keep_text: bool = false

## [member JSONSerializer.id]:[JSONSerializer]
var _serializers: Dictionary = {}

## The user's [JSONObjectConfigRegistry] to allow adding [JSONObjectConfig]s via
## the inspector.
var object_config_registry: JSONObjectConfigRegistry

# Internal cache of native serializers used by others to prevent unnecessary dictionary lookups
var _color: JSONSerializer
var _vector2: JSONSerializer
var _vector2i: JSONSerializer
var _vector3: JSONSerializer
var _vector4: JSONSerializer
var _basis: JSONSerializer
var _object: JSONSerializer


## Constructs & returns a new JSON-parsable [Dictionary] containing a "i" key
## of [member JSONSerializer.id] from the [param serializer], and a
## "v" of [param serialized]. Will only be truly JSON parsable if the [param serialized]
## is natively supported by Godot's JSON.
func wrap_value(serializer: JSONSerializer, serialized: Variant) -> Dictionary:
	return {
		"i": serializer.id,
		"v": serialized,
	}


## Unwraps & returns the value from the [param wrapped_value] assuming it was created
## via [method wrap_value].
func unwrap_value(wrapped_value: Dictionary) -> Variant:
	assert(wrapped_value != null, "wrapped_value is null")
	assert(wrapped_value.has("v"), "wrapped_value (%s) does not have 'v' key" % wrapped_value)
	return wrapped_value.v


## Retunrs true if [param variant] is supported by a [JSONSerializer], false if not.
func is_serializiable(variant: Variant) -> bool:
	return is_type_serializable(typeof(variant))


## Returns true if the [param type] is supported by a [JSONSerializer], false if not.
func is_type_serializable(type: Variant.Type) -> bool:
	return _serializers.has(str(type))


## Adds the [param serializer].
func add_serializer(serializer: JSONSerializer) -> void:
	assert(serializer != null, "serializer is null")
	assert(!_serializers.has(serializer.id), "a serializer with id (%s) already exists" % serializer.id)
	_serializers[serializer.id] = serializer


## Removes the [param serializer], returning true if removed, false if not.
func remove_serializer(serializer: JSONSerializer) -> bool:
	assert(serializer != null, "serializer is null")
	return _serializers.erase(serializer.id)


## Returns the [JSONSerializer] with the [param id], or null if one does not exist.
func get_serializer_for_type(type: Variant.Type) -> JSONSerializer:
	return _serializers.get(type)


## Returns the [JSONSerializer] for use with deserializing the [param wrapped_value].
## [param serialize] must be a [Dictionary] wrapped by [JSONSerialization].
## An assertion is called so that in debug mode if no [JSONSerializer] is found for the 
## [param wrapped_value], an error is thrown. In release mode an error will be thrown
## as well, but from trying to access a missing key from the internal [member _serializers]
## dictionary.
func get_deserializer(wrapped_value: Dictionary) -> JSONSerializer:
	assert(wrapped_value.has("i"), "'i' key not found in wrapped_value (%s)" % wrapped_value)
	assert(_serializers.has(wrapped_value.i), ("no JSONSerializer with id (%s) found for " + \
	"wrapped_value(%s)") % [wrapped_value.i, wrapped_value])
	
	return _serializers[wrapped_value.i]


## Serializes the [param variant] into a wrapped [Dictionary] (see [method wrap_value]) 
## that can be safely stored via JSON & deserialized.
func serialize(variant: Variant) -> Dictionary:
	# str(variant) needed as some types such as RID will not work w/o it
	assert(is_serializiable(variant), "variant (%s) not supported by any JSONSerializer" % str(variant))
	
	var serializer: JSONSerializer = get_serializer_for_type(typeof(variant))
	assert(serializer != null, "get_serializer_for_type(typeof(%s)) returned null" % variant)
	var serialized: Variant = serializer._serialize(variant, self)
	
	return wrap_value(serializer, serialized)


## Deserializes the [param wrapped_value] and creates & returns a new instance of the type.
func deserialize(wrapped_value: Dictionary) -> Variant:
	assert(wrapped_value != null, "wrapped_value is null, must be a Dictionary")
	
	var serializer: JSONSerializer = get_deserializer(wrapped_value)
	assert(serializer != null, "get_deserializer(%s) returned null" % wrapped_value)
	var unwrapped_value: Variant = unwrap_value(wrapped_value)
	
	return serializer._deserialize(unwrapped_value, self)


## Deserializes the [param wrapped_value] into the specified [param instance]. The [param instance]
## can not be null and its [JSONSerializer] must support [method JSONSerializer._deserialize_into],
## which currently is only supported for [Array], [Dictionary], and [Object].
func deserialize_into(wrapped_value: Dictionary, instance: Variant) -> void:
	assert(instance != null, "instance is null, can't deserialize into a null instance")
	
	var serializer: JSONSerializer = get_serializer_for_type(typeof(instance))
	assert(serializer != null, "get_serializer_for_type(typeof(%s)) returned null" % instance)
	
	# In debug, ensure serializers match up from instance type & wrapped type
	if OS.is_debug_build():
		var wrapped_serializer: JSONSerializer = get_deserializer(wrapped_value)
		assert(serializer == wrapped_serializer, ("serializer (%s) of instance (%s) " + \
		"does not match serializer (%s) of wrapped_value (%s)") % [serializer, instance, \
		 wrapped_serializer, wrapped_value])
	
	var unwrapped_value: Variant = unwrap_value(wrapped_value)
	serializer._deserialize_into(wrapped_value, instance, self)


## Helper function that calls [method serialize] with the [param variant],
## then passing that varaint & other parameters into [method JSON.stringify], returning
## that value.
func stringify(variant: Variant) -> String:
	var serialized: Dictionary = serialize(variant)
	return JSON.stringify(serialized, indent, sort_keys, full_precision)


## Helper function that calls [method JSON.parse] with [param wrapped_json_string], then
## sends the resulting [Variant] to [method deserialize], returning that value.
## [br][param wrapped_json_string] is what is returned by [method serialize], and
## [method stringify].
func parse(wrapped_json_string: String) -> Variant:
	var parsed: Variant = _parse(wrapped_json_string)
	return deserialize(parsed as Dictionary)


## Helper function to call [method JSON.parse_string] with [param wrapped_json_string], then
## sends the resulting [Variant] and [param instance] to [method deserialize_into].
## [br][param wrapped_json_string] is what is returned by [method serialize], and
## [method stringify].
func parse_into(instance: Variant, wrapped_json_string: String) -> void:
	var parsed: Variant = _parse(wrapped_json_string)
	deserialize_into(instance, parsed as Dictionary)


## Internal helper function for [method parse] and [method parse_into].
func _parse(wrapped_json_string: String) -> Variant:
	var json: JSON = JSON.new()
	var error: Error = json.parse(wrapped_json_string, keep_text)
	assert(error == OK, "JSON error: line=%s,message=%s" % [json.get_error_line(), json.get_error_message()])
	assert(json.data is Dictionary, "json.parse() result (%s) not of type Dictionary for wrapped_json_string %s"\
	 % [json.data, wrapped_json_string])
	return json.data
