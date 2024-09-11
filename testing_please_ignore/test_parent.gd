class_name TestParent extends Resource

@export var test_parent_string: String = "parent_prop"
@export var test_parent_int: int = 4
@export var test_array: Array[int] = []
@export var test_dictionary: Dictionary[int, String] = {}
@export var test_parent_sub: TestParent

func _init(test: StringName = &"") -> void:
	pass


func do_shit() -> void:
	Array()
	pass


func _to_string() -> String:
	return "TestParent(string=%s,int=%s,array=%s,dict=%s,sub=%s)" \
	% [test_parent_string, test_parent_int, test_array, test_dictionary, test_parent_sub]
