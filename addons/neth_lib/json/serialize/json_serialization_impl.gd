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

## [JSONObjectIdentifier]:[JSONObjectConfig]
var _default_object_configs: Dictionary = {}

## [member JSONObjectConfig.id]:[JSONObjectConfig]
var _object_configs_by_id: Dictionary = {}

## The user's [JSONObjectConfigRegistry] to allow adding [JSONObjectConfig]s via
## the inspector.
var _object_config_registry: JSONObjectConfigRegistry

# Internal cache of native serializers used by others to prevent unnecessary dictionary lookups
var _color: NonObjectJSONSerializer
var _vector2: NonObjectJSONSerializer
var _vector2i: NonObjectJSONSerializer
var _vector3: NonObjectJSONSerializer
var _basis: NonObjectJSONSerializer
var _vector4: NonObjectJSONSerializer
var _object: JSONSerializer


## Sets the [param config] as the default [JSONObjectConfig] for any objects/properties
## which match the [JSONObjectIdentifier] but do not have a config.
## To create a [JSONObjectIdentifier] for any type of object, see the static methods in that class.
func set_default_object_config(id: JSONObjectIdentifier, config: JSONObjectConfig) -> void:
	assert(id != null, "id is null")
	assert(config != null, "config is null")
	_default_object_configs[id] = config


## Removes the default [JSONObjectConfig] for the [param id].
## To create a [JSONObjectIdentifier] for any type of object, see the static methods in that class.
func remove_default_object_config(id: JSONObjectIdentifier) -> void:
	assert(id != null, "id is null")
	_default_object_configs.erase(id)


## Returns the default [JSONObjectConfig] for the [param id], or null if one
## does not exist.
## To create a [JSONObjectIdentifier] for any type of object, see the static methods in that class.
func get_default_object_config(id: JSONObjectIdentifier) -> JSONObjectConfig:
	assert(id != null, "id is null")
	return _default_object_configs.get(id, null)


## Returns true if the [param config] is successfully registered, false if not.
func is_config_registered(config: JSONObjectConfig) -> bool:
	return _object_config_registry != null && _object_config_registry.configs.has(config)


## Returns true if a [JSONObjectConfig] with the [param config_id] is registered, false if not.
func is_config_id_registered(config_id: StringName) -> bool:
	return _object_configs_by_id.has(config_id)


## Returns the [JSONObjectConfig] with the [param config_id], or null if no config with 
## that id is registered
func get_object_config(config_id: StringName) -> JSONObjectConfig:
	return _object_configs_by_id.get(config_id, null)


func register_object_config(config: JSONObjectConfig) -> void:
	assert(!is_config_id_registered(config.id), "id %s already registered")


### Returns the [JSONObjectConfig] for the [param object], or null if one can
### not be found. The order of the search is as follows:
### [br]1. If [param object] is not null, searches for the config in the object's metadata.
### [br]2. If [param object_owner] is not null & [param json_key] is not empty, it searches the owner's
### metadata for an [JSONObjectConfig], and if found the [param json_key] is search for a
### [JSONObjectConfig] which is returned if it can be found.
### [br]3. If [param object] is not null, searches for a default config in this [JSONSerializationImpl]
### based on its resolved [JSONObjectIdentifier].
### [br]4. If [param property] is not empty, searches for a default config based on the configured
### type (accounting for typed arrays).
#func get_object_configs(object: Object = null, object_owner: Object = null, 
#property: Dictionary = {}, json_key: StringName = &"") -> Array[JSONObjectConfig]:
	#var configs: Array[JSONObjectConfig] = []
	## 1. Check in the object instance itself
	#if object != null:
		#var config: JSONObjectConfig = JSONObjectMeta.get_config(object)
		#if config != null:
			#return [config]
	#
	## 2. Check the owner's configuration
	#if object_owner != null && !json_key.is_empty():
		#var owner_config: JSONObjectConfig = JSONObjectMeta.get_config(object_owner)
		#if owner_config != null:
			#configs = owner_config.get_configs_for_property(json_key)
			#if !configs.is_empty():
	#
				#return configs
	## 3. Check for default config for object
	#if object != null:
		#var id: JSONObjectIdentifier = JSONObjectIdentifier.from_object(object)
		#var config: JSONObjectConfig = get_default_object_config(id)
		#if config != null:
			#return [config]
	#
	## 4. Check for default config for property
	#if !property.is_empty():
		#var id: JSONObjectIdentifier = JSONObjectIdentifier.from_property(property)
		#config = get_default_object_config(id)
		#if config != null:
			#return config
	#
	## No config can be found
	#return null


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
	return _serializers.has(type)


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
## that can be safely stored via JSON & deserialized via [method deserialize_into] (excluding
## native types).
## If the type is an [Object] or statically typed [Array], [param object_configs] should have
## a size of one
func serialize(variant: Variant, object_configs: Array[JSONObjectConfig] = []) -> Dictionary:
	# str(variant) needed as some types such as RID will not work w/o it
	assert(is_serializiable(variant), "variant (%s) not supported by any JSONSerializer" % str(variant))
	
	var serializer: JSONSerializer = get_serializer_for_type(typeof(variant))
	if typeof(variant) == TYPE_OBJECT && (object_configs.is_empty() || object_configs[0] == null):
		object_configs[0] = get_object_config(variant)
		assert(object_configs[0] != null, ("variant (%s) is of TYPE_OBJECT and no object_config " + \
		"was specified or could be found") % variant)
	
	var serialized: Variant = serializer._serialize(variant, self, object_configs)
	
	return wrap_value(serializer, serialized)


## Deserializes the [param wrapped_value] and creates & returns a new instance of the type.
## [param object_owner] is the owner of the [param wrapped_value], can be null if there is
## no owner. And [param property] is the property whose value is being deserialized,
## can be empty if there is no property. TODO Explain more
func deserialize(wrapped_value: Dictionary, object_config: JSONObjectConfig = null) -> Variant:
	assert(wrapped_value != null, "wrapped_value is null, must be a Dictionary")
	
	var serializer: JSONSerializer = get_deserializer(wrapped_value)
	var unwrapped_value: Variant = unwrap_value(wrapped_value)
	
	assert(serializer.id != _object.id || object_config != null, ("wrapped_value (%s) is an object " + \
	"and object_config is null") % wrapped_value)
	
	return serializer._deserialize(unwrapped_value, self, object_config)


## Deserializes the [param wrapped_value] into the specified [param instance].
## [param object_owner] is the owner of the [param wrapped_value], can be null if there is
## no owner. And [param property] is the property whose value is being deserialized,
## can be empty if there is no property. TODO Explain more
func deserialize_into(wrapped_value: Dictionary, instance: Variant, 
object_config: JSONObjectConfig = null) -> void:
	assert(instance != null, "instance is null, can't deserialize into a null instance")
	assert(wrapped_value != null, "wrapped_value is null")
	
	var serializer: JSONSerializer = get_serializer_for_type(typeof(instance))
	
	# In debug, ensure serializers match up from instance type & wrapped type
	if OS.is_debug_build():
		var wrapped_serializer: JSONSerializer = get_deserializer(wrapped_value)
		assert(serializer == wrapped_serializer, ("serializer (%s) of instance (%s) " + \
		"does not match serializer (%s) of wrapped_value (%s)") % [serializer, instance, \
		 wrapped_serializer, wrapped_value])
	
	var unwrapped_value: Variant = unwrap_value(wrapped_value)
	serializer._deserialize_into(object_owner, property, instance, unwrapped_value)


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
