## Autoloaded class (named JSONSerialization) responsible for managing [JSONSerializer]s and providing
## serialization & deserialization.
extends Node

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

## [Variant]:[Variant] as to where the key is the previous [member JSONSerializer.id],
## and the value is the new [member JSONSerializer.id].
var _deserialization_remaps: Dictionary = {}


func _ready() -> void:
	# Add types confirmed to be working with PrimitiveJSONSerializer
	# see default/primitive_json_serializer_tests.gd for code used to test this
	# Some were omitted as they made no sense; such as Basis which worked but
	# Vector3 didnt, and a Basis is comprised of 3 Vector3s ??? Don't want to risk that
	# getting all fucky wucky in a release build.
	add_serializer(PrimitiveJSONSerializer.new(TYPE_NIL))
	add_serializer(PrimitiveJSONSerializer.new(TYPE_BOOL))
	add_serializer(PrimitiveJSONSerializer.new(TYPE_INT))
	add_serializer(PrimitiveJSONSerializer.new(TYPE_FLOAT))
	add_serializer(PrimitiveJSONSerializer.new(TYPE_STRING))
	add_serializer(PrimitiveJSONSerializer.new(TYPE_STRING_NAME))
	add_serializer(PrimitiveJSONSerializer.new(TYPE_PACKED_INT32_ARRAY))
	add_serializer(PrimitiveJSONSerializer.new(TYPE_PACKED_INT64_ARRAY))
	add_serializer(PrimitiveJSONSerializer.new(TYPE_PACKED_FLOAT32_ARRAY))
	add_serializer(PrimitiveJSONSerializer.new(TYPE_PACKED_FLOAT64_ARRAY))
	add_serializer(PrimitiveJSONSerializer.new(TYPE_PACKED_STRING_ARRAY))
	
	# Add other default serializers
	add_serializer(ArrayJSONSerializer.new())
	add_serializer(DictionaryJSONSerializer.new())
	add_serializer(ColorJSONSerializer.new())
	add_serializer(Vector2JSONSerializer.new())
	add_serializer(Vector2IJSONSerializer.new())
	add_serializer(Vector3JSONSerializer.new())
	add_serializer(Vector3IJSONSerializer.new())
	add_serializer(Vector4JSONSerializer.new())
	add_serializer(Vector4IJSONSerializer.new())
	
	ProjectSettings.settings_changed.connect(_on_project_setting_changed)


func _on_project_setting_changed() -> void:
	# TODO serialize_all_types project setting maybe?
	pass


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
	var id: Variant = derive_serializer_id(variant)
	if variant is Object:
		print("ID: " + str(id))
	return _serializers.has(id)


## Adds the [param serializer].
func add_serializer(serializer: JSONSerializer) -> void:
	assert(serializer != null, "serializer is null")
	assert(!_serializers.has(serializer.id), "a serializer with id (%s) already exists" % serializer.id)
	_serializers[serializer.id] = serializer


## Removes the [param serializer], returning true if removed, false if not.
func remove_serializer(serializer: JSONSerializer) -> bool:
	assert(serializer != null, "serializer is null")
	return _serializers.erase(serializer.id)


## Derives the serializer ID from [param variant].
func derive_serializer_id(variant: Variant) -> Variant:
	if variant is Object:
		var script: Script = variant.get_script() as Script
		
		# 1. Use the resource path of the script
		if script != null && !script.resource_path.is_empty():
			return script.resource_path
		
		# 2. Use the class name
		var _class: String = variant.get_class()
		if !_class.is_empty():
			return _class
	
	# 3. Use the type as string version (otherwise its serialized as a float)
	return str(typeof(variant))


## Returns the [JSONSerializer] for use with serializing the [param variant]. If no
## serilaizer is found, in debug mode an assertion is called resulting in an error, and
## in release mode an error will be thrown from trying to retrieve a non-existent key
## from the internal [member _serializers] dictionary.
func get_serializer(variant: Variant) -> JSONSerializer:
	assert(is_serializiable(variant), "variant (%s) not supported by any JSONSerializer")
	var id: Variant = derive_serializer_id(variant)
	return _serializers[id]


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
## that can be safely stored via JSON & deserialized via [method deserialize_into] (excluding
## native types)
func serialize(variant: Variant) -> Dictionary:
	# str(variant) needed as some types such as RID will not work w/o it
	assert(is_serializiable(variant), "variant (%s) not supported by any JSONSerializer" % str(variant))
	
	var serializer: JSONSerializer = get_serializer(variant)
	var serialized: Variant = serializer._serialize(variant)
	
	return wrap_value(serializer, serialized)


## Deserializes the [param wrapped_value] and creates & returns a new instance of the type.
func deserialize(wrapped_value: Dictionary) -> Variant:
	assert(wrapped_value != null, "wrapped_value is null, must be a Dictionary")
	
	var serializer: JSONSerializer = get_deserializer(wrapped_value)
	var unwrapped_value: Variant = unwrap_value(wrapped_value)
	return serializer._deserialize(unwrapped_value)


## Deserializes the [param wrapped_value] into the specified [param instance].
func deserialize_into(instance: Variant, wrapped_value: Dictionary) -> void:
	assert(instance != null, "instance is null, can't deserialize into a null instance")
	assert(wrapped_value != null, "wrapped_value is null")
	
	var serializer: JSONSerializer = get_serializer(instance)
	
	# In debug, ensure serializers match up from instance type & wrapped type
	if OS.is_debug_build():
		var wrapped_serializer: JSONSerializer = get_deserializer(wrapped_value)
		assert(serializer == wrapped_serializer, ("serializer (%s) of instance (%s) " + \
		"does not match serializer (%s) of wrapped_value (%s)") % [serializer, instance, \
		 wrapped_serializer, wrapped_value])
	
	var unwrapped_value: Variant = unwrap_value(wrapped_value)
	serializer._deserialize_into(instance, unwrapped_value)


## Helper function that calls [method serialize] with the [param variant],
## then passing that varaint & other parameters into [method JSON.stringify], returning
## that value.
func stringify(variant: Variant) -> String:
	var serialized: Dictionary = serialize(variant)
	return JSON.stringify(serialized, indent, sort_keys, full_precision)


## Helper function that calls [method JSON.parse] with [param wrapped_json_string], then
## sends the resulting [Variant] to [method deserialize], returning that value.
func parse(wrapped_json_string: String) -> Variant:
	var parsed: Variant = _parse(wrapped_json_string)
	return deserialize(parsed as Dictionary)


## Helper function to call [method JSON.parse_string] with [param wrapped_json_string], then
## sends the resulting [Variant] and [param instance] to [method deserialize_into].
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
