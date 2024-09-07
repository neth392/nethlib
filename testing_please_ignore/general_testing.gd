class_name GeneralTesting extends Node

@export var scene: PackedScene

var array_test: Array[Button] = []

func _ready() -> void:
	# Serialize this bad boy
	var test_parent: TestParent = scene.instantiate() as TestParent
	# Change properties from default
	test_parent.test_parent_string = "changed and serialized!"
	test_parent.test_parent_int = 56789
	
	var test_parent_2: TestParent = scene.instantiate() as TestParent
	test_parent_2.test_parent_string = "mem2"
	test_parent_2.test_parent_int = 2
	
	var test_parent_3: TestParent = scene.instantiate() as TestParent
	test_parent_3.test_parent_string = "mem3"
	test_parent_3.test_parent_int = 3
	
	test_parent.test_array = [[test_parent_2, test_parent_3]]
	
	print("BEFORE JSON: ", test_parent)
	
	# To JSON we go! 
	var json: String = JSONSerialization.stringify(test_parent)
	print("JSON:")
	print(json)
	
	# Back to an object (a new instance of it)
	var deserialized: TestParent = JSONSerialization.parse(json) as TestParent
	print("DESERIALIZED:", deserialized)
