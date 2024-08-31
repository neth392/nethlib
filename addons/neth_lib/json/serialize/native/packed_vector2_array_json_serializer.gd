extends JSONSerializer


var _vector2serializer: JSONSerializer

func _init(vector2serializer: JSONSerializer) -> void:
	_vector2serializer = vector2serializer


func _get_id() -> Variant:
	return TYPE_PACKED_VECTOR2_ARRAY


func _serialize(instance: Variant) -> Variant:
	assert(instance is PackedVector2Array, "instance not of type PackedVector2Array")
	assert(_vector2serializer != null, "_vector2serializer is null")
	var serialized: Array[Dictionary] = []
	var array: PackedVector2Array = instance as PackedVector2Array
	for vector2: Vector2 in array:
		serialized.append(_vector2serializer._serialize(vector2))
	return serialized


func _deserialize(property: Dictionary, serialized: Variant) -> Variant:
	assert(serialized is Array, "serialized not of type Array")
	assert(_vector2serializer != null, "_vector2serializer is null")
	
	var array: PackedVector2Array = PackedVector2Array()
	for serialized_vector2 in serialized:
		array.append(_vector2serializer._deserialize(serialized_vector2))
	
	return array
