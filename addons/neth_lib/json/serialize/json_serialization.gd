## Autoloaded class (named JSONSerialization) responsible for managing [JSONSerializer]s and providing
## serialization & deserialization. See [JSONSerializationImpl] (the implementation) for more information.
@tool
extends JSONSerializationImpl

## Constructs a new [JSONSerializationImpl] instance with support for reading errors.
## The returned node should NOT be added to the tree.
func new() -> JSONSerializationImpl:
	var instance: JSONSerializationImpl = JSONSerializationImpl.new()
	instance._serializers = _serializers.duplicate(false)
	instance.indent = indent
	instance.sort_keys = sort_keys
	instance.full_precision = full_precision
	instance.keep_text = keep_text
	instance._color = _color
	instance._vector2 = _vector2
	instance._vector2i = _vector2i
	instance._vector3 = _vector3
	instance._basis = _basis
	instance._vector4 = _vector4
	instance._object = _object
	return instance


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
	add_serializer(PrimitiveJSONSerializer.new(TYPE_NODE_PATH))
	add_serializer(PrimitiveJSONSerializer.new(TYPE_PACKED_INT32_ARRAY))
	add_serializer(PrimitiveJSONSerializer.new(TYPE_PACKED_INT64_ARRAY))
	add_serializer(PrimitiveJSONSerializer.new(TYPE_PACKED_FLOAT32_ARRAY))
	add_serializer(PrimitiveJSONSerializer.new(TYPE_PACKED_FLOAT64_ARRAY))
	add_serializer(PrimitiveJSONSerializer.new(TYPE_PACKED_STRING_ARRAY))
	
	# TYPE_ARRAY
	# TODO: FIX
	#add_serializer(preload("./native/array_json_serializer.gd").new())
	
	# TYPE_DICTIONARY
	# TODO: FIX
	#add_serializer(preload("./native/dictionary_json_serializer.gd").new())
	
	# TYPE_COLOR
	_color = preload("./native/color_json_serializer.gd").new()
	add_serializer(_color)
	
	# TYPE_PACKED_COLOR_ARRAY
	add_serializer(preload("./native/packed_color_array_json_serializer.gd").new())
	
	# TYPE_QUARTERNION
	add_serializer(preload("./native/quarternion_json_serializer.gd").new())
	
	# TYPE_VECTOR2
	_vector2 = preload("./native/vector2_json_serializer.gd").new()
	add_serializer(_vector2)
	
	# TYPE_PACKED_VECTOR2_ARRAY
	add_serializer(preload("./native/packed_vector2_array_json_serializer.gd").new())
	
	# TYPE_RECT2
	add_serializer(preload("./native/rect2_json_serializer.gd").new())
	
	# TYPE_TRANSFORM2D
	add_serializer(preload("./native/transform2d_json_serializer.gd").new())
	
	# TYPE_VECTOR2i
	_vector2i = preload("./native/vector2i_json_serializer.gd").new()
	add_serializer(_vector2i)
	
	# TYPE_RECT2i
	add_serializer(preload("./native/rect2i_json_serializer.gd").new())
	
	# TYPE_VECTOR3i
	add_serializer(preload("./native/vector3i_json_serializer.gd").new())
	
	# TYPE_VECTOR3
	_vector3 = preload("./native/vector3_json_serializer.gd").new()
	add_serializer(_vector3)
	
	# TYPE_PACKED_VECTOR3_ARRAY
	add_serializer(preload("./native/packed_vector3_array_json_serializer.gd").new())
	
	# TYPE_PLANE
	add_serializer(preload("./native/plane_json_serializer.gd").new())
	
	# TYPE_BASIS
	_basis = preload("./native/basis_json_serializer.gd").new()
	add_serializer(_basis)
	
	# TYPE_TRANSFORM3D
	add_serializer(preload("./native/transform3d_json_serializer.gd").new())
	
	# TYPE_AABB
	add_serializer(preload("./native/aabb_json_serializer.gd").new())
	
	# TYPE_VECTOR4i
	add_serializer(preload("./native/vector4i_json_serializer.gd").new())
	
	# TYPE_VECTOR4
	_vector4 = preload("./native/vector4_json_serializer.gd").new()
	add_serializer(_vector4)
	
	# TYPE_PACKED_VECTOR4_ARRAY
	add_serializer(preload("./native/packed_vector4_array_json_serializer.gd").new())
	
	# TYPE_PROJECTION
	add_serializer(preload("./native/projection_json_serializer.gd").new())
