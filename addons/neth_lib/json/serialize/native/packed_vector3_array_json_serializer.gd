extends JSONSerializer


var _vector3serializer: JSONSerializer

func _init(vector3serializer: JSONSerializer) -> void:
	_vector3serializer = vector3serializer


func _get_id() -> Variant:
	return TYPE_PACKED_VECTOR3_ARRAY


func _serialize(instance: Variant) -> Variant:
	assert(instance is PackedVector3Array, "instance not of type PackedVector3Array")
	assert(_vector3serializer != null, "_vector3serializer is null")
	var serialized: Array[Dictionary] = []
	var array: PackedVector3Array = instance as PackedVector3Array
	for vector3: Vector3 in array:
		serialized.append(_vector3serializer._serialize(vector3))
	return serialized


func _deserialize(owner: Object, property: Dictionary, serialized: Variant) -> Variant:
	assert(serialized is Array, "serialized not of type Array")
	assert(_vector3serializer != null, "_vector3serializer is null")
	
	var array: PackedVector3Array = PackedVector3Array()
	for serialized_vector3 in serialized:
		array.append(_vector3serializer._deserialize(owner, property, serialized_vector3))
	
	return array
