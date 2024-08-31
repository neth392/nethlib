extends JSONSerializer


var _vector3serializer: JSONSerializer
var _basis_json_serializer: JSONSerializer

func _init(vector3serializer: JSONSerializer, basis_json_serializer: JSONSerializer) -> void:
	_vector3serializer = vector3serializer
	_basis_json_serializer = basis_json_serializer


func _get_id() -> Variant:
	return TYPE_TRANSFORM3D


func _serialize(instance: Variant) -> Variant:
	assert(instance is Transform3D, "instance not of type Transform3D")
	assert(_vector3serializer != null, "_vector3serializer is null")
	assert(_basis_json_serializer != null, "_basis_json_serializer is null")
	return {
		"b": _basis_json_serializer._serialize(instance.basis),
		"o": _vector3serializer._serialize(instance.origin),
	}


func _deserialize(owner: Object, property: Dictionary, serialized: Variant) -> Variant:
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	assert(serialized["b"] is Dictionary, "b is not a Dictionary")
	assert(serialized["o"] is Dictionary, "o is not a Dictionary")
	assert(_vector3serializer != null, "_vector3serializer is null")
	assert(_basis_json_serializer != null, "_basis_json_serializer is null")
	
	return Transform3D(
		_basis_json_serializer._deserialize(owner, property, serialized["b"]), 
		_vector3serializer._deserialize(owner, property, serialized["o"]), 
	)
