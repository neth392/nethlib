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
]

@onready var _vector2: JSONSerializer = preload("./default/vector2_json_serializer.gd").new()
@onready var _vector3: JSONSerializer = preload("./default/vector3_json_serializer.gd").new()
@onready var _color: JSONSerializer = preload("./default/color_json_serializer.gd").new()

var _serializers: Array[JSONSerializer] = []

func _ready() -> void:
	add_serializer(_vector2)
	add_serializer(_vector3)
	add_serializer(_color)


func add_serializer(serializer: JSONSerializer) -> void:
	assert(!_serializers.has(serializer), "serializer already registered: %s" % serializer)
	_serializers.append(serializer)


func get_serializer(variant: Variant) -> JSONSerializer:
	assert(variant != null, "variant is null")
	for serializer: JSONSerializer in _serializers:
		if serializer._can_serialize(variant):
			return serializer
	return null


func serialize(variant: Variant) -> Dictionary:
	assert(get_serializer(variant) != null, "no serializer for variant (%s)" % variant)
	var serializer: JSONSerializer = get_serializer(variant)
	return serializer._serialize(variant)


func deserialize_into(instance: Variant, json_dictionary: Dictionary) -> void:
	assert(instance != null, "instance is null")
	assert(get_serializer(instance) != null, "no serializer for instance (%s)" % instance)
	var serializer: JSONSerializer = get_serializer(instance)
	serializer._deserialize_into(instance, json_dictionary)


## Serializes the [param object] based on the [param property_struct]. The [param property_struct]
## must be a [Dictionary] whose keys are [StringName]s representing the names of the properties 
## to be parsed.[br]
## Any property from the object that is native or is supported by a [JSONSerializer] 
## will be parsed automatically.[br]
## Properties that have a value as a [Dictionary] will be recursively sent back
## through this method as their own object, and that dictionary value will be the struct.[br]
## [Array] properties must be statically typed, and elements must be either a native value 
## or supported by a [JSONSerializer].[br]
## TODO dictionary
func serialize_object(object: Object, property_struct: Dictionary) -> Dictionary:
	assert(object != null, "object is null")
	assert(property_struct != null, "property_struct is null")
	assert(!property_struct.is_empty(), "property_struct is empty")
	
	var serialized: Dictionary = {}
	_serialize_object(func(prop_name): return object.get(prop_name), property_struct, serialized)
	return serialized


# Internal function. Only note is [param getter] allows submitting either an [Object]
# or [Dictionary] for this function.
func _serialize_object(getter: Callable, property_struct: Dictionary, current_dict: Dictionary) -> void:
	for property_name: String in property_struct:
		var value: Variant = getter.call(property_name)
		
		# Check if the value is null
		if value == null:
			current_dict[property_name] = null
			continue
		
		var type: Variant.Type = typeof(value)
		var sub_struct = property_struct[property_name]
		if sub_struct is Dictionary:
			assert(!_native_types.has(type), "sub_struct defined but value (%s) is a native type " + \
			"for property (%s)" % [value, property_name])
			assert(value is Object, "sub_struct defined but value (%s) not of type object " + \
			"for property (%s)" % [value, property_name])
		
		# Check if the type is natively supported.
		if _native_types.has(type):
			current_dict[property_name] = value
			continue
		
		if type == TYPE_ARRAY:
			var array: Array = value as Array
			assert(array.is_typed(), "array (%s) is not typed, untyped arrays are not supported" \
			% property_name)
			if array.is_empty():
				current_dict[property_name] = []
				continue
			# TODO figure this out, parse first element?
			continue
		
		if type == TYPE_DICTIONARY:
			# TODO figure this out; how will the structs work?
			continue
			var dictionary: Dictionary = value as Dictionary
			if dictionary.is_empty():
				current_dict[property_name] = {}
				continue
			var sub_dict: Dictionary = {}
			_serialize_object(func(prop_name): return dictionary[prop_name], dictionary, sub_dict)
			current_dict[property_name] = sub_dict
			continue
		
		var serializer: JSONSerializer = get_serializer(value)
		if serializer != null:
			current_dict[property_name] = serializer._serialize(value)
			continue
		
		if sub_struct is Dictionary:
			var sub_dict: Dictionary = {}
			_serialize_object(func(prop_name): return value.get(prop_name), sub_struct, sub_dict)
			current_dict[property_name] = sub_dict
			continue
		
		push_error("unable to parse property (%s) with value (%s)" % [property_name, value])
