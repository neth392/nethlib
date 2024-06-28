class_name JSONTestObject extends Resource

var str: String
var str_dont_serialize: String
var iint: int
var ffloat: float
var vec2: Vector2 = Vector2(99, 99)
var vec3: Vector3 
var color: Color
var dictionary: Dictionary
var generic_array: Array = [1.0, 2.0, 3.0]
var typed_array: Array[String] = []
var sub_object: JSONTestObject 

func _to_string() -> String:
	return "\ncolor " + str(color) + "\n" + \
	"vec2: " + str(vec2) + "\n" + \
	"vec3: " + str(vec3) + "\n" + \
	"str: " + str(str) + "\n" + \
	"iint: " + str(iint) + "\n" + \
	"ffloat: " + str(ffloat) + "\n" + \
	"generic_array: " + str(generic_array) + "\n" + \
	"typed_array: \n" + str(typed_array) + "\n" + \
	"sub_object: " + str(sub_object) + "\n"

class Serializer extends ObjectJSONSerializer:
	
	func _init() -> void:
		super._init(&"JSONTestObject", DeserializeMode.BOTH)
	
	func _can_serialize(variant) -> bool:
		return variant is JSONTestObject
	
	func _deserialize(serialized: Variant) -> Variant:
		return _deserialize_into(JSONTestObject.new(), serialized)
	
	func _get_property_names() -> Dictionary:
		return {
			&"str": IfMissing.SET_NULL,
			&"iint": IfMissing.SET_NULL,
			&"ffloat": IfMissing.SET_NULL,
			&"vec2": IfMissing.SET_NULL,
			&"vec3": IfMissing.SET_NULL,
			&"color": IfMissing.SET_NULL,
			&"sub_object": IfMissing.SET_NULL,
			&"typed_array": IfMissing.SET_NULL,
			&"generic_array": IfMissing.SET_NULL,
		}
