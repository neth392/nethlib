class_name GeneralTesting extends Node

@export var scene: PackedScene

func _ready() -> void:
	var test_parent: TestParent = scene.instantiate()
	test_parent.test_parent_prop = "changed and serialized!"
	test_parent.test_parent_3 = 56789
	
	var json: String = JSONSerialization.stringify(test_parent)
	print("JSON:")
	print(json)
	
	var deserialized: TestParent = JSONSerialization.parse(json) as TestParent
	print("DESERIALIZED:")
	print("test_parent_prop: ", deserialized.test_parent_prop)
	print("test_parent_3: ", deserialized.test_parent_3)
