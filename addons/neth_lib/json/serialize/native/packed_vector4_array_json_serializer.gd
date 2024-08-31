extends JSONSerializer


var _vector4serializer: JSONSerializer

func _init(vector4serializer: JSONSerializer) -> void:
	_vector4serializer = vector4serializer


func _get_id() -> Variant:
	return TYPE_PACKED_VECTOR4_ARRAY


func _serialize(instance: Variant) -> Variant:
	assert(instance is PackedVector4Array, "instance not of type PackedVector4Array")
	assert(_vector4serializer != null, "_vector4serializer is null")
	var serialized: Array[Dictionary] = []
	var array: PackedVector4Array = instance as PackedVector4Array
	for vector4: Vector4 in array:
		serialized.append(_vector4serializer._serialize(vector4))
	return serialized


func _deserialize(owner: Object, property: Dictionary, serialized: Variant) -> Variant:
	assert(serialized is Array, "serialized not of type Array")
	assert(_vector4serializer != null, "_vector4serializer is null")
	
	var array: PackedVector4Array = PackedVector4Array()
	for serialized_vector4 in serialized:
		array.append(_vector4serializer._deserialize(serialized_vector4))
	
	return array
