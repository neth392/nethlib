class_name GeneralTesting extends Node


var test_dictionary: Dictionary[String, int] = {
	"one": 1,
	"two": 2,
	"three": 3,
}


func _ready() -> void:
	var obj: TestParent = load("res://testing_please_ignore/test_parent_res.tres")
	
	var json: String = JSON.stringify(JSON.from_native(obj, true, true))
	print(JSON.from_native(obj))
	print(obj)
	var parsed: Variant = JSON.to_native(JSON.parse_string(json), true, true)
	print(parsed)
	print(typeof(parsed))
	# Trying to assign value of type 'String' to a variable of type 'Vector2'.
	obj = null
	obj = parsed
	print(obj)
