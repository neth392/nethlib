class_name TestJSONObject extends Resource

var str: String
var str_dont_serialize: String
var iint: int
var ffloat: float
var vec2: Vector2 = Vector2(99, 99)
var vec3: Vector3 
var color: Color
var dictionary: Dictionary
var sub_resource: TestJSONObject = null


class Serializer extends JSONSerializer:
	
	func _can_serialize(variant) -> bool:
		return variant is TestJSONObject
	
	
	func _get_property_names() -> Array[StringName]:
		return [
			&"str",
			&"iint",
			&"ffloat",
			&"vec2",
			&"vec3",
			&"color",
		]
