class_name TestParent extends Button

@export var test_parent_string: String = "parent_prop"
var test_parent_int: int = 4
var test_array: Array[Array] = [[]]


func do_shit() -> void:
	Array()
	pass


func _to_string() -> String:
	return "TestParent(string=%s,int=%s,array=%s)" % [test_parent_string, test_parent_int, test_array]
