class_name GeneralTesting extends Node


@export var script_to_test: Script

var types_dict: Dictionary = {
	TYPE_NIL: "TYPE_NIL",
	TYPE_BOOL: "TYPE_BOOL",
	TYPE_INT: "TYPE_INT",
	TYPE_FLOAT: "TYPE_FLOAT",
	TYPE_STRING: "TYPE_STRING",
	TYPE_VECTOR2: "TYPE_VECTOR2",
	TYPE_VECTOR2I: "TYPE_VECTOR2I",
	TYPE_RECT2: "TYPE_RECT2",
	TYPE_RECT2I: "TYPE_RECT2I",
	TYPE_VECTOR3: "TYPE_VECTOR3",
	TYPE_VECTOR3I: "TYPE_VECTOR3I",
	TYPE_TRANSFORM2D: "TYPE_TRANSFORM2D",
	TYPE_VECTOR4: "TYPE_VECTOR4",
	TYPE_VECTOR4I: "TYPE_VECTOR4I",
	TYPE_PLANE: "TYPE_PLANE",
	TYPE_QUATERNION: "TYPE_QUATERNION",
	TYPE_AABB: "TYPE_AABB",
	TYPE_BASIS: "TYPE_BASIS",
	TYPE_TRANSFORM3D: "TYPE_TRANSFORM3D",
	TYPE_PROJECTION: "TYPE_PROJECTION",
	TYPE_COLOR: "TYPE_COLOR",
	TYPE_STRING_NAME: "TYPE_STRING_NAME",
	TYPE_NODE_PATH: "TYPE_NODE_PATH",
	TYPE_RID: "TYPE_RID",
	TYPE_OBJECT: "TYPE_OBJECT",
	TYPE_DICTIONARY: "TYPE_DICTIONARY",
	TYPE_ARRAY: "TYPE_ARRAY",
	TYPE_PACKED_BYTE_ARRAY: "TYPE_PACKED_BYTE_ARRAY",
	TYPE_PACKED_INT32_ARRAY: "TYPE_PACKED_INT32_ARRAY",
	TYPE_PACKED_INT64_ARRAY: "TYPE_PACKED_INT64_ARRAY",
	TYPE_PACKED_FLOAT32_ARRAY: "TYPE_PACKED_FLOAT32_ARRAY",
	TYPE_PACKED_FLOAT64_ARRAY: "TYPE_PACKED_FLOAT64_ARRAY",
	TYPE_PACKED_STRING_ARRAY: "TYPE_PACKED_STRING_ARRAY",
	TYPE_PACKED_VECTOR2_ARRAY: "TYPE_PACKED_VECTOR2_ARRAY",
	TYPE_PACKED_VECTOR3_ARRAY: "TYPE_PACKED_VECTOR3_ARRAY",
	TYPE_PACKED_COLOR_ARRAY: "TYPE_PACKED_COLOR_ARRAY",
	TYPE_PACKED_VECTOR4_ARRAY: "TYPE_PACKED_VECTOR4_ARRAY",
}

