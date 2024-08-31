extends JSONSerializer


var _color_serializer: JSONSerializer

func _init(color_serializer: JSONSerializer) -> void:
	_color_serializer = color_serializer


func _get_id() -> Variant:
	return TYPE_PACKED_COLOR_ARRAY


func _serialize(instance: Variant) -> Variant:
	assert(instance is PackedColorArray, "instance not of type PackedColorArray")
	assert(_color_serializer != null, "_color_serializer is null")
	var serialized: Array[Dictionary] = []
	var array: PackedColorArray = instance as PackedColorArray
	for color: Color in array:
		serialized.append(_color_serializer._serialize(color))
	return serialized


func _deserialize(owner: Object, property: Dictionary, serialized: Variant) -> Variant:
	assert(serialized is Array, "serialized not of type Array")
	assert(_color_serializer != null, "_color_serializer is null")
	
	var array: PackedColorArray = PackedColorArray()
	for serialized_color in serialized:
		array.append(_color_serializer._deserialize(owner, property, serialized_color))
	
	return array
