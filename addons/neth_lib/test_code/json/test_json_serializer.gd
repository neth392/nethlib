class_name TestJSONSerializer extends ObjectJSONSerializer


func _can_serialize(variant) -> bool:
	return variant is TestJSONObject


func _get_property_names() -> Array[StringName]:
	return [
		&"str",
		&"iint",
		&"ffloat",
		&"vec2"
	]
