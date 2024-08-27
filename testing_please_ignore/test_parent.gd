class_name TestParent extends Button

@export var test_parent_prop: String = ""

func _init(test: String, test2: int) -> void:
	print("init: test=%s, test2=%s" % [test, test2])


func do_shit() -> void:
	pass
