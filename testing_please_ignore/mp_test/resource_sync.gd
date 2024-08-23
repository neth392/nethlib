class_name ResourceSync extends Resource

var my_string: String = "hi!"

var my_array: Array[int] = [5,4,3,2,1]


func _to_string() -> String:
	return ObjectUtil.to_string_helper("ResourceSync", self)
