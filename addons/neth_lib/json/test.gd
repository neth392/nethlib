class_name Test extends JSONSerializer


func _can_serialize(variant) -> bool:
	return variant is Test



func _serialize(variant: Test) -> Dictionary:
	return {
		"str": variant.str,
		"iint": variant.iint,
		
	}


func _deserialize_into(instance: Test, json_dictionary: Dictionary) -> void:
	pass



class TestRes extends Resource:
	
	
	
	var str: String
	var iint: int
	var ffloat: float
	var vec2: Vector2 = Vector2()
	var vec3: Vector3 = Vector3()