var type_examples: Dictionary = {
	TYPE_NIL: null,  # Example for NIL type
	TYPE_BOOL: true,  # Example for BOOL type
	TYPE_INT: 42,  # Example for INT type
	TYPE_FLOAT: 3.14,  # Example for FLOAT type
	TYPE_STRING: "example",  # Example for STRING type
	TYPE_VECTOR2: Vector2(1, 1),  # Example for VECTOR2 type
	TYPE_VECTOR2I: Vector2i(1, 1),  # Example for VECTOR2I type
	TYPE_RECT2: Rect2(0, 0, 100, 100),  # Example for RECT2 type
	TYPE_RECT2I: Rect2i(0, 0, 100, 100),  # Example for RECT2I type
	TYPE_VECTOR3: Vector3(1, 1, 1),  # Example for VECTOR3 type
	TYPE_VECTOR3I: Vector3i(1, 1, 1),  # Example for VECTOR3I type
	TYPE_TRANSFORM2D: Transform2D(),  # Example for TRANSFORM2D type
	TYPE_VECTOR4: Vector4(1, 1, 1, 1),  # Example for VECTOR4 type
	TYPE_VECTOR4I: Vector4i(1, 1, 1, 1),  # Example for VECTOR4I type
	TYPE_PLANE: Plane(0, 1, 0, 0),  # Example for PLANE type
	TYPE_QUATERNION: Quaternion(),  # Example for QUATERNION type
	TYPE_AABB: AABB(Vector3(0, 0, 0), Vector3(1, 1, 1)),  # Example for AABB type
	TYPE_BASIS: Basis(),  # Example for BASIS type
	TYPE_TRANSFORM3D: Transform3D(),  # Example for TRANSFORM3D type
	TYPE_PROJECTION: Projection(),  # Example for PROJECTION type
	TYPE_COLOR: Color(1, 0, 0, 1),  # Example for COLOR type
	TYPE_STRING_NAME: StringName("example"),  # Example for STRING_NAME type
	TYPE_NODE_PATH: NodePath("/root/Node"),  # Example for NODE_PATH type
	TYPE_RID: RID(),  # Example for RID type
	TYPE_OBJECT: Object.new(),  # Example for OBJECT type (an instance of Object)
	TYPE_DICTIONARY: {"key": "value"},  # Example for DICTIONARY type
	TYPE_ARRAY: [1, 2, 3],  # Example for ARRAY type
	TYPE_PACKED_BYTE_ARRAY: PackedByteArray([0x00, 0xFF]),  # Example for PACKED_BYTE_ARRAY type
	TYPE_PACKED_INT32_ARRAY: PackedInt32Array([1, 2, 3]),  # Example for PACKED_INT32_ARRAY type
	TYPE_PACKED_INT64_ARRAY: PackedInt64Array([1, 2, 3]),  # Example for PACKED_INT64_ARRAY type
	TYPE_PACKED_FLOAT32_ARRAY: PackedFloat32Array([1.1, 2.2, 3.3]),  # Example for PACKED_FLOAT32_ARRAY type
	TYPE_PACKED_FLOAT64_ARRAY: PackedFloat64Array([1.1, 2.2, 3.3]),  # Example for PACKED_FLOAT64_ARRAY type
	TYPE_PACKED_STRING_ARRAY: PackedStringArray(["one", "two", "three"]),  # Example for PACKED_STRING_ARRAY type
	TYPE_PACKED_VECTOR2_ARRAY: PackedVector2Array([Vector2(1, 1), Vector2(2, 2)]),  # Example for PACKED_VECTOR2_ARRAY type
	TYPE_PACKED_VECTOR3_ARRAY: PackedVector3Array([Vector3(1, 1, 1), Vector3(2, 2, 2)]),  # Example for PACKED_VECTOR3_ARRAY type
	TYPE_PACKED_COLOR_ARRAY: PackedColorArray([Color(1, 0, 0), Color(0, 1, 0)]),  # Example for PACKED_COLOR_ARRAY type
	TYPE_PACKED_VECTOR4_ARRAY: PackedVector4Array([Vector4(1, 1, 1, 1), Vector4(2, 2, 2, 2)]),  # Example for PACKED_VECTOR4_ARRAY type
}


var supported_types: PackedStringArray = PackedStringArray()


func _ready() -> void:
	for type: Variant.Type in types_dict:
		var type_name: String = types_dict[type]
		var serializer: JSONSerializer = PrimitiveJSONSerializer.new()
		serializer.primitive_type = type
		var value: Variant = type_examples[type]
		assert(type == typeof(value), "type example mismatch for type %s" % type_name)
		
		JSONSerialization.add_serializer(serializer)
		
		var json_string: String = JSONSerialization.stringify(value)
		var parsed: Variant = JSONSerialization.parse(json_string)
		
		JSONSerialization.remove_serializer(serializer)
		print("TEST %s, TYPE MATCH=%s, EQUALS=%s" % [type_name, typeof(value) == typeof(parsed), value == parsed])
