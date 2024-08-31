extends JSONSerializer


var _vector4serializer: JSONSerializer

func _init(vector4serializer: JSONSerializer) -> void:
	_vector4serializer = vector4serializer


func _get_id() -> Variant:
	return TYPE_PROJECTION


func _serialize(instance: Variant) -> Variant:
	assert(instance is Projection, "instance not of type Projection")
	assert(_vector4serializer != null, "_vector4serializer is null")
	return {
		"x": _vector4serializer._serialize(instance.x),
		"y": _vector4serializer._serialize(instance.y),
		"z": _vector4serializer._serialize(instance.z),
		"w": _vector4serializer._serialize(instance.w),
	}


func _deserialize(owner: Object, property: Dictionary, serialized: Variant) -> Variant:
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	assert(serialized["x"] is Dictionary, "x is not a Dictionary")
	assert(serialized["y"] is Dictionary, "y is not a Dictionary")
	assert(serialized["z"] is Dictionary, "z is not a Dictionary")
	assert(serialized["w"] is Dictionary, "w is not a Dictionary")
	assert(_vector4serializer != null, "_vector4serializer is null")
	
	return Projection(
		_vector4serializer._deserialize(serialized["x"]),
		_vector4serializer._deserialize(serialized["y"]),
		_vector4serializer._deserialize(serialized["z"]),
		_vector4serializer._deserialize(serialized["w"]),
	)
