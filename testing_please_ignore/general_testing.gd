class_name GeneralTesting extends Node

@export var scene: PackedScene
@export var test_script: GDScript

var array_test: Array[Button] = []

func _ready() -> void:
	for method: Dictionary in test_script.get_script_method_list():
		print(method)
	pass
	#for i in 1:
		#var test_parent: TestParent = scene.instantiate() as TestParent
		## Change properties from default
		#test_parent.test_parent_string = "changed and serialized!"
		#test_parent.test_parent_int = 56789
		#
		#var test_parent_2: TestParent = scene.instantiate() as TestParent
		#test_parent_2.test_parent_string = "mem2"
		#test_parent_2.test_parent_int = 2
		#
		#var test_parent_3: TestParent = scene.instantiate() as TestParent
		#test_parent_3.test_parent_string = "mem3"
		#test_parent_3.test_parent_int = 3
		#
		#test_parent.test_array = [3,9,2]
		#test_parent.test_dictionary = {
			#1: "hi!",
			#"object": test_parent_2,
			#Vector2(9,2): "my vector",
		#}
		#
		##print("BEFORE JSON: ", test_parent)
		#
		## To JSON we go! 
		#var json: String = JSONSerialization.stringify(test_parent)
		##print("JSON:")
		##print(json)
		#
		## Back to an object (a new instance of it)
		##var deserialized: TestParent = JSONSerialization.parse(json) as TestParent
		##print("DESERIALIZED:", deserialized)
	#
	#ExecutionTimeTest.print_time_taken()
