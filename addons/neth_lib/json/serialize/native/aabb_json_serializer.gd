extends JSONSerializer


var _vector3serializer: JSONSerializer

func _init(vector3serializer: JSONSerializer) -> void:
	_vector3serializer = vector3serializer


func _get_id() -> Variant:
	return TYPE_AABB


func _serialize(instance: Variant) -> Variant:
	assert(instance is AABB, "instance not of type AABB")
	assert(_vector3serializer != null, "_vector3serializer is null")
	return {
		"p": _vector3serializer._serialize(instance.position),
		"e": _vector3serializer._serialize(instance.end),
	}


func _deserialize(property: Dictionary, serialized: Variant) -> Variant:
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	assert(serialized["p"] is Dictionary, "p is not a Dictionary")
	assert(serialized["e"] is Dictionary, "e is not a Dictionary")
	assert(_vector3serializer != null, "_vector3serializer is null")
	
	var aabb: AABB = AABB()
	aabb.position = _vector3serializer._deserialize(serialized["p"])
	aabb.end = _vector3serializer._deserialize(serialized["e"])
	return aabb
