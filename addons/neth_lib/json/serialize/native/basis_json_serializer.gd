extends JSONSerializer


var _vector3serializer: JSONSerializer

func _init(vector3serializer: JSONSerializer) -> void:
	_vector3serializer = vector3serializer


func _get_id() -> Variant:
	return TYPE_BASIS


func _serialize(instance: Variant) -> Variant:
	assert(instance is Basis, "instance not of type Basis")
	assert(_vector3serializer != null, "_vector3serializer is null")
	return {
		"x": _vector3serializer._serialize(instance.x),
		"y": _vector3serializer._serialize(instance.y),
		"z": _vector3serializer._serialize(instance.z),
	}


func _deserialize(owner: Object, property: Dictionary, serialized: Variant) -> Variant:
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	assert(serialized["x"] is Dictionary, "x is not a Dictionary")
	assert(serialized["y"] is Dictionary, "y is not a Dictionary")
	assert(serialized["z"] is Dictionary, "z is not a Dictionary")
	assert(_vector3serializer != null, "_vector3serializer is null")
	
	return Basis(
		_vector3serializer._deserialize(serialized["x"]), 
		_vector3serializer._deserialize(serialized["y"]), 
		_vector3serializer._deserialize(serialized["z"])
	)
