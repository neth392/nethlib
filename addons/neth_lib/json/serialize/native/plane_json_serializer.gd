extends JSONSerializer


var _vector3serializer: JSONSerializer

func _init(vector3serializer: JSONSerializer) -> void:
	_vector3serializer = vector3serializer


func _get_id() -> Variant:
	return TYPE_PLANE


func _serialize(instance: Variant) -> Variant:
	assert(instance is Plane, "instance not of type Plane")
	assert(_vector3serializer != null, "_vector3serializer is null")
	return {
		"n": _vector3serializer._serialize(instance.normal),
		"d": instance.d,
	}


func _deserialize(owner: Object, property: Dictionary, serialized: Variant) -> Variant:
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	assert(serialized["n"] is Dictionary, "n is not a Dictionary")
	assert(serialized["d"] is float, "d is not a Dictionary")
	assert(_vector3serializer != null, "_vector3serializer is null")
	
	return Plane(
		_vector3serializer._deserialize(serialized["n"]),
		serialized["d"]
	)
